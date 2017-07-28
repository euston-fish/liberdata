defmodule Liberdata.AMF do
  def encode(data, type \\ :amf3) do
    case :amf.encode type, data do
      {:ok, encoded} -> {:ok, :erlang.list_to_binary encoded}
      err -> err
    end
  end

  def decode(data, type \\ :amf3) when is_binary(data) do
    :amf.decode type, data
  end
end
