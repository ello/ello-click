defmodule ElloClick.Affiliate do
  alias ElloClick.Affiliate.VigLink
  @behaviour Plug

  def init(opts), do: opts

  def call(conn, _opts) do
    {:ok, url} = affiliate(conn)
    Plug.Conn.put_resp_header(conn, "location", url)
  end

  defp affiliate(conn) do
    conn.assigns.url
    |> skip_ello
    |> skip_vimeo
    |> VigLink.affiliate(conn)
    |> fallback
  end

  defp skip_ello("http://ello.co" <> _ = ello),  do: {:ok, ello}
  defp skip_ello("https://ello.co" <> _ = ello), do: {:ok, ello}
  defp skip_ello(not_ello), do: not_ello

  defp skip_vimeo("http://vimeo" <> _ = vimeo),  do: {:ok, vimeo}
  defp skip_vimeo("https://vimeo" <> _ = vimeo), do: {:ok, vimeo}
  defp skip_vimeo(not_vimeo), do: not_vimeo

  # Ensure we always return {:ok, link}
  defp fallback({:ok, affiliated}), do: {:ok, affiliated}
  defp fallback(unaffiliated), do:      {:ok, unaffiliated}
end
