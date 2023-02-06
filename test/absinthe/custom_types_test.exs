defmodule FastWeb.Schema.CustomTypesTest do
  use ExUnit.Case, async: true

  alias FastWeb.Schema
  alias Absinthe.Type
  alias Absinthe.Blueprint.Input

  defmodule TestSchema do
    use Absinthe.Schema
    import_types(Schema.CustomTypes)

    query do
      field :ping, :string do
        resolve(fn _, _, _ -> {:ok, "pong"} end)
      end
    end
  end

  @date_tuple {2018, 10, 31}
  # 8:30 am and 55 seconds
  @time_tuple {8, 30, 55}
  @time_zone_name "US/Central"
  @datetime Timex.to_datetime({@date_tuple, @time_tuple}, @time_zone_name)
  # ~D[2018-10-31]
  @date Timex.to_date(@date_tuple)
  @time ~T[08:30:55]

  defp serialize(type, value) do
    TestSchema.__absinthe_type__(type)
    |> Type.Scalar.serialize(value)
  end

  def parse(type, value) do
    TestSchema.__absinthe_type__(type)
    |> Type.Scalar.parse(value)
  end

  describe ":datetime" do
    test "serializes as an ISO8601 date and time string with a non-zero UTC offset" do
      assert "2018-10-31T08:30:55-05:00" == serialize(:datetime, @datetime)
    end

    test "can be parsed from an ISO8601 date and time string with a non-zero UTC offset" do
      {:ok, dt1} = parse(:datetime, %Input.String{value: "2018-10-31T08:30:55-05:00"})
      {:ok, dt2} = parse(:datetime, %Input.String{value: "2018-10-31 08:30:55-05:00"})
      # NB: This case/string is the result of JS `dateFns.format(d)`
      {:ok, dt3} = parse(:datetime, %Input.String{value: "2018-10-31T06:30:55.000-07:00"})
      assert dt1 == dt2
      assert Timex.equal?(dt1, @datetime)
      assert Timex.equal?(dt2, @datetime)
      assert Timex.equal?(dt3, @datetime)
    end

    test "can be parsed from an ISO8601 date tand time string without a UTC offset" do
      {:ok, dt} = parse(:datetime, %Input.String{value: "2018-10-31T13:30:55Z"})
      assert Timex.equal?(dt, @datetime)
    end

    test "can be parsed from an ISO8601 date and time string including zero UTC offset" do
      {:ok, dt} = parse(:datetime, %Input.String{value: "2018-10-31T13:30:55+00:00"})
      assert Timex.equal?(dt, @datetime)
    end

    test "parses as UTC when a UTC timezone marker isn't present" do
      assert {:ok, dt1} = parse(:datetime, %Input.String{value: "2018-10-31T13:30:55"})
      assert {:ok, dt2} = parse(:datetime, %Input.String{value: "2018-10-31 13:30:55"})
      assert Timex.equal?(dt1, @datetime)
      assert Timex.equal?(dt2, @datetime)
    end

    test "cannot be parsed when date or time is missing" do
      assert :error == parse(:datetime, %Input.String{value: "2017-01-27"})
      assert :error == parse(:datetime, %Input.String{value: "20:31:55"})
    end

    test "cannot be parsed from a binary not formatted according to ISO8601" do
      assert :error == parse(:datetime, %Input.String{value: "abc123"})
      assert :error == parse(:datetime, %Input.String{value: "01/25/2017 20:31:55"})
      assert :error == parse(:datetime, %Input.String{value: "2017-15-42T31:71:95Z"})
    end
  end

  describe ":date" do
    test "serializes as an ISO8601 date string" do
      assert "2018-10-31" == serialize(:date, @date)
    end

    test "can be parsed from an ISO8601 date string" do
      assert {:ok, @date} == parse(:date, %Input.String{value: "2018-10-31"})
    end

    test "cannot be parsed when time is included" do
      assert :error == parse(:date, %Input.String{value: "2018-10-31T13:30:55Z"})
      assert :error == parse(:date, %Input.String{value: "2018-10-31 13:30:55Z"})
      assert :error == parse(:date, %Input.String{value: "2018-10-31 13:30:55"})
    end

    test "cannot be parsed when date is missing" do
      assert :error == parse(:date, %Input.String{value: "13:30:55"})
    end

    test "cannot be parsed from a binary not formatted according to ISO8601" do
      assert :error == parse(:date, %Input.String{value: "abc123"})
      assert :error == parse(:date, %Input.String{value: "10/31/2018 13:30:55"})
      assert :error == parse(:date, %Input.String{value: "2018-15-42T31:71:95Z"})
    end
  end

  describe ":time" do
    test "serializes as an ISO8601 time string" do
      assert "08:30:55" == serialize(:time, @time)
    end

    test "can be parsed from an ISO8601 date string" do
      assert {:ok, @time} == parse(:time, %Input.String{value: "08:30:55"})
    end

    test "cannot be parsed when date is included" do
      assert :error == parse(:time, %Input.String{value: "2018-10-31T13:30:55Z"})
      assert :error == parse(:time, %Input.String{value: "2018-10-31 13:30:55Z"})
      assert :error == parse(:time, %Input.String{value: "2018-10-31 13:30:55"})
    end

    test "cannot be parsed when time is missing" do
      assert :error == parse(:time, %Input.String{value: "2018-10-31"})
    end

    test "cannot be parsed from a binary not formatted according to ISO8601" do
      assert :error == parse(:time, %Input.String{value: "abc123"})
      assert :error == parse(:time, %Input.String{value: "10/31/2018 13:30:55"})
      assert :error == parse(:time, %Input.String{value: "2018-15-42T31:71:95Z"})
    end
  end

  describe ":uuid4" do
    test "serializes a UUID" do
      assert "7587ae8a-9b9f-4bcc-939e-4ddfc8c8a6ab" ==
               serialize(:uuid4, "7587ae8a-9b9f-4bcc-939e-4ddfc8c8a6ab")
    end

    test "serializes nil" do
      assert nil == serialize(:uuid4, nil)
    end

    test "parses a UUID" do
      assert {:ok, "7587ae8a-9b9f-4bcc-939e-4ddfc8c8a6ab"} ==
               parse(:uuid4, %Input.String{value: "7587ae8a-9b9f-4bcc-939e-4ddfc8c8a6ab"})
    end

    test "parses null value" do
      assert {:ok, nil} == parse(:uuid4, %Input.Null{})
    end

    test "fails to parse a non-uuid" do
      assert :error == parse(:uuid4, %Input.String{value: "7587ae8a-9b9f-4bcc-939e"})
    end
  end

  describe ":point" do
    test "defines lat & lng fields a %Geo.Point{}" do
      obj = TestSchema.__absinthe_type__(:point)

      assert %Absinthe.Type.Field{name: "lat", type: %Absinthe.Type.NonNull{of_type: :float}} =
               obj.fields.lat

      assert %Absinthe.Type.Field{name: "lng", type: %Absinthe.Type.NonNull{of_type: :float}} =
               obj.fields.lng
    end

    test "serializes a %Geo.Point{}" do
      defmodule GeoSchema do
        use Absinthe.Schema
        import_types(Schema.CustomTypes)

        query do
          field :point, :point
        end
      end

      point = %Geo.Point{
        coordinates: {-66.749961, 18.180555},
        properties: %{},
        srid: 4326
      }

      root_data = %{point: point}
      query = "{ point { lat lng } }"

      assert {:ok, %{data: %{"point" => %{"lat" => 18.180555, "lng" => -66.749961}}}} ==
               Absinthe.run(query, GeoSchema, root_value: root_data)
    end
  end

  describe ":point_input" do
    test "defines lat & lng fields as input keys" do
      obj = TestSchema.__absinthe_type__(:point_input)

      assert %Absinthe.Type.Field{name: "lat", type: %Absinthe.Type.NonNull{of_type: :float}} =
               obj.fields.lat

      assert %Absinthe.Type.Field{name: "lng", type: %Absinthe.Type.NonNull{of_type: :float}} =
               obj.fields.lng
    end
  end

  describe ":json" do
    test "serializes a Map" do
      assert ~s({"test":["json",{"other":"thing","value":2}]}) ==
               serialize(:json, %{test: ["json", %{value: 2, other: "thing"}]})

      assert ~s({"test":["json",{"other":"thing","value":2}]}) ==
               serialize(:json, %{"test" => ["json", %{"value" => 2, "other" => "thing"}]})
    end

    test "serializes a string" do
      json = ~s({"test":["json",{"other":"thing","value":2}]})
      assert json == serialize(:json, json)
    end

    test "parses JSON" do
      json = ~s({"test":["json",{"other":"thing","value":2}]})

      assert {:ok, %{"test" => ["json", %{"other" => "thing", "value" => 2}]}} ==
               parse(:json, %Input.String{value: json})
    end
  end
end
