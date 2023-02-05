defmodule FastTest do
  use ExUnit.Case
  doctest Fast

  test "greets the world" do
    assert Fast.hello() == :world
  end
end
