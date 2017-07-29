defmodule Liberdata.Applicator do
  alias Liberdata.{Decoder, Rows, Row}
  import Kernel, except: [apply: 2]

  def apply(["load", type, resource | rest], state) do
    {:ok, rows} = Decoder.decode(resource, type)
    apply([rows | rest], state)
  end

  def apply([rows = %Rows{}, "filter" | rest], state) do
    {f, rest} = filter(["or" | rest])
    apply([Rows.filter(rows, f) | rest], state)
  end

  def apply([rows = %Rows{}, "trim", key | rest], state) do
    rows = rows
    |> Rows.map(fn %Row{data: data} ->
      {_, data} = Map.get_and_update(data, key, fn
        nil -> :pop
        value -> {nil, String.trim(value)}
      end)
      %Row{data: data}
    end)
    apply([rows | rest], state)
  end

  def apply([%Rows{rows: rows}, "count"], _) do
    {:ok, Enum.count(rows)}
  end

  def apply([rows = %Rows{}], _) do
    {:ok, rows}
  end

  def apply(_, _) do
    {:err, "bad command sequence"}
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
