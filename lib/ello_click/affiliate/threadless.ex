defmodule ElloClick.Affiliate.Threadless do
  alias ElloClick.Affiliate.Link

  @ello_fake_threadless_affiliate "xrGWivQiB3WN3lVUxIzErxGGUkkz3ESwEVOtXE0"

  # Don't re-affiliate links something further up the chain got
  def affiliate(%Link{is_affiliated: true} = link, _conn), do: link

  def affiliate(%Link{} = link, conn) do
    if config.clickid && should_be_affiliated?(link.original) do
      query = link.original
              |> URI.parse
              |> Map.get(:query)
              |> URI.decode_query
              |> Map.put("clickid", config.clickid)
              |> URI.encode_query
      affiliated = link.original
                   |> URI.merge("?" <> query)
                   |> URI.to_string
      Link.affiliate(link, affiliated)
    else
      link
    end
  end

  defp should_be_affiliated?(url) do
    String.match?(url, ~r/https?:\/\/.*\.threadless\.com.*/) &&
      !String.match?(url, ~r/clickid/)
  end

  defp config do
    Application.get_env(:ello_click, :threadless, %{click_id: nil})
  end
end
