defmodule Learn.Hits do
  def read_file(path) do
    stream = File.stream!(path)

    [last_line] =
      stream
      |> Stream.map(&String.trim_trailing/1)
      |> Enum.to_list()
      |> Enum.take(-1)

    [item] = Enum.take(String.split(last_line, "|"), -1)
    {count, _} = Integer.parse(item)
    count
  end

  def path do
    {:ok, path} = File.cwd()
    path <> "/hits.log"
  end

  def get_hit_count(path) do
    exists = File.regular?(path)

    count =
      if exists do
        count = read_file(path)
        count + 1
      else
        1
      end

    count
  end

  def save_hits() do
    count = get_hit_count(path())
    hits = Enum.join([date_time(), count], "|") <> "\n"
    File.write!(path(), hits, [:append])

    IO.inspect(count, label: "stored_count from save_hits")
    count
  end

  def date_time do
    {{year, month, day}, {hour, minute, second}} = :calendar.local_time()
    "#{second}:#{minute}:#{hour} #{day}-#{month}-#{year}"
  end
end
