defmodule Fast.AssignTest do
  use ExUnit.Case

  # Module under test
  alias Fast.Assign

  defmodule Dog do
    defstruct [:name]
  end

  describe inspect(&Fast.Assign.assign/3) do
    test "with a key and value" do
      assert %{some: "value"} == Assign.assign(%{}, :some, "value")
    end

    test "with a nested path" do
      state = %{data: %{}}
      assert %{data: %{key: "value"}} == Assign.assign(state, [:data, :key], "value")
    end

    test "works with structs" do
      dog = %Dog{}
      assert %Dog{name: "mango"} == Assign.assign(dog, :name, "mango")
    end
  end

  describe inspect(&Fast.Assign.assign/2) do
    test "puts the value in" do
      assert %{some: "value"} == Assign.assign(%{}, some: "value")
    end

    test "works with structs" do
      dog = %Dog{}
      assert %Dog{name: "mango"} == Assign.assign(dog, name: "mango")
    end
  end
end
