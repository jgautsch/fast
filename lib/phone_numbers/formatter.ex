defmodule Fast.PhoneNumbers.Formatter do
  def format(nil), do: nil
  def format(""), do: nil

  def format(phone_number) when is_binary(phone_number) do
    phone_number
    |> unformat()
    |> do_format()
  end

  defp do_format(<<a::binary-3, b::binary-3, c::binary-4>>) do
    "(" <> a <> ") " <> b <> "-" <> c
  end

  defp do_format("+1" <> <<phone::binary-10>>) do
    "+1 " <> do_format(phone)
  end

  defp do_format("1" <> <<phone::binary-10>>) do
    "+1 " <> do_format(phone)
  end

  defp do_format(phone_number) when is_binary(phone_number), do: phone_number

  def unformat(nil), do: nil
  def unformat(""), do: nil

  def unformat(phone_number) when is_binary(phone_number) do
    String.replace(phone_number, ~r/\D/, "")
  end
end
