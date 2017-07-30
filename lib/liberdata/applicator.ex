defmodule Liberdata.Applicator do
  alias Liberdata.{Decoder, Rows, Row, Commands}
  import Kernel, except: [apply: 2]
  use Commands

  doc :load, """
  Load a resource of a certain type. This should be the first part of the URL, 
  and the resource path should be escaped using standard URL encoding.

  You can use the example file from: `https://liberdata.tech/example.csv` 

  eg:
  ```
  /api/load/csv/https%3A%2F%2Fliberdata.tech%2Fexample.csv
  ```
  """
  cmd ["load", type, resource] do
    Decoder.decode(resource, type)
  end

  doc :filter, """
  Select certain rows from the data that match a predicate.
  Supported operators are: `==`, `<`, `>`, `<=`, `>=`.

  Find houses that have exactly five beds
  ```
  .../filter/Beds/==/5
  ```
  """
  cmd [rows = %Rows{}, "filter"], rest do
    {f, rest} = filter(["or" | rest])
    rows = Rows.filter(rows, f) 
    {:ok, rows, rest}
  end

  doc :count, """
  Get the count of the number of rows in the dataset.

  ```
  .../count
  ```
  """
  cmd [%Rows{rows: rows}, "count"] do
    rows = rows
    |> Enum.count
    |> Rows.scalar(:count)
    {:ok, rows}
  end

  doc :select, """

  """
  cmd [rows = %Rows{}, "select", columns] do

  end

  doc :sum, """
  Sum a column of numbers. Non-numeric values are counted as `0`.

  ```
  .../sum/my-column
  ```
  """
  cmd [rows = %Rows{}, "sum", column] do
    sum = rows
    |> Rows.map(fn row -> Row.get(row, column) end)
    |> Rows.filter(fn
      num when is_number(num) -> num
      _ -> 0
    end)
    |> Rows.unwrap
    |> Enum.sum
    |> Rows.scalar(:sum)

    {:ok, sum}
  end

  opr :==, rhs, lhs, do: lhs == rhs
  opr :<, rhs, lhs, do: lhs < rhs
  opr :>, rhs, lhs, do: lhs > rhs
  opr :<=, rhs, lhs, do: lhs <=  rhs
  opr :>=, rhs, lhs, do: lhs >=  rhs
end
