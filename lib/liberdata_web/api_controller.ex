defmodule LiberdataWeb.ApiController do
  use LiberdataWeb, :controller

  alias Liberdata.{Decoder, Masseuse}

  def decode(conn, _params = %{"url" => url}) do
    json conn, %{url: url}
  end

  def decode_known_type(conn, params = %{"type" => type, "url" => url}) do
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

    resp = case params do
      %{"filter" => filter} -> resp |> Masseuse.apply(filter)
      _ -> resp
    end
    put_status(conn, status)
    |> json(resp)
  end

  def decode_known_type(conn, _params) do
    json conn, %{"error" => "unknown format"}
  end
end
