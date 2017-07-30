defmodule Liberdata.Applicator do
  alias Liberdata.{Decoder, Rows, Row, Commands}
  import Kernel, except: [apply: 2]
  use Commands

  doc :load, """
  things
  """
  cmd ["load", type, resource] do
    {:ok, rows} = Decoder.decode(resource, type)
    rows
  end

  doc :filter, """
  todo
  """
  cmd [rows = %Rows{}, "filter"], rest do
    {f, rest} = filter(["or" | rest])
    rows = Rows.filter(rows, f) 
    {rows, rest}
  end

  doc :trim, """
  todo
  """
  cmd [rows = %Rows{}, "trim", key] do
    Rows.map(rows, fn %Row{data: data} ->
      {_, data} = Map.get_and_update(data, key, fn
        nil -> :pop
        value -> {nil, String.trim(value)}
      end)
      %Row{data: data}
    end)
  end

  doc :count, """
  todo
  """
  cmd [%Rows{rows: rows}, "count"] do
    %Rows{rows:
      [
        %Row{data:
          %{count:
            Enum.count(rows)
          }
        }
      ]
    }
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
