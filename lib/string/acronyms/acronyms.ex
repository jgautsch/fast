defmodule Fast.String.Acronyms do
  def inflect_title_acronyms(str) do
    inflect_acronyms(__MODULE__.Titles.title_acronyms(), str)
  end

  def inflect_address_acronyms(str) do
    inflect_acronyms(__MODULE__.Addresses.address_acronyms(), str)
  end

  defp inflect_acronyms(_acronym_tuples, nil), do: nil
  defp inflect_acronyms(_acronym_tuples, ""), do: ""

  defp inflect_acronyms(acronym_tuples, str) do
    Enum.reduce(acronym_tuples, str, &do_inflect/2)
  end

  defp do_inflect({regex, replacement}, str) do
    String.replace(str, regex, replacement)
  end
end
