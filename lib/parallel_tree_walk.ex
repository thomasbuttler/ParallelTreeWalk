# thank you to https://github.com/thestonefox/elixir_poolboy_example
defmodule ParallelTreeWalk do
  use Application

  defp pool_name() do
    :parallel_tree_walk_pool
  end

  def start(_type, _args) do
    poolboy_config = [
      {:name, {:local, pool_name()}},
      {:worker_module, ParallelTreeWalk.Worker},
      {:size, :erlang.system_info(:thread_pool_size)-1},
      {:max_overflow, 0}
    ]

    children = [
      :poolboy.child_spec(pool_name(), poolboy_config, [])
    ]

    options = [
      strategy: :one_for_one,
      name: ParallelTreeWalk.Supervisor
    ]

    Supervisor.start_link(children, options)
  end

  # major device numbers are unique to the file system, and minor numbers are always zero,
  # *except* when the file is a device (block or character).  Practically, it means we can
  # use a difference in the major device number of directories to identify a mount point.
  def procdir(path_name) do # /1 example
    {:ok, %File.Stat{major_device: major}} = File.lstat(path_name)
    proc_entry = fn(name, _stat) ->
      IO.puts("#{name}")
      true
    end
    filter_entry = fn(_name) -> true end      # accept all, for this demo
    procdir(path_name, major, proc_entry, filter_entry)
    wait_until_finished()
  end

  def procdir(path_name, major, proc_entry, filter_entry) do # /4 version
    case :poolboy.checkout(pool_name(), :false) do
      # :false above means do not block
      :full ->
        # IO.puts("all threads busy, top continuing with #{path_name}")
        # all threads busy; don't deadlock, just keep going
        ParallelTreeWalk.ProcDir.procdir({path_name, major, proc_entry, filter_entry})
      # todo: change spawn to Node.spawn/4
      pid   -> spawn(fn() ->
          # IO.puts("top invokes pool worker processing #{path_name}")
          try do
            ParallelTreeWalk.Worker.procdir(pid, {path_name, major, proc_entry, filter_entry})
          after
            :ok = :poolboy.checkin(pool_name(), pid)
          end
        end)
    end
  end

  def main(args \\ []) do
    try do
      procdir(List.to_string(args))
    catch type, value ->
      IO.puts "Error\n  #{inspect type}\n  #{inspect value}"
    end
  end

  def wait_until_finished() do
    # look for 0 allocated poolboy processes
    case :poolboy.status(pool_name()) do
    {_, _, _, 0} -> :ok
    _            -> :timer.sleep(100)
                    wait_until_finished()
    end
  end

end
