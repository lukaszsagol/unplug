defmodule Unplug.SocketSupervisor do
  use Supervisor

  ## API
  def start_link() do
    Supervisor.start_link(__MODULE__, [])
  end

  ## Callbacks
  def init([]) do
    children = [
      worker(Unplug.Socket, [])
    ]

    opts = [
      strategy: :simple_one_for_one
    ]

    supervise(children, opts)
  end
end
