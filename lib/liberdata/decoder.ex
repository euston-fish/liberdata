defmodule Liberdata.Decoder do
  def decode(url, type), do: decode_csv(url)
  def decode(_, unknown_type), do: {:err, "Unknown type #{unknown_type}"}

  def decode_csv(url) do
    stream = case download(url) do
      {:ok, resp} -> resp.body
      error -> throw error
    end
    |> String.split("\n")
    |> CSV.decode
    |> Stream.map(fn
      {:ok, line} -> line
      {:error, _line} -> nil
    end)
    |> Stream.filter(fn line -> line != nil end)

    [headers] = Enum.take(stream, 1)
    result = stream
    |> Stream.drop(1)
    |> Stream.map(fn row ->
      Enum.map(row, &convert_type/1)
    end)
    |> Stream.map(fn row ->
      Enum.zip(headers, row)
      |> Enum.into(%{})
    end)
    {:ok, result}
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
