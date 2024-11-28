defmodule AiSlack.Bender do
  use GenServer

  def start_link([message]) do
    {:ok, pid} = GenServer.start_link(__MODULE__, message, name: :bender)
    # :sys.trace(pid, true)
    {:ok, pid}
  end

  def init(message) do
    Process.flag(:trap_exit, true)
    {:ok, encoded_messages} = Jason.encode([message])
    {:ok, %{client: "client", messages: encoded_messages}}
  end

  @spec execute(any()) :: any()
  def execute(command) do
    res = GenServer.call(:bender, command)
    IO.inspect(res, label: "executer res")
    res
  end

  def handle_call(
        {:chat, %{message: message}},
        _from,
        %{client: _, messages: messages} = state
      ) do
    IO.inspect(messages, label: "HANDLE MESSAGE!!!!")

    {:ok, decoded_meesages} = Jason.decode(messages)

    IO.inspect(decoded_meesages, label: "DECODED MESSAGES!!!!!")

    map_messages =
      Enum.map(decoded_meesages, fn %{"content" => content, "role" => role} ->
        %{content: content, role: role}
      end)

    chat_res = chat(map_messages ++ [%{role: "user", content: message}])

    IO.inspect(chat_res, label: "CHAT RES")

    {:ok, %{"message" => %{"content" => content}}} = chat_res

    # IO.puts(content)

    # Restituisce true se la stringa è valida in UTF-8
    # valid = String.valid?(content)

    # IO.inspect(valid, label: "VALID")

    # new_content = String.replace(content, ~r/[^a-z0-9\s-]/u, " ")
    # String.replace(String.replace(content, "\\", "@@@@"), "\n", "@nn@")

    IO.inspect(content, label: "CONTENT")

    {:ok, encoded_messages} =
      Jason.encode(
        map_messages ++
          [%{role: "user", content: message}, %{role: "assistant", content: content}]
      )

    # {:ok, decoded} = Jason.decode(json_string)

    new_state = %{state | messages: encoded_messages}

    # IO.inspect(new_state, label: "NEW STATE")

    {:reply, {:ok, content}, new_state}
  end

  # def terminate(reason, state) do
  #   IO.inspect({reason, state}, label: "TERMINATE")
  # end

  @spec chat(any()) :: {:error, struct()} | {:ok, any()}
  def chat(messages) do
    client = Ollama.init()
    Ollama.chat(client, model: "llama3.1:latest", messages: messages)
  end
end
