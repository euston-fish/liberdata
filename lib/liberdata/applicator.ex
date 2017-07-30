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
    rows = %Rows{rows:
      [
        %Row{data:
          %{count:
            Enum.count(rows)
          }
        }
      ]
    }
    {:ok, rows}
  end

  for operator <- [:==, :<, :>, :<=, :>=] do
    IO.puts "Compiling #{operator}"
    defp filter(["or", key, unquote(Atom.to_string(operator)), value | rest]) do
      {f, rest} = filter(rest)
      {&(apply(Kernel, unquote(operator), [Row.get(&1, key), value]) or f.(&1)), rest}
    end
  end
  defp filter(rest), do: {fn _ -> false end, rest}
end
