defmodule IrcoisWeb.UserView do
  use IrcoisWeb, :view

  def bucket_values(buckets) do
    vals =
      buckets
      |> Enum.map(fn {_t, p} ->
        "\"#{trunc(p * 10000) / 100}\""
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
end
