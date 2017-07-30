defmodule Liberdata.Rows do
  alias Liberdata.{Rows, Row}
  defstruct [:rows]

  def filter(%Liberdata.Rows{rows: rows}, f) do
    %Liberdata.Rows{rows: Stream.filter(rows, f)}
  end

  def map(%Liberdata.Rows{rows: rows}, f) do
    %Liberdata.Rows{rows: Stream.map(rows, f)}
  end

  def unwrap(%Liberdata.Rows{rows: rows}), do: rows

  def scalar(value, name) do
    %Rows{rows:
      [
        %Row{data:
          %{
            name => value
          }
        }
      ]
    }
  end
end

defimpl Poison.Encoder, for: Liberdata.Rows do
  def encode(%Liberdata.Rows{rows: rows}, options) do
    Poison.Encoder.encode(Enum.to_list(rows), options)
  end
end
