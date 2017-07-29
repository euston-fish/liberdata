defmodule Liberdata.Table do
  alias Liberdata.Table

  defstruct [:headers, :rows] # maybe these should be tuples for nicer indexing?

  def new(headers, rows), do: %Table{headers: headers, rows: rows}

  def labelled_rows(%Table{headers: headers, rows: rows}) do
    rows |> Stream.map(&Enum.into(Enum.zip(Tuple.to_list(headers), Tuple.to_list(&1)), %{}))
  end
end

defimpl Poison.Encoder, for: Liberdata.Table do
  def encode(table = %Liberdata.Table{}, options) do
    Poison.Encoder.encode(Liberdata.Table.labelled_rows(table), options)
  end
end
