defmodule IrcoisWeb.UserHTML do
  @moduledoc """
  This module contains pages rendered by PageController.

  See the `page_html` directory for all templates available.
  """
  use IrcoisWeb, :html

  embed_templates "user_html/*"

  def bucket_values(buckets) do
    vals =
      buckets
      |> Enum.map(fn {_t, p} ->
        "\"#{format_float(p * 100, 2)}\""
      end)
      |> Enum.join(", ")

    "[#{vals}]"
  end

  def bucket_labels(buckets) do
    vals =
      buckets
      |> Enum.map(fn {t, _p} ->
        hour = "#{t.hour}" |> String.pad_leading(2, "0")
        mins = "#{t.minute}" |> String.pad_leading(2, "0")
        "\"#{hour <> ":" <> mins}\""
      end)
      |> Enum.join(", ")

    "[#{vals}]"
  end

  def format_datetime(nil), do: ""

  def format_datetime(dt) do
    Timex.format!(dt, "%d/%m/%Y %H:%M", :strftime)
  end

  def format_time(t) do
    hour = "#{t.hour}" |> String.pad_leading(2, "0")
    mins = "#{t.minute}" |> String.pad_leading(2, "0")
    hour <> ":" <> mins
  end

  def format_float(f, decimals \\ 2) do
    trunc(f * :math.pow(10, decimals)) / :math.pow(10, decimals)
  end

end
