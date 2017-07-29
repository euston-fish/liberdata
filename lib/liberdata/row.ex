defmodule Liberdata.Row do
  alias Liberdata.Row

  defstruct [:data]

  def get(%Row{data: data}, key) do
    Map.get(data, key)
  end
end
