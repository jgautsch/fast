defmodule Fast.Absinthe.GraphqlSigil do
  @moduledoc """
  Adds the ~G sigil
  """
  def sigil_G(string, []), do: string
end
