defmodule Fast.PhoneNumbers do
  @moduledoc """
  This is a library for doing things with phone numbers.

  Things like:
    * validation
    * formatting
    * etc.
  """

  defdelegate format(phone_number), to: __MODULE__.Formatter
  defdelegate unformat(phone_number), to: __MODULE__.Formatter
  defdelegate valid?(phone_number), to: __MODULE__.Validator
end
