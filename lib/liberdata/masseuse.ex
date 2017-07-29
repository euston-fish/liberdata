defmodule Liberdata.Masseuse do
  @doc "Parse filter string"
  def apply(table = %Liberdata.Table{}, filter) do
    commands = String.split(filter)

    papply(table, commands)
  end

  defp papply(table, ["strip", key | rest]) do
    table
    |> map(key, &String.trim/1)
    |> papply(rest)
  end

  defp papply(table, ["filter", key, value | rest]) do
    table
    |> filter(key, MapSet.new([value]))
    |> papply(rest)
  end

  defp papply(table, ["count"]) do
    table
    |> count()
  end

  defp papply(table, _) do
    table
  end

  @doc "Filter a table on `key`, only including rows where the value is in `value_set`"
  def filter(%Liberdata.Table{headers: headers, rows: rows}, key, value_set) do
    col_index = column_index(headers, key)
    %Liberdata.Table{
      headers: headers,
      rows: rows |> Stream.filter(&MapSet.member?(value_set, elem(&1, col_index)))
    }
  end

  @doc "Map `key` of a table, applying `f` to the values"
  def map(%Liberdata.Table{headers: headers, rows: rows}, key, f) do
    col_index = column_index(headers, key)
    IO.inspect %Liberdata.Table{
      headers: headers, 
      rows: rows |> Stream.map(&put_elem(&1, col_index, f.(elem(&1, col_index))))
    }
  end

  def count(%Liberdata.Table{rows: rows}) do
    rows |> Enum.count()
  end

  defp column_index(headers, key), do: Enum.find_index(Tuple.to_list(headers), &(key==&1))
end
