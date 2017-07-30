defmodule Liberdata.Row do
  alias Liberdata.Row

  defstruct [:data]

  def get(%Row{data: data}, key) do
    Map.get(data, key)
  end
end

defimpl Poison.Encoder, for: Liberdata.Row do
  def encode(%Liberdata.Row{data: data}, options) do
    Poison.Encoder.encode(data, options)
  end
end
