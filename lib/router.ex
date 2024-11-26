defmodule AiSlackChat.Router do
  use Plug.Router

  plug(Plug.Parsers,
    parsers: [:urlencoded, :json, :multipart],
    pass: ["*/*"],
    json_decoder: Jason
  )

  plug(:match)
  plug(:dispatch)

  post "/" do
    case get_message(conn.body_params) do
      {:ok, _} ->
        Req.post(
          "https://hooks.slack.com/services/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",
          json: %{text: "Hello!!!"}
        )

      {:exit} ->
        nil
    end

    conn
    |> send_resp(200, "")
  end

  def get_message(%{"event" => %{"subtype" => "bot_message"}}), do: {:exit}
  def get_message(%{"event" => %{"text" => text}}), do: {:ok, text}
end
