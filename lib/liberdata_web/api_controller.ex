defmodule LiberdataWeb.ApiController do
  use LiberdataWeb, :controller

  alias Liberdata.{Applicator}

  def decode(conn, _params = %{"commands" => commands}) do
    {status, resp} = Applicator.apply(commands) |> case do
      {:ok, resp} -> {200, resp}
      {:err, message} -> {500, %{error: message}}
      _ -> {500, %{error: "cri"}}
    end

    conn
    |> put_status(status)
    |> json(resp)
  end
end
