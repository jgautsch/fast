defmodule Fast.Enum do
  def pmap(collection, func, timeout \\ 5000) do
    collection
    |> Enum.map(&Task.async(fn -> func.(&1) end))
    |> Enum.map(&Task.await(&1, timeout))
  end
end
