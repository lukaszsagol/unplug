defmodule WebsocketTest do
  use ExUnit.Case

  setup do
    Unplug.start(nil, %{port: 0})
    {:ok, %{port: 0}}
  end

  test "accepts websocket connection", %{port: port} do
    {status, _} = :websocket_client.start_link("ws://localhost:4000/", self(), [])

    assert status == :ok
  end
end
