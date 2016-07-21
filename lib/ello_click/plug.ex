defmodule ElloClick.Plug do
  use Plug.Builder
  use Honeybadger.Plug
  alias ElloClick.Affiliate

  plug Affiliate
  plug :redirect

  def redirect(conn, _opts) do
    send_resp(conn, 301, "")
  end
end
