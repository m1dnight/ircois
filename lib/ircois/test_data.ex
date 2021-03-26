defmodule TestData do
  @words """
  "In hac habitasse platea dictumst. Vivamus facilisis diam at odio. Mauris dictum, nisi eget consequat elementum, lacus ligula molestie metus, non feugiat orci magna ac sem. Donec turpis. Donec vitae metus. Morbi tristique neque eu mauris. Quisque gravida ipsum non sapien. Proin turpis lacus, scelerisque vitae, elementum at, lobortis ac, quam. Aliquam dictum eleifend risus. In hac habitasse platea dictumst. Etiam sit amet diam. Suspendisse odio. Suspendisse nunc. In semper bibendum libero. Proin nonummy, lacus eget pulvinar lacinia, pede felis dignissim leo, vitae tristique magna lacus sit amet eros. Nullam ornare. Praesent odio ligula, dapibus sed, tincidunt eget, dictum ac, nibh. Nam quis lacus. Nunc eleifend molestie velit. Morbi lobortis quam eu velit. Donec euismod vestibulum massa. Donec non lectus. Aliquam commodo lacus sit amet nulla. Cras dignissim elit et augue. Nullam non diam. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. In hac habitasse platea dictumst. Aenean vestibulum. Sed lobortis elit quis lectus. Nunc sed lacus at augue bibendum dapibus. Aliquam vehicula sem ut pede. Cras purus lectus, egestas eu, vehicula at, imperdiet sed, nibh. Morbi consectetuer luctus felis. Donec vitae nisi. Aliquam tincidunt feugiat elit. Duis sed elit ut turpis ullamcorper feugiat. Praesent pretium, mauris sed fermentum hendrerit, nulla lorem iaculis magna, pulvinar scelerisque urna tellus a justo. Suspendisse pulvinar massa in metus. Duis quis quam. Proin justo. Curabitur ac sapien. Nam erat. Praesent ut quam. Vivamus commodo, augue et laoreet euismod, sem sapien tempor dolor, ac egestas sem ligula quis lacus. Donec vestibulum tortor ac lacus. Sed posuere vestibulum nisl. Curabitur eleifend fermentum justo. Nullam imperdiet. Integer sit amet mauris imperdiet risus sollicitudin rutrum. Ut vitae turpis. Nulla facilisi. Quisque tortor velit, scelerisque et, facilisis vel, tempor sed, urna. Vivamus nulla elit, vestibulum eget, semper et, scelerisque eget, lacus. Pellentesque viverra purus. Quisque elit. Donec ut dolor. Duis volutpat elit et erat. In at nulla at nisl condimentum aliquet. Quisque elementum pharetra lacus. Nunc gravida arcu eget nunc. Nulla iaculis egestas magna. Aliquam erat volutpat. Sed pellentesque orci. Etiam lacus lorem, iaculis sit amet, pharetra quis, imperdiet sit amet, lectus. Integer quis elit ac mi aliquam pretium. Nullam mauris orci, porttitor eget, sollicitudin non, vulputate id, risus. Donec varius enim nec sem. Nam aliquam lacinia enim. Quisque eget lorem eu purus dignissim ultricies. Fusce porttitor hendrerit ante. Mauris urna diam, cursus id, mattis eget, tempus sit amet, risus. Curabitur eu felis. Sed eu mi. Nullam lectus mauris, luctus a, mattis ac, tempus non, leo. Cras mi nulla, rhoncus id, laoreet ut, ultricies id, odio. Donec imperdiet. Vestibulum auctor tortor at orci. Integer semper, nisi eget suscipit eleifend, erat nisl hendrerit justo, eget vestibulum lorem justo ac leo. Integer sem velit, pharetra in, fringilla eu, fermentum id, felis. Vestibulum sed felis. In elit. Praesent et pede vel ante dapibus condimentum. Donec magna. Quisque id risus. Mauris vulputate pellentesque leo. Duis vulputate, ligula at venenatis tincidunt, orci nunc interdum leo, ac egestas elit sem ut lacus. Etiam non diam quis arcu egestas commodo. Curabitur nec massa ac massa gravida condimentum. Aenean id libero. Pellentesque vitae tellus. Fusce lectus est, accumsan ac, bibendum sed, porta eget, augue. Etiam faucibus. Quisque tempus purus eu ante. Vestibulum sapien nisl, ornare auctor, consectetuer quis, posuere tristique, odio. Fusce ultrices ullamcorper odio. Ut augue nulla, interdum at, adipiscing non, tristique eget, neque. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Ut pede est, condimentum id, scelerisque ac, malesuada non, quam. Proin eu ligula ac sapien suscipit blandit. Suspendisse euismod."
  """

  @user_count 5
  @message_count 100
  @nick_length 7
  @message_length 3
  @karma_increments 100
  @url_count 100
  @channel "#infogroep"

  @days_back 14 * 86400
  @minutes_between_messages 15

  def now() do
    tz = Application.get_env(:ircois, :timezone)
    DateTime.now!(tz)
  end

  def add_seconds(dt, delta) do
    DateTime.add(dt, delta, :second, Calendar.get_time_zone_database())
  end

  def add_minutes(dt, delta) do
    DateTime.add(dt, delta * 60, :second, Calendar.get_time_zone_database())
  end

  def add_days(dt, delta) do
    DateTime.add(dt, delta * 24 * 60 * 60, :second, Calendar.get_time_zone_database())
  end

  def gen_nick() do
    1..@nick_length
    |> Enum.map(fn _ ->
      "1234567890abcdefghijklmnopqrstuvwxyz_"
      |> String.to_charlist()
      |> Enum.random()
    end)
    |> List.to_string()
  end

  def gen_message() do
    @words
    |> String.split(" ")
    |> Enum.shuffle()
    |> Enum.take(@message_length)
    |> Enum.join(" ")
  end

  def gen_url do
    str =
      @words
      |> String.split(" ")
      |> Enum.shuffle()
      |> Enum.take(@message_length)
      |> Enum.join()

    "https://#{str}.com"
  end

  def insert_messages(previous) do
    current = add_seconds(previous, -1 * 3)
    random_nick = gen_nick()

    message = %{
      :from => random_nick,
      :content => gen_message(),
      :channel => @channel,
      :when => current
    }

    IO.puts("Inserting")
    {:ok, _} = Ircois.Data.store_message(message)

    if abs(DateTime.diff(current, now(), :second)) < @days_back do
      insert_messages(current)
    else
      IO.puts("Done inserting")
    end
  end

  def insert_all() do
    IO.puts("Inserting messages!!!!!")
    insert_messages(now())
  end

  #   messages
  # |> Enum.map(fn message ->
  #   random_nick = Enum.random(nicknames)
  #   random_timestamp =
  #   {:ok, _} = Ircois.Data.store_message(%{:from => random_nick, :content => message, :channel => channel})
  # end)
end
