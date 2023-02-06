defmodule FastWeb.Schema.CustomTypes do
  use Absinthe.Schema.Notation

  @moduledoc """
  This module contains the following data types:
  - input_error
  - datetime
  - date
  - time
  - uuid4

  Further description of these types can be found in the source code.

  To use: `import_types FastWeb.Schema.CustomTypes`

  This is a modified version of: https://github.com/absinthe-graphql/absinthe/blob/be199215ad52050ed5a12b7c5af6cfaae329252c/lib/absinthe/type/custom.ex
  """

  @desc "An error encountered trying to persist input"
  object :input_error do
    field :key, non_null(:string)
    field :message, non_null(:string)
  end

  scalar :datetime, name: "DateTime" do
    description """
    The `DateTime` scalar type represents a date and time.
    The DateTime appears in a JSON response as an ISO8601 formatted
    string, including UTC timezone("Z").
    """

    serialize &serialize_datetime/1
    parse &parse_datetime/1
  end

  scalar :date do
    description """
    The `Date` scalar type represents a date. The Date appears in a JSON
    response as an ISO8601 formatted string.
    """

    serialize &Date.to_iso8601/1
    parse &parse_date/1
  end

  scalar :time do
    description """
    The `Time` scalar type represents a time. The Time appears in a JSON
    response as an ISO8601 formatted string.
    """

    serialize &Time.to_iso8601/1
    parse &parse_time/1
  end

  scalar :uuid4, name: "UUID4" do
    description """
    The `UUID4` scalar type represents UUID4 compliant string data, represented
    as UTF-8 character sequences. The UUID4 type is most often used to represent
    unique human-readable ID strings.
    """

    serialize &encode_uuid/1
    parse &decode_uuid/1
  end

  object :point do
    description """
    This turns a Geo.PostGIS.Geometry (Geo.Point) into a format we'll expect in JS land.
    Geo.Point looks like this:

        %Geo.Point{
          coordinates: {-66.749961, 18.180555},
          properties: %{},
          srid: 4326
        }

    and we want it to look like this for JS:

        {lat: float, lng: float}

    """

    field :lat, non_null(:float) do
      resolve fn geom, _, _ ->
        %{coordinates: {_lng, lat}} = geom
        {:ok, lat}
      end
    end

    field :lng, non_null(:float) do
      resolve fn geom, _, _ ->
        %{coordinates: {lng, _lat}} = geom
        {:ok, lng}
      end
    end
  end

  input_object :point_input do
    field :lat, non_null(:float)
    field :lng, non_null(:float)
  end

  object :phone_number do
    description """
    The `PhoneNumber` object type represents a phone number. The PhoneNumber
    appears in a JSON response with fields `formatted` and `raw`.
    """

    field :formatted, :string do
      resolve fn phone_number, _, _ ->
        {:ok, Fast.PhoneNumbers.format(phone_number)}
      end
    end

    field :raw, :string do
      resolve fn phone_number, _, _ ->
        case phone_number do
          nil ->
            {:ok, nil}

          "" ->
            {:ok, nil}

          phone_number when is_binary(phone_number) ->
            {:ok, phone_number}
        end
      end
    end
  end

  scalar :json, name: "Json" do
    description """
    The `Json` scalar type represents arbitrary json string data, represented as UTF-
    character sequences. The Json type is most often used to represent a free-form
    human-readable json string.
    """

    serialize &encode_json/1
    parse &decode_json/1
  end

  @spec parse_datetime(Absinthe.Blueprint.Input.String.t()) :: {:ok, DateTime.t()} | :error
  @spec parse_datetime(Absinthe.Blueprint.Input.Null.t()) :: {:ok, nil}
  defp parse_datetime(%Absinthe.Blueprint.Input.String{value: value}) do
    case Timex.Parse.DateTime.Parser.parse(
           value,
           "{ISO:Extended}",
           Timex.Parse.DateTime.Tokenizers.Default
         ) do
      {:ok, datetime} -> {:ok, datetime}
      _error -> :error
    end
  end

  defp parse_datetime(%Absinthe.Blueprint.Input.Null{}) do
    {:ok, nil}
  end

  defp parse_datetime(_) do
    :error
  end

  defp serialize_datetime(%DateTime{} = datetime), do: DateTime.to_iso8601(datetime)

  defp serialize_datetime(%NaiveDateTime{} = dt) do
    dt
    |> DateTime.from_naive!("Etc/UTC")
    |> serialize_datetime
  end

  @spec parse_date(Absinthe.Blueprint.Input.String.t()) :: {:ok, Date.t()} | :error
  @spec parse_date(Absinthe.Blueprint.Input.Null.t()) :: {:ok, nil}
  defp parse_date(%Absinthe.Blueprint.Input.String{value: value}) do
    case Date.from_iso8601(value) do
      {:ok, date} -> {:ok, date}
      _error -> :error
    end
  end

  defp parse_date(%Absinthe.Blueprint.Input.Null{}) do
    {:ok, nil}
  end

  defp parse_date(_) do
    :error
  end

  @spec parse_time(Absinthe.Blueprint.Input.String.t()) :: {:ok, Time.t()} | :error
  @spec parse_time(Absinthe.Blueprint.Input.Null.t()) :: {:ok, nil}
  defp parse_time(%Absinthe.Blueprint.Input.String{value: value}) do
    case Time.from_iso8601(value) do
      {:ok, time} -> {:ok, time}
      _error -> :error
    end
  end

  defp parse_time(%Absinthe.Blueprint.Input.Null{}) do
    {:ok, nil}
  end

  defp parse_time(_) do
    :error
  end

  defp encode_uuid(value), do: value

  @spec decode_uuid(Absinthe.Blueprint.Input.String.t()) :: {:ok, term()} | :error
  @spec decode_uuid(Absinthe.Blueprint.Input.Null.t()) :: {:ok, nil}
  defp decode_uuid(%Absinthe.Blueprint.Input.String{value: value}) do
    Ecto.UUID.cast(value)
  end

  defp decode_uuid(%Absinthe.Blueprint.Input.Null{}) do
    {:ok, nil}
  end

  defp decode_uuid(_) do
    :error
  end

  @spec decode_json(Absinthe.Blueprint.Input.String.t()) :: {:ok, term()} | :error
  @spec decode_json(Absinthe.Blueprint.Input.Null.t()) :: {:ok, nil}
  defp decode_json(%Absinthe.Blueprint.Input.String{value: value}) do
    case Jason.decode(value) do
      {:ok, result} -> {:ok, result}
      _ -> :error
    end
  end

  defp decode_json(%Absinthe.Blueprint.Input.Null{}) do
    {:ok, nil}
  end

  defp decode_json(_) do
    :error
  end

  defp encode_json(value) when is_map(value), do: Jason.encode!(value)

  defp encode_json(value), do: value
end
