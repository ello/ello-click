defmodule ElloClick.Affiliate.Link do
  defstruct [original: nil, affiliated: nil, is_affiliated: false]

  def affiliate(link, url) do
    link
    |> Map.put(:affiliated, url)
    |> Map.put(:is_affiliated, true)
  end
end
