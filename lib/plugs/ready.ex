defmodule Fast.Plug.Ready do
  @behaviour Plug
  import Plug.Conn

  @default_path "/readyz"

  @moduledoc """
  A plug for responding to "ready" check requests.

  This plug responds with "200 YES" when ready, "423 NO" otherwise.
  It checks the `:ready_for_traffic` env var to determine
  if the application is ready for traffic.

  ## Options

    * `:otp_app` - app name that the config belongs to
    * `:path` - request path string to handle requests for
    * `:json` - a boolean to decide whether response should be json

  ## Examples

    defmodule MyServer do
      use Plug.Builder
      plug Fast.Plug.Ready

      # ... rest of the pipeline
    end

  Using a custom path:

    defmodule MyServer do
      use Plug.Builder
      plug Fast.Plug.Ready, otp_app: :my_app, path: "/ready"


      # ... rest of the pipeline
    end

  """

  defmodule MissingOption do
    defexception [:message]
  end

  def init(opts) do
    case Keyword.get(opts, :otp_app) do
      app when is_atom(app) ->
        Keyword.merge([path: @default_path, json: false], opts)

      nil ->
        raise MissingOption, message: "`:otp_app` is a required option for Fast.Plug.Ready"
    end
  end

  def call(%Plug.Conn{} = conn, opts) do
    if conn.request_path == opts[:path] and conn.method in ~w(GET HEAD) do
      conn |> halt |> send_ready(opts[:otp_app], opts[:json])
    else
      conn
    end
  end

  defp send_ready(conn, otp_app, false = _json) do
    status = http_status(otp_app)

    body =
      case ready?(otp_app) do
        true -> "YES"
        false -> "NO"
      end

    send_resp(conn, status, body)
  end

  defp send_ready(conn, otp_app, true = _json) do
    status = http_status(otp_app)
    json = Jason.encode!(%{ready: ready?(otp_app)})

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status, json)
  end

  defp http_status(otp_app) do
    case ready?(otp_app) do
      true -> 200
      # NB: 423 == "Locked"
      false -> 423
    end
  end

  defp ready?(otp_app) do
    Application.get_env(otp_app, :ready_for_traffic, false)
  end
end
