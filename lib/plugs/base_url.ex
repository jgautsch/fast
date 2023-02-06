defmodule Fast.Plug.BaseUrl do
  @behaviour Plug
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    base_url = get_base_url(conn)
    assign(conn, :base_url, base_url)
  end

  # NB: This is essentially taken from Phoenix.Router.Helpers.url/2
  #     Ref: https://github.com/phoenixframework/phoenix/blob/c8883af5582a38496e4b7e45e05d3a4d759a6caa/lib/phoenix/router/helpers.ex
  defp get_base_url(%Plug.Conn{private: private}) do
    case private do
      %{phoenix_router_url: %URI{} = uri} -> URI.to_string(uri)
      %{phoenix_router_url: url} when is_binary(url) -> url
      %{phoenix_endpoint: endpoint} -> endpoint.url()
    end
  end
end
