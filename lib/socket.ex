defmodule Unplug.Socket do
  use GenServer

  defmodule State do
    defstruct sup: nil, socket: nil
  end

  def start_link(sup, socket) do
    GenServer.start_link(__MODULE__, [sup, socket])
  end

  def init([sup, socket]) when is_pid(sup) and is_port(socket) do
    :inet.setopts(socket, [{:active, true}])
    {:ok, %State{sup: sup, socket: socket}}
  end


  def handle_info({:tcp, socket, _msg}, state) do
    :gen_tcp.send(socket, "Hello world")
    :gen_tcp.close(socket)

    {:noreply, state}
  end

  def handle_info({:tcp_closed, _socket}, state = %{sup: sup}) do
    Supervisor.terminate_child(sup, self())
    {:noreply, state}
  end
end
