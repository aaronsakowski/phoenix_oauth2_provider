defmodule PhoenixOauth2Provider.ControllerTest do
  use PhoenixOauth2Provider.ConnCase

  alias PhoenixOauth2Provider.Test.Fixtures
  alias Plug.Conn

  setup %{conn: conn} do
    user = Fixtures.user()
    conn = Conn.assign(conn, :current_test_user, user)

    {:ok, conn: conn, user: user}
  end

  test "handles invalid resource owner", %{conn: conn} do
    assert_raise RuntimeError,
                 "Resource owner was not found with :current_test_user assigns",
                 fn ->
                   conn = Conn.assign(conn, :current_test_user, nil)

                   get(conn, Routes.oauth_application_path(conn, :index))
                 end
  end

  test "handles custom web module", %{conn: conn} do
    conn = Conn.put_private(conn, :phoenix_oauth2_provider_config, web_module: DummyWeb)

    conn = get(conn, Routes.oauth_application_path(conn, :index))

    assert html_response(conn, 200)
  end

  describe "application config" do
    setup do
      config = Application.get_env(:phoenix_oauth2_provider, PhoenixOauth2Provider)
      new_config = Keyword.put(config || [], :web_module, DummyWeb)
      Application.put_env(:phoenix_oauth2_provider, PhoenixOauth2Provider, new_config)

      on_exit(fn ->
        Application.put_env(:phoenix_oauth2_provider, PhoenixOauth2Provider, config)
      end)

      :ok
    end

    test "handles custom web module", %{conn: conn} do
      conn = get(conn, Routes.oauth_application_path(conn, :index))
      assert html_response(conn, 200)
    end
  end
end
