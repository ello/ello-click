defmodule ElloClick.Affiliate.VigLink do
  alias Plug.Conn

  # Don't re-affiliate links something further up the chain got
  def affiliate({:ok, affiliated}), do: {:ok, affiliated}

  def affiliate(unaffiliated, conn) do
    call_api(config.key, unaffiliated, referer(conn))
  end

  # No API key
  defp call_api(nil, out, _location), do: {:ok, out}

  # Have API key
  defp call_api(key, out, location) do
    params = [
      format: "txt",
      key: key,
      loc: location,
      out: out
    ]
    case HTTPoison.get(config.url, [], params: params) do
      {:ok, %{body: body}} -> {:ok, body} # Successfull api response
      _                    -> {:ok, out}  # Failed - just return original link
    end
  end

  defp config do
    Application.get_env(:ello_click, :viglink, %{})
  end

  # Find referer from conn, if not present just use ello.co
  defp referer(conn) do
    case Conn.get_req_header(conn, "referer") do
      [referer | _] -> referer
      _             -> "https://ello.co"
    end
  end
end
