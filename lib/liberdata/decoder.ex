defmodule Liberdata.Decoder do
  def decode(url, "csv"), do: decode_csv(url)
  def decode(_, unknown_type), do: {:err, "Unknown type #{unknown_type}"}

  def decode_csv(url) do
    stream = case download(url) do
      {:ok, resp} -> resp.body
      error -> throw error
    end
    |> String.split("\n")
    |> Stream.filter(fn line -> String.trim(line) != "" end)
    |> CSV.decode
    |> Stream.map(fn
      {:ok, line} -> line
      {:error, _line} -> nil
      row when is_list(row) -> row
    end)
    |> Stream.filter(fn line -> line != nil end)

    headers = List.to_tuple(Enum.map(Enum.at(stream, 0), &String.trim/1))
    rows = stream
    |> Stream.drop(1)
    |> Stream.map(fn row -> # maybe we get rid of this and push it into a Masseuse step?
      Enum.map(row, &convert_type/1)
    end)
    |> Stream.map(&List.to_tuple/1)
    # it might be useful to check the row lengths and header length are all equal here as well
    {:ok, %Liberdata.Table{headers: headers, rows: rows}}
  end

  def download(url) do
    HTTPoison.get(url)
  end

  def convert_type(string) do
    cond do
      Regex.match?(~r/^\d+$/, string) ->
        {num, _} = Integer.parse(string)
        num
      true -> string
    end
  end
end
