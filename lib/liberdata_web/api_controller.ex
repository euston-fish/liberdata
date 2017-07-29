defmodule LiberdataWeb.ApiController do
  use LiberdataWeb, :controller

  alias Liberdata.{Decoder}

  def decode(conn, _params = %{"url" => url}) do
    json conn, %{url: url}
  end

  def decode_known_type(conn, %{"type" => type, "url" => url}) do
    {status, resp} = Decoder.decode(url, type)
    |> case do
      {:ok, stream} ->
        {200, stream}
      {:err, message} ->
        resp = %{
          "error" => message
        }
        {500, resp}
    end
    put_status(conn, status)
    |> json(resp)
  end

  def decode_known_type(conn, _params) do
    json conn, %{"error" => "unknown format"}
  end
end
