defmodule Liberdata.Decoder do
  def decode(url, "csv"), do: decode_csv(url)
  def decode(_, unknown_type), do: {:err, "Unknown type #{unknown_type}"}

  def decode_csv(url) do
    stream = case get_by_url(url) do
      {:ok, body} -> body
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

    headers = List.to_tuple(Enum.at(stream, 0))
    rows = stream
    |> Stream.drop(1)
    |> Stream.map(fn row -> # maybe we get rid of this and push it into a Masseuse step?
      Enum.map(row, &convert_type/1)
    end)
    |> Stream.map(&List.to_tuple/1)
    # it might be useful to check the row lengths and header length are all equal here as well
    {:ok, %Liberdata.Table{headers: headers, rows: rows}}
  end

  def get_by_url(url) do
    cache_location = Application.get_env(:liberdata, :cache_location)
    File.mkdir_p cache_location
    local_path = cache_location <> "/" <> String.replace(url, "/", "_")
    if File.exists? local_path do
      File.read(local_path)
    else
      case HTTPoison.get(url) do
        {:ok, resp} ->
          File.write(local_path, resp.body)
          {:ok, resp.body}
        error -> error
      end
    end
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
