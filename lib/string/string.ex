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

  def slugify(nil), do: nil
  def slugify(""), do: ""

  def slugify(str) when is_binary(str) do
    str
    |> String.downcase()
    |> String.trim()
    |> String.replace("&", "and")
    # Replace all spaces with dashes
    |> String.replace(~r/\s+/, "-")
    # Replace all non-alphanumeric (or dash or period) characters with dashes
    |> String.replace(~r/[^a-z0-9-\.]/, "-")
    # Replace all double+ dashes with a single dash
    |> String.replace(~r/-+/, "-")
    # Replace all em-dashes with a single dash
    |> String.replace(~r/—+/, "-")
    # Remove trailing dashes
    |> String.trim_trailing("-")
    # Remove leading dashes
    |> String.trim_leading("-")
  end
end
