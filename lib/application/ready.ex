defmodule Fast.Application.Ready do
  @moduledoc """
  This is a super simple process that will set an env
  value when started (e.g. as the last process in your
  application supervision tree) to indicate the
  application is ready for traffic.

  Put this as the last process in `application.ex`.

  See also: `Fast.Plug.Ready`

  Example usage:

      defmodule MyApp.Application do
        use Application

        def start(_type, _args) do
          children = [
            ...
          ] ++ [{Fast.Application.Ready, otp_app: :my_app}]

          opts = [strategy: :one_for_one, name: MyApp.Supervisor]
          Supervisor.start_link(children, opts)
        end
      end
  """

  use GenServer
  require Logger

  def start_link(otp_app: otp_app) do
    GenServer.start_link(__MODULE__, otp_app, [])
  end

  def init(otp_app) do
    Application.put_env(otp_app, :ready_for_traffic, true)
    Logger.info("[boot] Ready for traffic!")
    {:ok, nil}
  end
end
