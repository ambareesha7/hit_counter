defmodule Learn.Worker do
  use GenServer
  alias Learn.Hits

  @self __MODULE__
  @timer 30_000

  # client-side
  def start_link(_) do
    GenServer.start_link(@self, :ok, name: __MODULE__)
  end

  def call_count do
    send(@self, :bump)
  end

  # server-side
  @impl true
  def init(_state) do
    Process.send_after(@self, :timer, @timer)
    {:ok, 0}
  end

  @impl true
  def handle_info(:bump, 10) do
    stored_count = Hits.save_hits()
    IO.puts("writing to disk after 10 hits\ncurrent stored count: #{stored_count}")
    Process.send_after(@self, :timer, @timer)
    {:noreply, 0}
  end

  @impl true
  def handle_info(:bump, counter) do
    IO.inspect(counter + 1, label: "current hit_count")
    {:noreply, counter + 1}
  end

  @impl true
  def handle_info(:timer, 0) do
    IO.puts("zero hits, so no write to disk after 30s")
    Process.send_after(@self, :timer, @timer)
    {:noreply, 0}
  end

  @impl true
  def handle_info(:timer, counter) when counter != 0 do
    IO.puts("there were #{counter} hits so writing to disk after 30s")
    store_count = Hits.save_hits()
    IO.puts("current store count: #{store_count}")
    Process.send_after(@self, :timer, @timer)
    {:noreply, 0}
  end

  @impl true
  def handle_info(_, counter) do
    IO.inspect(counter, label: "handle_info any")
    Process.send_after(@self, :timer, @timer)
    {:noreply, counter}
  end
end
