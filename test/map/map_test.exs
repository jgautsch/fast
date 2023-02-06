defmodule Fast.MapTest do
  use ExUnit.Case, async: true

  describe inspect(&Fast.Map.deep_map/3) do
    test "maps values deeply inside the object" do
      original = %{
        "groups" => [
          %{
            "elements" => [
              %{"type" => "1"},
              %{"type" => "2"}
            ]
          },
          %{
            "elements" => [
              %{"type" => "3"}
            ]
          },
          %{"elements" => []}
        ]
      }

      expected = %{
        "groups" => [
          %{
            "elements" => [
              %{"kind" => "1"},
              %{"kind" => "2"}
            ]
          },
          %{
            "elements" => [
              %{"kind" => "3"}
            ]
          },
          %{"elements" => []}
        ]
      }

      func = fn element ->
        element
        |> Map.put("kind", element["type"])
        |> Map.delete("type")
      end

      assert expected == Fast.Map.deep_map(original, ["groups", "elements"], func)
    end
  end
end
