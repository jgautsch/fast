# Fast

Build _faster_.

My grab-bag of utilities that I tend to want, but don't want to reimplement for every application I build.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `fast` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:fast, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/fast>.

## Publishing

Update `mix.exs` with a version number.

Run `mix hex.publish`.

## Incorporating into a new app

### `Fast.Application.Ready` & `Fast.Plug.Ready`

GenServer that tracks whether an application is ready for traffic (for use with `Fast.Plug.Ready`).

1. Add `Fast.Application.Ready` as the last child in `application.ex`:

```diff
# lib/myapp/application.ex

defmodule MyApp.Application do
  use Application

  def start(_type, _args) do
    children = [
      ...
-    ]
+    ] ++ [{Fast.Application.Ready, otp_app: :my_app}]

    opts = [strategy: :one_for_one, name: MyApp.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
```

2. Add `Fast.Plug.Ready` to `lib/myapp_web/endpoint.ex`:

```elixir
plug Fast.Plug.Ready, otp_app: :myapp, path: "/readyz"
```

