defmodule ElloClick.Plug do
  use Plug.Builder
  use Honeybadger.Plug
  alias ElloClick.{Validate,Affiliate}

  plug Validate
  plug Affiliate
  plug :redirect

  defp redirect(conn, _opts) do
    send_resp(conn, 301, "")
  end
end
