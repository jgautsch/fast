defmodule Fast.Assign do
  @moduledoc """
  Tiny helper module to allow conn-like `assign` into a Map or struct.
  """

  def assign(%{} = state, key, value) when is_atom(key) do
    Map.put(state, key, value)
  end

  def assign(%{} = state, key, value) when is_list(key) do
    put_in(state, key, value)
  end

  def assign(%{} = state, [{key, value}]) when is_atom(key) do
    Map.put(state, key, value)
  end
end
