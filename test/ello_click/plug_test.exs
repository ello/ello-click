defmodule ElloClick.PlugTest do
  use ExUnit.Case
  use Plug.Test
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney, options: [clear_mock: true]
  alias Plug.Conn

  @amazon_url "https://www.amazon.com/Mountain-Mens-Three-T-Shirt-Medium/dp/B007I4HHX4"
  @affiliated_amazon_url "https://www.amazon.com/Mountain-Mens-Three-T-Shirt-Medium/dp/B007I4HHX4?tag=viglink22575-20"

  test "returns url with no changes when viglink key is not present" do
    conn = get(@amazon_url)
    assert conn.status == 301
    assert @amazon_url in Conn.get_resp_header(conn, "location")
  end

  test "returns an affiliated link when viglink key is present" do
    use_cassette "viglink_amazon", match_request_on: [:query] do
      setup_viglink
      conn = get(@amazon_url)
      assert conn.status == 301
      assert @affiliated_amazon_url in Conn.get_resp_header(conn, "location")
      teardown_viglink
    end
  end

  @opts ElloClick.Plug.init([])
  defp get(path, referer \\ "https://ello.co/") do
    conn(:get, "http://click.ello.co/" <> path)
    |> put_req_header("referer", referer)
    |> ElloClick.Plug.call(@opts)
  end

  defp setup_viglink do
    Application.put_env(:ello_click, :viglink, %{
      url: Application.get_env(:ello_click, :viglink).url,
      key: "88ac2a40e081e283ac504d1789d398ac", # Key from viglink public docs
    })
  end

  defp teardown_viglink do
    Application.put_env(:ello_click, :viglink, %{
      url: Application.get_env(:ello_click, :viglink).url,
      key: nil,
    })
  end
end
