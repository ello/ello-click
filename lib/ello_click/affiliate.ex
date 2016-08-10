defmodule ElloClick.Affiliate do
  alias ElloClick.Affiliate.{VigLink,Link}
  @behaviour Plug

  def init(opts), do: opts

  def call(conn, _opts) do
    link = affiliate(conn)
    Plug.Conn.put_resp_header(conn, "location", link.affiliated)
  end

  defp affiliate(conn) do
    %Link{original: conn.assigns.url}
    |> handle_ello
    |> VigLink.affiliate(conn)
    |> fallback
  end

  defp handle_ello(%Link{is_affiliated: true} = link), do: link
  defp handle_ello(%Link{original: "http://ello.co" <> _} = link),
    do: Link.affiliate(link, link.original)
  defp handle_ello(%Link{original: "https://ello.co" <> _} = link),
    do: Link.affiliate(link, link.original)
  defp handle_ello(%Link{original: "https://ello.ninja" <> _} = link),
    do: Link.affiliate(link, link.original)
  defp handle_ello(%Link{} = link), do: link

  defp fallback(%Link{is_affiliated: true} = link), do: link
  defp fallback(link), do: Link.affiliate(link, link.original)
end
