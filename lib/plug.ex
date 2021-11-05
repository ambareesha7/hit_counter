defmodule Learn.Plug do
  use Plug.Router

  alias Learn.Worker
  alias Learn.Hits

  plug(:match)
  plug(:dispatch)

  get("/h") do
    render(conn)
  end

  match _ do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, ~s{go to "http://localhost:4001/h" route})
  end

  def render(conn) do
    Worker.call_count()
    stored_count = Hits.path() |> Hits.read_file()
    IO.inspect(stored_count, label: "stored count from plug")

    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, "stored count #{stored_count}")
  end
end
