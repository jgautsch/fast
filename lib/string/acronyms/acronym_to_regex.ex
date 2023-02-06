defmodule Fast.String.Acronyms.ToRegex do
  @moduledoc """
  Module with functions generally used at compile-time
  to create a list of "replacement tuples" used to inflect
  various acronyms.
  """

  def to_replacement_tuple(acronym) when is_binary(acronym) do
    {regex_for_acronym(acronym), acronym}
  end

  def to_replacement_tuple({acronym, replacement}) do
    {regex_for_acronym(acronym), replacement}
  end

  def regex_for_acronym(acronym) do
    acronym
    |> String.downcase()
    |> String.graphemes()
    |> Enum.join("\\.?\\s?")
    |> (&("\\b(" <> &1 <> "\\.?)\\b\\.?")).()
    |> Regex.compile!("\i")
  end
end
