defmodule Unplug.Socket do
  use GenServer
  require Logger

  defmodule State do
    defstruct sup: nil, socket: nil
  end

  ## API
  def start_link(sup, socket) do
    GenServer.start_link(__MODULE__, [sup, socket])
  end

  ## Callbacks
  def init([sup, socket]) when is_pid(sup) and is_port(socket) do
    :inet.setopts(socket, [{:active, true}])
    {:ok, %State{sup: sup, socket: socket}}
  end

  def handle_info({:tcp, socket, msg}, state) do
    Logger.info("Received on #{inspect self()}")
    Logger.info(msg)

    msg
    |> detect_packet_type
    |> parse
    |> reply
    |> respond(socket)

    {:noreply, state}
  end

  def handle_info({:tcp_closed, _socket}, state) do
    Logger.info("tcp_closed on #{inspect self()}")

    GenServer.cast(self(), :close)

    {:noreply, state}
  end

  def handle_cast(:close, state = %{sup: sup, socket: socket}) do
    Logger.info("close on #{inspect self()}")

    :gen_tcp.close(socket)
    Supervisor.terminate_child(sup, self())

    {:noreply, state}
  end

  defp detect_packet_type(msg) do
    cond do
      {:ok, {:http_request, _, _, _}, rest} = :erlang.decode_packet(:http, msg, []) ->
        {:http, rest}
      true ->
        {:unknown, msg}
    end
  end

  defp parse({:http, msg}) do
    {:ok, headers} = Unplug.Parser.HTTP.parse(msg)
    {:http, headers}
  end

  defp parse({:websocket, msg}) do
    {:ok, packet} = Unplug.Parser.WebSocket.parse(msg)
    {:websocket, packet}
  end

  defp reply({:http, headers}) do
    Unplug.Responder.Handshake.call(headers)
  end

  defp reply({:websocket, msg}) do
  end

  defp respond({:reply, msg}, socket) do
    Logger.info("Responded: #{msg}")

    :gen_tcp.send(socket, msg)
  end

  defp respond({:close, msg}, socket) do
    respond({:reply, msg}, socket)
    GenServer.cast(self(), :close)
  end
end
