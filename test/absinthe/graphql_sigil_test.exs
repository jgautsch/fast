defmodule Fast.Absinthe.GraphqlSigilTest do
  use ExUnit.Case
  import Fast.Absinthe.GraphqlSigil

  @query ~G"""
  query test($token: String!) {
    user {
      name
    }
  }
  """

  test "it preserves the string" do
    assert @query == """
           query test($token: String!) {
             user {
               name
             }
           }
           """
  end
end
