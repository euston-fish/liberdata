defmodule Liberdata.Applicator do
  alias Liberdata.{Decoder, Masseuse, Table}
  import Kernel, except: [apply: 2]

  def apply(["load", type, resource | rest], state) do
    {:ok, table} = Decoder.decode(resource, type)
    apply([table | rest], state)
  end

  def apply([table = %Table{}, "filter" | rest], state) do
    {f, rest} = filter(rest, state)
    apply([Masseuse.filter(table, key, f) | rest], state)
  end

  def apply([table = %Table{}, "trim", key | rest], state) do
    apply([Masseuse.map(table, key, &String.trim/1) | rest], state)
  end

  def apply([table = %Table{}], _) do
    {:ok, table}
  end

  def apply(_, _) do
    {:err, "bad command sequence"}
  end

  def filter([key, "=", value | rest], _), do: {&(&1==value), rest}
  def filter([key, "<", value | rest], _), do: {&(&1<value), rest}
  def filter([key, ">", value | rest], _), do: {&(&1>value), rest}
  def filter([key, "<=", value | rest], _), do: {&(&1<=value), rest}
  def filter([key, ">=", value | rest], _), do: {&(&1>=value), rest}
end
