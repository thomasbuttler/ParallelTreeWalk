defmodule ParallelTreeWalk.Worker do
  use GenServer

  def start_link([]) do
    :gen_server.start_link(__MODULE__, [], [])
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call(dir_data, _from, state) do
    ParallelTreeWalk.ProcDir.procdir(dir_data)
    {:reply, [], state}
  end

  def procdir(pid, dir_data) do
    :gen_server.call(pid, dir_data)
  end
end
