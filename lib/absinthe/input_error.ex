defmodule Fast.Absinthe.InputError do
  @moduledoc """
  A struct representing an input error.
  """
  defstruct [:key, :message]

  @spec new(binary) :: %__MODULE__{key: binary, message: binary}
  def new(message) when is_binary(message) do
    new("", message)
  end

  @spec new(binary, binary) :: %__MODULE__{key: binary, message: binary}
  def new(key, message) when is_binary(key) and is_binary(message) do
    %__MODULE__{
      key: key,
      message: message
    }
  end
end
