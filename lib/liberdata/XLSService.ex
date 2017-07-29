defmodule Liberdata.XLSService do
  use GenServer
  def start_link() do
    GenServer.start_link __MODULE__, :ok, name: :xls_service
  end

  def init(:ok) do
    port = Port.open({:spawn, "./start_xls_service.sh"}, [:binary])
    Port.connect port, self()
    {:ok, port}
  end
  
  def parse_file(path) do
    out_path = path <> "-out.json"
    res = case GenServer.call(:xls_service, {:parse_file, path}) do
      :ok ->
        case File.read(out_path) do
          {:ok, contents} -> 
            Poison.decode(contents)
          error -> error
        end
      {:err, msg} -> {:err, msg}
    end
    File.rm(out_path)
    res
  end
  
  def handle_call({:parse_file, path}, _from, port) do
    Port.command(port, path <> "\n")
    resp = receive do
      {^port, {:data, "ok\n"}} -> :ok
      {^port, {:data, error_message}} -> {:err, error_message}
    after
      20_000 -> {:err, :timeout}
    end
    {:reply, resp, port}
  end
end
