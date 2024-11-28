defmodule AiSlackChat.Application do
  use Application

  @impl true
  def start(_, _) do
    :ets.new(:events_ids, [:set, :public, :named_table])

    children = [
      {Plug.Cowboy, scheme: :http, plug: AiSlackChat.Router, options: [port: 4000]},
      {AiSlack.Bender,
       [
         %{
           role: "system",
           content:
             "You are a helpful assistant. Never use markdown and never use new line escape characters, use only letters for your response"
         }
       ]}
      # {Registry, [keys: :unique, name: TodoList.Registry]},
      # {TodoGateway, []}
    ]

    children
    |> Supervisor.start_link(strategy: :one_for_one, name: AiSlackChat.Supervisor)
  end
end
