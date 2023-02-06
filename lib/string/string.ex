defmodule Fast.String do
  defdelegate inflect_address_acronyms(str), to: __MODULE__.Acronyms
  defdelegate inflect_title_acronyms(str), to: __MODULE__.Acronyms

  def titlecase(nil), do: nil
  def titlecase(""), do: ""

  def titlecase(str) when is_binary(str) do
    # First downcase and capitalize the first character of the string.
    str =
      str
      |> String.downcase()
      |> String.capitalize()

    # Then capitalize any letter following one of these delimeters:
    # \s \n _ - \t & . , /
    Regex.replace(~r/([\s\n_\-\t&\.,\/]{1}[A-Za-z]{1})/, str, fn _,
                                                                 <<delimeter::binary-1,
                                                                   char::binary-1>> ->
      delimeter <> String.capitalize(char)
    end)
  end
end
