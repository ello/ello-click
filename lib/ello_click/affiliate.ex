defmodule ElloClick.Affiliate do
  alias ElloClick.Affiliate.VigLink
  @behaviour Plug

  def init(opts), do: opts

  def call(conn, _opts) do
    {:ok, url} = affiliate(conn)
    Plug.Conn.put_resp_header(conn, "location", url)
  end

  defp affiliate(conn) do
    conn
    |> full_url
    |> clean
    |> VigLink.affiliate(conn)
    |> fallback
  end

  # Include query params if url has them
  defp full_url(%{request_path: path, query_string: nil}), do: path
  defp full_url(%{request_path: path, query_string: ""}),  do: path
  defp full_url(%{request_path: path, query_string: q}),   do: path <> "?" <> q

  # Strip leading slash
  defp clean("/"),        do: {:ok, "https://ello.co"}
  defp clean(""),         do: {:ok, "https://ello.co"}
  defp clean("/" <> url), do: url
  defp clean(url),        do: url

  # Ensure we always return {:ok, link}
  defp fallback({:ok, affiliated}), do: {:ok, affiliated}
  defp fallback(unaffiliated), do:      {:ok, unaffiliated}
end
