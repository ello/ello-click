defmodule ElloClick.Plug do
  use Plug.Builder
  alias ElloClick.Affiliate

  plug Affiliate
  plug :redirect

  def redirect(conn, _opts) do
    send_resp(conn, 301, "")
  end
end
