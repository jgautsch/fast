defmodule Fast.Map do
  @doc """
  Like `Enum.map/2`, but takes a map as the first arg instead of a list, and
  a path of keys down to the list to which the mapping func should be applied.

  ## Example:

      data = %{
        "groups" => [
          %{
            "elements" => [
              %{"type" => "text"}
            ]
          }
        ]
      }

      # Updates all the elements in the data
      Fast.Map.deep_map(data, ["groups", "elements"], fn element ->
        element
        |> Map.put("kind", element["kind"])
        |> Map.delete("type")
      end)
  """
  @spec deep_map(map, nonempty_maybe_improper_list, fun) :: map
  def deep_map(tree, [key], func) do
    new_values = Enum.map(Map.fetch!(tree, key), func)
    Map.put(tree, key, new_values)
  end

  def deep_map(tree, [key | rest], func) do
    new_values = Enum.map(Map.fetch!(tree, key), &deep_map(&1, rest, func))
    Map.put(tree, key, new_values)
  end
end
