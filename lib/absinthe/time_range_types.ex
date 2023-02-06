defmodule FastWeb.Schema.TimeRangeTypes do
  use Absinthe.Schema.Notation

  input_object :time_range_input do
    field :start, non_null(:datetime)
    field :finish, non_null(:datetime)
  end

  input_object :inclusive_date_range_input do
    field :start, non_null(:date)
    field :finish, non_null(:date)
  end

  object :date_range do
    field :start, non_null(:date) do
      resolve fn
        {%DateTime{} = start, %DateTime{} = _finish}, _, _ ->
          {:ok, DateTime.to_date(start)}

        {%Date{} = start, %Date{} = _finish}, _, _ ->
          {:ok, start}

        %{start: %DateTime{} = start, finish: %DateTime{} = _finish}, _, _ ->
          {:ok, DateTime.to_date(start)}

        %{start: %Date{} = start, finish: %Date{} = _finish}, _, _ ->
          {:ok, start}
      end
    end

    field :finish, non_null(:date) do
      resolve fn
        {%DateTime{} = _start, %DateTime{} = finish}, _, _ ->
          {:ok, DateTime.to_date(finish)}

        {%Date{} = _start, %Date{} = finish}, _, _ ->
          {:ok, finish}

        %{start: %DateTime{} = _start, finish: %DateTime{} = finish}, _, _ ->
          {:ok, DateTime.to_date(finish)}

        %{start: %Date{} = _start, finish: %Date{} = finish}, _, _ ->
          {:ok, finish}
      end
    end

    field :duration, non_null(:integer) do
      resolve fn
        {%Date{} = start, %Date{} = finish}, _, _ ->
          {:ok, Date.diff(finish, start)}

        {%DateTime{} = start_dt, %DateTime{} = finish_dt}, _, _ ->
          start = DateTime.to_date(start_dt)
          finish = DateTime.to_date(finish_dt)
          {:ok, Date.diff(finish, start)}

        %{start: %Date{} = start, finish: %Date{} = finish}, _, _ ->
          {:ok, Date.diff(finish, start)}

        %{start: %DateTime{} = start_dt, finish: %DateTime{} = finish_dt}, _, _ ->
          start = DateTime.to_date(start_dt)
          finish = DateTime.to_date(finish_dt)
          {:ok, Date.diff(finish, start)}
      end
    end
  end

  object :time_range do
    field :start, non_null(:datetime) do
      resolve fn
        {start, _finish}, _, _ ->
          {:ok, start}

        %{start: start, finish: _finish}, _, _ ->
          {:ok, start}
      end
    end

    field :finish, non_null(:datetime) do
      resolve fn
        {_start, finish}, _, _ ->
          {:ok, finish}

        %{start: _start, finish: finish}, _, _ ->
          {:ok, finish}
      end
    end

    field :duration, non_null(:integer) do
      resolve fn
        {start, finish}, _, _ ->
          {:ok, Timex.diff(finish, start, :minutes)}

        %{start: start, finish: finish}, _, _ ->
          {:ok, Timex.diff(finish, start, :minutes)}
      end
    end

    field :start_time_string, non_null(:string) do
      # Default Value formats in <date>T<time><offset>. Full date and time specification with separators. (e.g. 2007-08-13T16:48:01 +03:00)
      arg :format, :string, default_value: "{ISO:Extended}"
      arg :time_zone_name, :string

      resolve fn
        {start, _finish}, %{format: format, time_zone_name: time_zone_name}, _ ->
          start
          |> Timex.to_datetime(time_zone_name)
          |> Timex.format(format)

        {start, _finish}, %{format: format}, _ ->
          Timex.format(start, format)
      end
    end

    field :finish_time_string, non_null(:string) do
      # Default Value formats in <date>T<time><offset>. Full date and time specification with separators. (e.g. 2007-08-13T16:48:01 +03:00)
      arg :format, :string, default_value: "{ISO:Extended}"
      arg :time_zone_name, :string

      resolve fn
        {_start, finish}, %{format: format, time_zone_name: time_zone_name}, _ ->
          finish
          |> Timex.to_datetime(time_zone_name)
          |> Timex.format(format)

        {_start, finish}, %{format: format}, _ ->
          Timex.format(finish, format)
      end
    end
  end

  object :time_series_integers do
    field :time_range, non_null(:time_range)
    field :data, non_null(list_of(non_null(:time_series_integer_datum)))
  end

  object :time_series_integer_datum do
    field :datetime, non_null(:datetime)
    field :value, non_null(:integer)
  end

  enum :time_range_granularity do
    value :hourly
    value :daily
    value :weekly
    value :monthly
    value :quarterly
    value :yearly
  end
end
