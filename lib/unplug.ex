defmodule Unplug do
  @moduledoc """
  Documentation for Unplug.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Unplug.hello
      :world

  """
  def hello do
    :world
  end

  def start do
    {:ok, pid} = Unplug.Supervisor.start_link([port: 4000])
  end
end
