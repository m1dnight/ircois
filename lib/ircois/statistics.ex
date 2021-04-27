defmodule Ircois.Statistics do
  alias Ircois.{Message}
  alias Ircois.Repo
  import Ecto.Query

  #############################################################################
  # Statistics per user

  def avg_per_day(username, channel) do
    subq =
      from m in Message,
        select: %{
          daytotal: count()
        },
        group_by: fragment("date_trunc('day', (? AT TIME ZONE 'UTC'))", m.when),
        where: m.channel == ^channel and m.from == ^username

    average =
      from(day in subquery(subq))
      |> Repo.aggregate(:avg, :daytotal)

    case average do
      nil ->
        0.0

      _ ->
        Decimal.to_float(average)
    end
  end

  def total_messages(username, channel) do
    query = from m in Message, where: m.channel == ^channel and m.from == ^username
    Repo.aggregate(query, :count)
  end

  def active_hours(username, channel) do
    # Timestamps in the database are all UTC.
    # Truncating them requires them being transformed into the local TZ: (? AT TIME ZONE 'UTC')
    # When they are returned from Ecto, they are in UTC again.

    # Count messages per hour for the last year.

    query =
      from m in Message,
        select: %{
          total: count(),
          start: fragment("date_trunc('hour', (? AT TIME ZONE 'UTC'))", m.when)
        },
        group_by: fragment("date_trunc('hour', (? AT TIME ZONE 'UTC'))", m.when),
        where:
          m.channel == ^channel and m.from == ^username and
            m.when >= fragment("(now() AT TIME ZONE 'UTC') - interval '1 year'")

    buckets =
      Repo.all(query)
      |> Enum.map(fn x ->
        Map.update(x, :start, nil, &(DateTime.shift_zone!(&1, "Europe/Brussels") |> DateTime.to_time()))
      end)

    total =
      buckets
      |> Enum.map(& &1.total)
      |> Enum.sum()

    buckets
    |> Enum.map(fn b -> Map.update(b, :total, 0.0, fn v -> v / total end) end)
    |> Enum.map(fn b ->
      {b.start, b.total}
    end)
    |> Enum.into(%{})
    |> pad_buckets(1)
  end

  @doc """
  Given the computed buckets above, fills in the ones that are missing.
  Makes it easier to pass the data to chart.js.
  """
  def pad_buckets(buckets, bucket_size_hours \\ 1) do
    0..(trunc(24 / bucket_size_hours) - 1)
    |> Enum.map(fn i ->
      ~T[00:00:00.0]
      |> Time.add(i * bucket_size_hours * 60 * 60)
    end)
    |> Enum.reduce(buckets, fn bucket, buckets ->
      Map.put_new(buckets, bucket, 0.0)
    end)
  end
end
