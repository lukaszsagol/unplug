defmodule Unplug.Supervisor do
  use Supervisor

  ## API
  def start_link(config) do
    Supervisor.start_link(__MODULE__, config)
  end

  ## Callbacks
  def init(config) do
    children = [
      worker(Unplug.Listener, [self(), config])
    ]

    opts = [
      strategy: :one_for_all
    ]

    supervise(children, opts)
  end

  ## Private functions
end
