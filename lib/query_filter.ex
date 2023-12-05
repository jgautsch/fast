defmodule Fast.QueryFilter do
  defguard is_blank(filter_value) when filter_value in [nil, "", [], "ANY", "ALL"]
end
