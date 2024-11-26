defmodule AiSlackChat.Application do
  use Application

  @impl true
  def start(_, _) do
    children = [
      {Plug.Cowboy, scheme: :http, plug: AiSlackChat.Router, options: [port: 4000]},
      # {Registry, [keys: :unique, name: TodoList.Registry]},
      # {TodoGateway, []}
    ]

    children
    |> Supervisor.start_link(strategy: :one_for_one, name: AiSlackChat.Supervisor)
  end
end
