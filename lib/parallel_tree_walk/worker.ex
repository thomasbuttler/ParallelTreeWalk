defmodule ParallelTreeWalk.Worker do
  use GenServer

  @moduledoc """
  ParallelTreeWalk.Worker provides the callbacks that allow
  processing of directory in a BEAM process managed by :poolboy
  """

  @doc """
  start_link/1 invoked by :poolboy, a wrapper for :gen_server.start_link/3
  """
  @spec start_link([]) :: GenServer.on_start()
  def start_link([]) do
    :gen_server.start_link(__MODULE__, [], [])
  end

  @doc """
  Process initialization invoked by :poolboy
  """
  @spec init(init_arg :: term()) ::
    {:ok, state}
    | {:ok, state, timeout() | :hibernate | {:continue, term()}}
    | :ignore
    | {:stop, reason :: any()}
  when state: any()
  def init(state) do
    {:ok, state}
  end

  @doc """
  handle_call/3 invoked by :poolboy
  """
  @spec handle_call(request :: term(), GenServer.from(), state :: term()) ::
    {:reply, reply, new_state}
    | {:reply, reply, new_state, timeout() | :hibernate | {:continue, term()}}
    | {:noreply, new_state}
    | {:noreply, new_state, timeout() | :hibernate | {:continue, term()}}
    | {:stop, reason, reply, new_state}
    | {:stop, reason, new_state}
  when reply: term(), new_state: term(), reason: term()
  def handle_call(dir_data, _from, state) do
    ParallelTreeWalk.ProcDir.procdir(dir_data)
    {:reply, [], state}
  end

  @doc """
  procdir/2 invoked by :poolboy
  """
  @spec procdir(GenServer.server(), {String.t, integer(), (String.t, integer(), fun(), fun() -> boolean), (String.t -> boolean)}) :: term()
  def procdir(pid, dir_data) do
    :gen_server.call(pid, dir_data)
  end
end
