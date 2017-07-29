defmodule Liberdata.Masseuse do
  @doc "Filter a table on `key`, only including rows where the value is in `value_set`"
  def filter(%Liberdata.Table{headers: headers, rows: rows}, key, f) do
    col_index = column_index(headers, key)
    %Liberdata.Table{
      headers: headers,
      rows: rows |> Stream.filter(&f.(elem(&1, col_index)))
    }
  end

  @doc "Map `key` of a table, applying `f` to the values"
  def map(%Liberdata.Table{headers: headers, rows: rows}, key, f) do
    col_index = column_index(headers, key)
    %Liberdata.Table{
      headers: headers, 
      rows: rows |> Stream.map(&put_elem(&1, col_index, f.(elem(&1, col_index))))
    }
  end

  def count(%Liberdata.Table{rows: rows}) do
    rows |> Enum.count()
  end

  defp column_index(headers, key), do: Enum.find_index(Tuple.to_list(headers), &(key==&1))
end
