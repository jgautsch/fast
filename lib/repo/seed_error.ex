defmodule Fast.Repo.SeedError do
  defexception [:message]

  def exception(%{message: message}) do
    %__MODULE__{message: message}
  end
end
