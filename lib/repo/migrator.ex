defmodule Fast.Repo.Migrator do
  use GenServer
  require Logger

  @moduledoc """
  Runs migrations on startup.
  Taken from: https://elixirforum.com/t/what-is-your-strategy-for-running-one-off-and-automated-tasks-using-releases-no-mix/27347

  Opts:

    * `:repo` - Required. The repo module to migrate.
    * `:migrations_path` - Optional. Relative dir containing migrations.
  """

  @default_migrations_path "priv/repo/migrations"

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, [])
  end

  def init(opts) do
    migrate!(opts)
    {:ok, nil}
  end

  def migrate!(opts) do
    otp_app = Keyword.fetch!(opts, :otp_app)
    migrations_path = Keyword.get(opts, :migrations_path, @default_migrations_path)
    repo = Keyword.fetch!(opts, :repo)

    path = Application.app_dir(otp_app, migrations_path)

    Ecto.Migrator.run(repo, path, :up, all: true)
  end
end
