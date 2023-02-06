defmodule Fast.String.Acronyms.Addresses do
  @address_acronyms [
                      "US",
                      "PO Box",
                      {"Ste", "Suite"},
                      "N",
                      "E",
                      "S",
                      "W",
                      {"Ne", "NE"},
                      {"Nw", "NW"},
                      {"Se", "SE"},
                      {"Sw", "SW"},
                      "Rd",
                      {"Road", "Rd"},
                      "St",
                      {"Street", "St"},
                      "Dr",
                      {"Drive", "Dr"},
                      "Ave",
                      {"Avenue", "Ave"},
                      "Pkwy",
                      {"Parkway", "Pkwy"},
                      "Blvd",
                      {"Boulevard", "Blvd"},
                      "Ln",
                      {"Lane", "Ln"},
                      "Ct",
                      {"Hwy", "Highway"}
                    ]
                    |> Enum.map(&Fast.String.Acronyms.ToRegex.to_replacement_tuple/1)

  def address_acronyms do
    @address_acronyms
  end
end
