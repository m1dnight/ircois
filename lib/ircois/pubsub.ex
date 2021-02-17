defmodule Ircois.PubSub do
  @topic inspect(__MODULE__)

  def subscribe do
    Phoenix.PubSub.subscribe(__MODULE__, @topic)
  end

  defp notify_new_message({:error, err}) do
    {:error, err}
  end

  defp notify_new_message({:ok, message}) do
    Phoenix.PubSub.broadcast(__MODULE__, @topic, {:new_message, message})
    {:ok, message}
  end
end
