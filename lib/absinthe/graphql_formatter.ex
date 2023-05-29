defmodule Fast.Absinthe.GraphqlFormatter do
  @behaviour Mix.Tasks.Format

  def features(_opts) do
    [sigils: [:G], extensions: []]
  end

  def format(contents, _opts \\ []) do
    Absinthe.Formatter.format(contents)
  end
end
