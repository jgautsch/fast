defmodule Fast.Absinthe.ExtractPossibleTypes do
  @query """
  query {
    __schema {
      types {
        kind
        name
        possibleTypes {
          name
        }
      }
    }
  }
  """

  @doc """
  Extract GraphQL possible types to support result validation and
  accurate fragment matching on unions and interfaces.

  More info here: https://www.apollographql.com/docs/react/data/fragments/#defining-possibletypes-manually

  Example usage in a mix task:

      defmodule Mix.Tasks.ExtractPossibleTypes do
        use Mix.Task
        alias Fast.Absinthe.ExtractPossibleTypes
        alias Fast.Application.Schema
        require Logger

        @shortdoc "Extract GraphQL possible types"
        def run([schema_name, output_path]) do
          Logger.info("Extracting possible types...")
          schema =
            case schema_name do
              "api" -> Schema.Api
              "admin" -> Schema.Admin
            end

          json =
            schema
            |> ExtractPossibleTypes.run()
            |> Jason.encode!()

          File.write!(output_path, json)
          Logger.info("Done! (possible types written to " <> output_path <> ")")
        end
      end
  """
  def run(schema) do
    {:ok, %{data: %{"__schema" => %{"types" => types}}}} = Absinthe.run(@query, schema)

    transform(types)
  end

  defp transform(types) do
    for supertype <- types, reduce: %{} do
      acc ->
        if is_list(supertype["possibleTypes"]) && length(supertype["possibleTypes"]) do
          type_names = for type <- supertype["possibleTypes"], do: type["name"]
          Map.put(acc, supertype["name"], type_names)
        else
          acc
        end
    end
  end
end
