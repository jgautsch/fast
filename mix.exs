defmodule Fast.MixProject do
  use Mix.Project

  @name "Fast"
  @version "0.2.0"
  @repo_url "https://github.com/jgautsch/fast"

  def project do
    [
      app: :fast,
      version: @version,
      elixir: "~> 1.14",
      description: "A grab bag of utilities I tend to want, so I can build faster.",
      start_permanent: Mix.env() == :prod,
      package: package(),
      docs: docs(),
      name: @name,
      source_url: @repo_url,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:absinthe, "~> 1.7"},
      {:bcrypt_elixir, "~> 3.0"},
      {:ecto, "~> 3.9"},
      {:ecto_sql, "~> 3.9"},
      {:ex_rated, "~> 2.1"},
      {:geo_postgis, "~> 3.4"},
      {:httpoison, "~> 2.0"},
      {:jason, "~> 1.4"},
      {:logger_json, "~> 5.1"},
      {:plug, "~> 1.14"},
      {:timex, "~> 3.7"},
      {:tzdata, "~> 1.1"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  def package do
    [
      maintainers: ["Jon Gautsch"],
      licenses: ["MIT"],
      links: %{"GitHub" => @repo_url}
    ]
  end

  def docs do
    [
      main: "readme",
      source_ref: "v#{@version}",
      source_url: @repo_url
    ]
  end
end
