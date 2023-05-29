defmodule Fast.Absinthe.GraphqlFormatterTest do
  use ExUnit.Case

  @query """
  query test($token: String!) {
    user {
          name          }
  }
  """

  test "formats graphql queries" do
    assert Fast.Absinthe.GraphqlFormatter.features([]) == [sigils: [:G], extensions: []]

    assert Fast.Absinthe.GraphqlFormatter.format(@query) ==
             "query test($token: String!) {\n  user {\n    name\n  }\n}\n"
  end
end
