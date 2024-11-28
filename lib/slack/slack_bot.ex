defmodule AiSlack.SlackBot do
  def send_message(message) do
    Req.post(
      "https://hooks.slack.com/services/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",
      json: %{text: message}
    )
  end
end
