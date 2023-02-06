defmodule Fast.PhoneNumbers.Validator do
  alias Fast.PhoneNumbers.Formatter

  @spec valid?(nil | String.t()) :: boolean
  def valid?(nil), do: false
  def valid?(""), do: false

  def valid?(phone_number) when is_binary(phone_number) do
    phone_number
    |> Formatter.unformat()
    |> is_valid?()
  end

  def valid?(_phone_number), do: false

  @spec is_valid?(String.t()) :: boolean
  defp is_valid?("1" <> <<_rest::binary-10>>), do: true
  defp is_valid?(<<_phone::binary-10>>), do: true
  defp is_valid?(_phone), do: false
end
