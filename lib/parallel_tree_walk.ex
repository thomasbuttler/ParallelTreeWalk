# thank you to https://github.com/thestonefox/elixir_poolboy_example
defmodule ParallelTreeWalk do
  use Application

  @moduledoc """
  Provides a means to process a directory tree in parallel.  Useful
  when file system I/O is about 100 times slower than processing, e.g.,
  with NFS.
  """

  # Provides a separate management space for :poolboy
  @spec pool_name() :: atom
  defp pool_name() do
    :parallel_tree_walk_pool
  end

  @doc """
  Entry point for the Elixir Application
  """
  @spec start(atom, list(any)) :: {:error, any} | {:ok, pid()} | {:ok, pid(), any}
  def start(_type, _args) do
    poolboy_config = [
      {:name, {:local, pool_name()}},
      {:worker_module, ParallelTreeWalk.Worker},
      {:size, :erlang.system_info(:thread_pool_size) - 1},
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

  @doc """
  An example use of procdir/4

  Major device numbers are unique to the file system, and minor numbers are always zero,
  *except* when the file is a device (block or character).  Practically, it means we can
  use a difference in the major device number of directories to identify a mount point.
  """
  @spec procdir(String.t) :: atom
  def procdir(path_name) do
    {:ok, %File.Stat{major_device: major}} = File.lstat(path_name)

    proc_entry = fn name, _stat ->
      IO.puts("#{name}")
      true
    end

    # accept all, for this demo
    filter_entry = fn _name -> true end
    procdir(path_name, major, proc_entry, filter_entry)
    wait_until_finished()
  end

  @doc """
    Primary entry point to ParallelTreeWalk.

    ## Arguments
      - path_name: file system path name to the first item to process.  Usually a directory,
        but won't fail with a file

      - major: false if you want to traverse mount points, otherwise the major device number
        returned by an lstat() call on path_name

      - proc_entry: a function called with two arguments: the path name of the entry being
        processed; and the %File.Stat map returned by lstat() on that entry

      - filter_entry: a function which takes the last component of the file path, and returns
        true if it should be processed, or false if not.  "." and ".." are implicitly filtered.
        This can be used to skip, e.g., directories named ".backup"

    ## Exmaple
      See procdir/1, defined in this file.
    """
    @spec procdir(String.t, integer(), (String.t, %File.Stat{} -> boolean), (String.t -> boolean)) :: atom
    def procdir(path_name, major, proc_entry, filter_entry) do
      case :poolboy.checkout(pool_name(), false) do
        # :false above means do not block
        :full ->
          # IO.puts("all threads busy, top continuing with #{path_name}")
          # all threads busy; don't deadlock, just keep going
          ParallelTreeWalk.ProcDir.procdir({path_name, major, proc_entry, filter_entry})

        # todo: change spawn to Node.spawn/4
        pid ->
          spawn(fn ->
            # IO.puts("top invokes pool worker processing #{path_name}")
            try do
              ParallelTreeWalk.Worker.procdir(pid, {path_name, major, proc_entry, filter_entry})
            after
              :ok = :poolboy.checkin(pool_name(), pid)
            end
          end)
      end
    end

  @doc """
  Entry point for escript version.

  ## Arguments
    - args: a list of strings, usually tokenized by invocation from the command line
  """
  @spec main(list(String.t)) :: atom
  def main(args \\ []) do
    try do
      procdir(List.to_string(args))
    catch
      type, value ->
        IO.puts("Error\n  #{inspect(type)}\n  #{inspect(value)}")
    end
  end

  @doc """
  Usually, you don't want to exit or otherwise proceed until the
  directory tree processing has finished.  wait_until_finished/0
  waits until that is the case, and returns :ok
  """
  @spec wait_until_finished() :: atom
  def wait_until_finished() do
    # look for 0 allocated poolboy processes
    case :poolboy.status(pool_name()) do
      {_, _, _, 0} ->
        :ok

      _ ->
        :timer.sleep(100)
        wait_until_finished()
    end
  end
end
