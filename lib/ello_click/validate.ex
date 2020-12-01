defmodule ElloClick.Validate do
  use Plug.Builder

  plug :parse_url
  plug :validate_url

  @doc """
  Parse desination url from path, assign to conn.

  Clean up extra slashes, include any query params etc.
  """
  def parse_url(conn, _opts) do
    url = conn
          |> extract_url
          |> clean_url
    assign(conn, :url, url)
  end

  @doc """
  Validate parsed url, if invalid render 404 and halt.
  """
  def validate_url(conn, _opts) do
    case URI.parse(conn.assigns.url) do
      %URI{scheme: nil} -> render_404(conn)
      %URI{host: nil}   -> render_404(conn)
      _                 -> conn
    end
  end

  # Include query params if url has them
  defp extract_url(%{request_path: path, query_string: nil}), do: path
  defp extract_url(%{request_path: path, query_string: ""}),  do: path
  defp extract_url(%{request_path: path, query_string: q}),   do: path <> "?" <> q

  defp clean_url("/https://u.to/" <> _), do: "https://ello.co" # BAD url -> ello.co
  defp clean_url("/"),        do: "https://ello.co" # No url -> ello.co
  defp clean_url(""),         do: "https://ello.co" # No url -> ello.co
  defp clean_url("/" <> url), do: url # Strip leading slash
  defp clean_url(url),        do: url

  defp render_404(conn) do
    halt send_file(conn, 404, "priv/static/404.html")
  end
end
