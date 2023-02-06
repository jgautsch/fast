defmodule Fast.EnumTest do
  use ExUnit.Case, async: true

  describe inspect(&Fast.Enum.pmap/2) do
    test "works like Enum.map/2" do
      assert [2, 4] = Fast.Enum.pmap([1, 2], fn a -> a * 2 end)
    end
  end
end
