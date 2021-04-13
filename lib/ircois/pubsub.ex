defmodule Ircois.PubSub do
  @topic inspect(__MODULE__)

  def subscribe do
    Phoenix.PubSub.subscribe(__MODULE__, @topic)
  end

  def notify_new_url({:error, err}) do
    {:error, err}
  end

  def notify_new_url({:ok, message}) do
    Phoenix.PubSub.broadcast(__MODULE__, @topic, {:new_url, message})
    {:ok, message}
  end

  def notify_karma_update({:error, err}) do
    {:error, err}
  end

  def notify_karma_update({:ok, message}) do
    Phoenix.PubSub.broadcast(__MODULE__, @topic, {:new_karma, message})
    {:ok, message}
  end

  def notify_fact_update({:ok, message}) do
    Phoenix.PubSub.broadcast(__MODULE__, @topic, {:new_fact, message})
    {:ok, message}
  end

  def notify_new_message({:error, err}) do
    {:error, err}
  end

  def notify_new_message({:ok, message}) do
    Phoenix.PubSub.broadcast(__MODULE__, @topic, {:new_message, message})
    {:ok, message}
  end
end
