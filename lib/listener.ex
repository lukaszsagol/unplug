defmodule Unplug.Listener do
  use GenServer

  defmodule State do
    defstruct sup: nil, port: 5000, socket: nil, socket_sup: nil
  end

  ## API
  def start_link(sup, config) do
    GenServer.start_link(__MODULE__, [sup, config], name: __MODULE__)
  end

  ## Callbacks
  def init([sup, config]) when is_pid(sup) do
    init(config, %State{sup: sup})
  end

  def init([{:port, port}|rest], state) do
    init(rest, %{state | port: port})
  end

  def init([_|rest], state) do
    init(rest, state)
  end

  def init([], state) do
    init(state)
  end

  def init(state = %{sup: _, port: _}) do
    send(self(), :start_socket_sup)
    send(self(), :start_listening)

    {:ok, state}
  end

  ## Callbacks
  def handle_info(:start_socket_sup, state = %{sup: sup}) do
    {:ok, socket_sup} = Supervisor.start_child(sup, supervisor_spec())

    {:noreply, %{state | socket_sup: socket_sup}}
  end

  def handle_info(:start_listening, state = %{port: port}) do
    opts = [:binary, {:packet, :raw}, {:reuseaddr, true},
            {:keepalive, true}, {:active, false}]

    {:ok, listen_socket} = :gen_tcp.listen(port, opts)

    GenServer.cast(self(), :accept)

    {:noreply, %{state | socket: listen_socket}}
  end

  def handle_info(:error, msg) do
    IO.inspect(msg)
  end

  def handle_cast(:accept, state = %{socket: socket, socket_sup: socket_sup}) do
    {:ok, conn_socket} = :gen_tcp.accept(socket)
    {:ok, socket} = new_socket(socket_sup, conn_socket)
    :ok = :gen_tcp.controlling_process(conn_socket, socket)

    GenServer.cast(self(), :accept)

    {:noreply, state}
  end

  ## Private functions
  defp new_socket(sup, socket) do
    Supervisor.start_child(sup, [sup, socket])
  end

  defp supervisor_spec() do
    Supervisor.Spec.supervisor(Unplug.SocketSupervisor, [])
  end
end
