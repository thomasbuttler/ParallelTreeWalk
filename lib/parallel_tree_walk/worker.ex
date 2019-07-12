defmodule ParallelTreeWalk.Worker do
  use GenServer

  @moduledoc """
  ParallelTreeWalk.Worker provides the callbacks that allow
  processing of directory in a BEAM process managed by :poolboy
  """

  @doc """
  start_link/1 invoked by :poolboy, a wrapper for :gen_server.start_link/3
  """
  def start_link([]) do
    :gen_server.start_link(__MODULE__, [], [])
  end

  @doc """
  Process initialization invoked by :poolboy
  """
  def init(state) do
    {:ok, state}
  end

  @doc """
  handle_call/3 invoked by :poolboy
  """
  def handle_call(dir_data, _from, state) do
    ParallelTreeWalk.ProcDir.procdir(dir_data)
    {:reply, [], state}
  end

  @doc """
  procdir/2 invoked by :poolboy
  """
  def procdir(pid, dir_data) do
    :gen_server.call(pid, dir_data)
  end
end
