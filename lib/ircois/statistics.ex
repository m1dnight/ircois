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
          start_hour: fragment("date_part('hour', (? AT TIME ZONE 'UTC'))", m.when)
        },
        group_by: fragment("date_part('hour', (? AT TIME ZONE 'UTC'))", m.when),
        where: m.channel == ^channel and m.from == ^username

    # The hour is returned based on the timezone from the database, so the right timezone.
    buckets =
      Repo.all(query)
      |> Enum.map(fn h ->
        Map.put(h, :start, Time.new!(trunc(h.start_hour), 0, 0) |> Time.truncate(:second))
      end)

    # Calculate the total amount of messages for the percentage.
    total =
      buckets
      |> Enum.map(& &1.total)
      |> Enum.sum()

    # Replace the total with the percentage.
    buckets
    |> Enum.map(&Map.update(&1, :total, 0.0, fn v -> v / total end))
    |> Enum.map(&{&1.start, &1.total})
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
      ~T[00:00:00]
      |> Time.add(i * bucket_size_hours * 60 * 60)
      |> Time.truncate(:second)
    end)
    |> Enum.reduce(buckets, fn bucket, buckets ->
      Map.put_new(buckets, bucket, 0.0)
    end)
  end
end
