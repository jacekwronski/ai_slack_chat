defmodule AiSlackChatTest do
  use ExUnit.Case
  doctest AiSlackChat

  test "greets the world" do
    assert AiSlackChat.hello() == :world
  end
end
