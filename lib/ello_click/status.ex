defmodule ElloClick.Status do
  @behaviour Plug
  import Plug.Conn

  def init(opts), do: opts

  @doc """
  Send 200 "okay" if path starts with /status. Everything else pass through.
  """
  def call(%{path_info: ["status" | _ ]} = conn, _) do
    halt send_resp(conn, 200, "okay")
  end
  def call(conn, _opts), do: conn
end
