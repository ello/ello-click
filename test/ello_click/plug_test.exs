defmodule ElloClick.PlugTest do
  use ExUnit.Case
  use Plug.Test
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney, options: [clear_mock: true]
  alias Plug.Conn

  @amazon_url "https://www.amazon.com/Mountain-Mens-Three-T-Shirt-Medium/dp/B007I4HHX4"
  @affiliated_amazon_url "https://www.amazon.com/Mountain-Mens-Three-T-Shirt-Medium/dp/B007I4HHX4?tag=viglink22575-20"
  @newegg_url "http://www.newegg.com/Product/Product.aspx?Item=N82E16879261644"
  @affiliated_newegg_url "http://www.dpbolvw.net/click-6154407-10446076?sid=iqmowped5e00fbg300053&url=http%3A%2F%2Fwww.newegg.com%2FProduct%2FProduct.aspx%3FItem%3DN82E16879261644"
  @threadless_url "https://www.threadless.com/product/7600/MTN_LP/tab,guys?utm_campaign=27795&utm_medium=affiliate&utm_source=ImpactRadius"
  @affiliated_threadless_url "https://www.threadless.com/product/7600/MTN_LP/tab,guys?clickid=madeupkey&utm_campaign=27795&utm_medium=affiliate&utm_source=ImpactRadius"

  setup do
    teardown_viglink
    teardown_threadless
    :ok
  end

  test "it redirects to ello.co when no path is present" do
    conn = get("")
    assert conn.status == 301
    assert "https://ello.co" in Conn.get_resp_header(conn, "location")
  end

  test "returns url with no changes when threadless key is not present" do
    conn = get(@threadless_url)
    assert conn.status == 301
    assert @threadless_url in Conn.get_resp_header(conn, "location")
  end

  test "returns affiliate threadless url when threadless affiliate id is present" do
    setup_threadless
    conn = get(@threadless_url)
    assert conn.status == 301
    assert @affiliated_threadless_url in Conn.get_resp_header(conn, "location")
  end

  test "does not re-affiliate threadless urls" do
    setup_threadless
    previously_affiliated_url = @threadless_url <> "&clickid=previousaffiliate"
    conn = get(previously_affiliated_url)
    assert conn.status == 301
    refute @affiliated_threadless_url in Conn.get_resp_header(conn, "location")
    assert previously_affiliated_url in Conn.get_resp_header(conn, "location")
  end


  test "returns url with no changes when viglink key is not present" do
    conn = get(@amazon_url)
    assert conn.status == 301
    assert @amazon_url in Conn.get_resp_header(conn, "location")
  end

  test "returns an affiliated link when viglink key is present" do
    setup_viglink
    use_cassette "viglink_amazon", match_request_on: [:query] do
      conn = get(@amazon_url)
      assert conn.status == 301
      assert @affiliated_amazon_url in Conn.get_resp_header(conn, "location")
    end
  end

  test "it handles sending urls with query params to viglink properly" do
    setup_viglink
    use_cassette "viglink_newegg", match_request_on: [:query] do
      conn = get(@newegg_url)
      assert conn.status == 301
      assert @affiliated_newegg_url in Conn.get_resp_header(conn, "location")
    end
  end

  test "it returns 200 okay to /status" do
    conn = get("status")
    assert conn.status == 200
    assert conn.resp_body == "okay"
  end

  test "it gracefully handles invalid urls" do
    setup_viglink
    conn = get("notaurl")
    assert conn.status == 404
    assert conn.resp_body =~ ~r/ello/
    assert conn.resp_body =~ ~r/html/
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

  defp setup_threadless do
    Application.put_env(:ello_click, :threadless, %{ clickid: "madeupkey" })
  end

  defp teardown_threadless do
    Application.put_env(:ello_click, :threadless, %{ clickid: nil })
  end
end
