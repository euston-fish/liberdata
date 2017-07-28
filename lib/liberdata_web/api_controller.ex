defmodule LiberdataWeb.ApiController do
  use LiberdataWeb, :controller

  def decode(conn, _params = %{"url" => url}) do
    json conn, %{url: url}
  end
end
