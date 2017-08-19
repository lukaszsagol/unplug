defmodule Unplug do
  use Application

  def start(_type, args) do
    config = Map.merge(%{port: 4000}, args)
    Unplug.Supervisor.start_link(config)
  end
end
