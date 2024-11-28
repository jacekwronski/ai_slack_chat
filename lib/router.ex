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
    %{"event_id" => event_id} = conn.body_params

    elements = :ets.lookup(:events_ids, event_id)

    if(Enum.empty?(elements)) do
      :ets.insert(:events_ids, {event_id})

      response =
        case get_message(conn.body_params) do
          {:ok, user_message} ->
            {:ok, content} = AiSlack.Bender.execute({:chat, %{message: user_message}})
            AiSlack.SlackBot.send_message(content)

            ""

          {:challange, challenge} ->
            challenge

          {:exit} ->
            ""
        end

      conn
      |> send_resp(200, response)
    else
      conn
      |> send_resp(200, "")
    end
  end

  def get_message(%{"event" => %{"subtype" => "bot_message"}}), do: {:exit}
  def get_message(%{"event" => %{"text" => text}}), do: {:ok, text}
  def get_message(%{"challenge" => challenge}), do: {:challange, challenge}
end
