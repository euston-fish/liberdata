defmodule Liberdata.Applicator do
  alias Liberdata.{Decoder, Rows, Row}
  import Kernel, except: [apply: 2]

  def apply(["load", type, resource | rest], state) do
    {:ok, rows} = Decoder.decode(resource, type)
    apply([rows | rest], state)
  end

  def apply([rows = %Rows{}, "filter" | rest], state) do
    {f, rest} = filter(rest, state)
    apply([Rows.filter(rows, f) | rest], state)
  end

  def apply([rows = %Rows{}, "trim", key | rest], state) do
    rows = rows
    |> Rows.map(fn %Row{data: data} ->
      {_, data} = Map.get_and_update(data, key, fn
        nil -> :pop
        value -> {String.trim(value), String.trim(value)}
      end)
      %Row{data: data}
    end)
    apply([rows | rest], state)
  end

  def apply([rows = %Rows{}], _) do
    {:ok, rows}
  end

  def apply(_, _) do
    {:err, "bad command sequence"}
  end

  def filter([key, "=", value | rest], _), do: {&(Row.get(&1, key)==value), rest}
  def filter([key, "<", value | rest], _), do: {&(Row.get(&1, key)<value), rest}
  def filter([key, ">", value | rest], _), do: {&(Row.get(&1, key)>value), rest}
  def filter([key, "<=", value | rest], _), do: {&(Row.get(&1, key)<=value), rest}
  def filter([key, ">=", value | rest], _), do: {&(Row.get(&1, key)>=value), rest}
end
