defmodule Learn.Worker do
  use GenServer
  alias Learn.Hits

  @self __MODULE__
  @timer 30_000

  # client-side
  def start_link(state) do
    GenServer.start_link(@self, state, name: __MODULE__)
  end

  def call_count do
    IO.puts("call_count being called")
    send(@self, :bump)
    Process.send_after(@self, :timer, @timer)
  end

  # server-side
  @impl true
  def init(_state) do
    {:ok, 1}
  end

  @impl true
  def handle_info(:bump, 10) do
    stored_count = Hits.save_hits()
    IO.inspect(stored_count, label: "handle_info write to disk after 10 hits")
    call_count()
    {:noreply, 0}
  end

  @impl true
  def handle_info(:bump, counter) do
    IO.inspect(counter, label: "handle_info hit_count")
    {:noreply, counter + 1}
  end

  @impl true
  def handle_info(:timer, counter) when counter != 0 do
    IO.inspect(counter, label: "handle_info write to disk after 30s")
    Hits.save_hits()
    {:noreply, 0}
  end

  @impl true
  def handle_info(_, counter) do
    IO.inspect(counter, label: "handle_info any")
    {:noreply, counter}
  end
end
