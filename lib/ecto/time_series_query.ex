defmodule Fast.Ecto.TimeSeriesQuery do
  # -- Imports
  import Ecto.Query

  @default_time_zone_name "US/Pacific"

  def time_series_counts_query(queryable, opts) when is_list(opts) do
    start = Access.fetch!(opts, :start)
    finish = Access.fetch!(opts, :finish)

    granularity = unit_for_range(start, finish)

    case granularity do
      :hourly -> hourly_counts_query(queryable, opts)
      :daily -> daily_counts_query(queryable, opts)
      :weekly -> weekly_counts_query(queryable, opts)
      :monthly -> monthly_counts_query(queryable, opts)
    end
  end

  def hourly_counts_query(queryable, opts) do
    field_name = Access.get(opts, :field, :inserted_at)
    start = Access.fetch!(opts, :start)
    finish = Access.fetch!(opts, :finish)
    time_zone_name = Access.get(opts, :time_zone_name, @default_time_zone_name)

    iana_time_zone_name = Tzdata.links() |> Map.get(time_zone_name)

    from(row in queryable,
      where:
        is_nil(field(row, ^field_name)) or
          (field(row, ^field_name) >= ^start and field(row, ^field_name) < ^finish),
      right_join:
        h in fragment(
          "select generate_series(
            date_trunc('day', (?)::timestamp AT TIME ZONE 'UTC' AT TIME ZONE (?))::timestamptz,
            date_trunc('day', (?)::timestamp AT TIME ZONE 'UTC' AT TIME ZONE (?))::timestamptz,
            '1 hour'::interval
          )::timestamp as hour",
          ^start,
          ^iana_time_zone_name,
          ^finish,
          ^iana_time_zone_name
        ),
      on:
        h.hour ==
          fragment(
            "to_timestamp(to_char(?, 'YYYY-MM-DD HH24'), 'YYYY-MM-DD HH24')",
            field(row, ^field_name)
          ),
      group_by: h.hour,
      order_by: h.hour,
      select: %{datetime: h.hour, value: count(row.id)}
    )
  end

  def daily_counts_query(queryable, opts) do
    field_name = Access.get(opts, :field, :inserted_at)
    start = Access.fetch!(opts, :start) |> Timex.to_datetime("Etc/UTC")
    finish = Access.fetch!(opts, :finish) |> Timex.to_datetime("Etc/UTC")
    time_zone_name = Access.get(opts, :time_zone_name, @default_time_zone_name)

    iana_time_zone_name = Tzdata.links() |> Map.get(time_zone_name)

    from(row in queryable,
      where:
        is_nil(field(row, ^field_name)) or
          (field(row, ^field_name) >= ^start and field(row, ^field_name) < ^finish),
      right_join:
        d in fragment(
          "select generate_series(
                  date_trunc('day', (?)::timestamp AT TIME ZONE 'UTC' AT TIME ZONE (?))::timestamp,
                  date_trunc('day', (?)::timestamp AT TIME ZONE 'UTC' AT TIME ZONE (?))::timestamp,
                  '1 day'::interval
                ) as day",
          ^start,
          ^iana_time_zone_name,
          ^finish,
          ^iana_time_zone_name
        ),
      on:
        d.day ==
          fragment(
            "date_trunc('day', (?)::timestamp AT TIME ZONE 'UTC' AT TIME ZONE (?))::timestamp",
            field(row, ^field_name),
            ^iana_time_zone_name
          ),
      group_by: d.day,
      order_by: d.day,
      select: %{datetime: d.day, value: count(row.id)}
    )
  end

  def weekly_counts_query(queryable, opts) do
    field_name = Access.get(opts, :field, :inserted_at)
    start = Access.fetch!(opts, :start)
    finish = Access.fetch!(opts, :finish)

    from(row in queryable,
      where:
        is_nil(field(row, ^field_name)) or
          (field(row, ^field_name) >= ^start and field(row, ^field_name) < ^finish),
      right_join:
        w in fragment(
          """
          select generate_series(
            date_trunc('week', (?)::timestamp AT TIME ZONE 'America/Los_Angeles'),
            date_trunc('week', (?)::timestamp AT TIME ZONE 'America/Los_Angeles'),
            '1 week'::interval
          ) as week
          """,
          fragment("(?)::timestamp AT TIME ZONE 'UTC'", ^start),
          fragment("(?)::timestamp AT TIME ZONE 'UTC'", ^finish)
        ),
      on:
        w.week ==
          fragment(
            "date_trunc('week', (?)::timestamp AT TIME ZONE 'America/Los_Angeles')",
            field(row, ^field_name)
          ),
      group_by: w.week,
      order_by: w.week,
      select: %{datetime: w.week, value: count(row.id)}
    )
  end

  def monthly_counts_query(queryable, opts) do
    field_name = Access.get(opts, :field, :inserted_at)
    start = Access.fetch!(opts, :start)
    finish = Access.fetch!(opts, :finish)

    from(row in queryable,
      where:
        is_nil(field(row, ^field_name)) or
          (field(row, ^field_name) >= ^start and field(row, ^field_name) < ^finish),
      right_join:
        m in fragment(
          """
          select generate_series(
            date_trunc('month', (?)::timestamp AT TIME ZONE 'America/Los_Angeles'),
            date_trunc('month', (?)::timestamp AT TIME ZONE 'America/Los_Angeles'),
            '1 month'::interval
          ) as month
          """,
          fragment("(?)::timestamp AT TIME ZONE 'UTC'", ^start),
          fragment("(?)::timestamp AT TIME ZONE 'UTC'", ^finish)
        ),
      on:
        m.month ==
          fragment(
            "date_trunc('month', (?)::timestamp AT TIME ZONE 'America/Los_Angeles')",
            field(row, ^field_name)
          ),
      group_by: m.month,
      order_by: m.month,
      select: %{datetime: m.month, value: count(row.id)}
    )
  end

  def unit_for_range(%DateTime{} = start, %DateTime{} = finish) do
    unit_for_range({start, finish})
  end

  def unit_for_range(%{start: %DateTime{} = start, finish: %DateTime{} = finish}) do
    unit_for_range({start, finish})
  end

  def unit_for_range({%DateTime{} = start, %DateTime{} = finish}) do
    num_days = abs(Timex.diff(finish, start, :days))

    cond do
      # Less than 3 days -> hourly
      num_days in 0..3 ->
        :hourly

      # Between 3 and 90 days -> daily
      num_days in 4..90 ->
        :daily

      # Between 90 and 180 days -> weekly
      num_days in 91..180 ->
        :weekly

      # Over 180 days -> monthly
      num_days > 180 ->
        :monthly
    end
  end
end
