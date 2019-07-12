defmodule ParallelTreeWalk.ProcDir do
  require Logger
  
  @moduledoc """
  Implementation of directory tree processing.
  """
@doc """
  ParallelTreeWalk.ProcDir.procdir invokes the File.lstat/2 call,
  then optionally use the result to prevent crossingmountpoints.
  File.lstat/2 is wrapped in ParallelTreeWalk.ProcDir.retry/3 to
  skip ephemeral errors.
  """
  def procdir(data = {path_name, major, _proc_entry, _proc_filter}) do
    case retry(fn() -> File.lstat(path_name, [{:time, :posix}]) end, 0, 10) do
      {:ok, file_stat} ->
        case file_stat do
          %File.Stat{major_device: ^major} ->
            procdir(data, file_stat)
          %File.Stat{type: :directory}     ->
            case major do
              false -> procdir(data, file_stat) # caller wants to cross file system boundaries
              _     -> :will_not_cross_mount_points
            end
          _                                ->
            procdir(data, file_stat) # still process device with differing major
        end
      result           ->
        Logger.warn("File.lstat of #{path_name} repeatedly failed: #{inspect(result)}")
        :ok
    end    
  end

@doc """
  ParallelTreeWalk.ProcDir.procdir/2 invokes the supplied entry processing,
  and, in the case that the entry is a directory, recurses into processing
  the directory's entries.
  """
  def procdir({path_name, major, proc_entry, proc_filter}, file_stat) do
    case proc_entry.(path_name, file_stat) do
      :false -> :pruned
      _      ->
        case file_stat do
        %File.Stat{type: :directory} ->
          case retry(fn() -> File.ls(path_name) end, 0, 10) do
            # note recursion to top level of module, where pool checkin/checkout occur
            {:ok, entries} ->
              # IO.puts("PTW.ProcDir.procdir/2 with #{path_name} processing #{entries}")
              for entry <- entries, proc_filter.(entry) do
                new_path = Path.join(path_name,entry)
                ParallelTreeWalk.procdir(new_path, major, proc_entry, proc_filter)
              end
            result         ->
              Logger.warn("File.ls of #{path_name} repeatedly failed: #{inspect(result)}")
              :ok
          end
        _ -> :finished_with_non_directory
      end
    end
  end

  use Bitwise # for left shift operator <<<

  # Attempt, with exponential backoff, to run the
  # supplied function.
  defp retry(to_retry, count, max) when count < max do
    result = to_retry.()
    case result do
      {:ok, _data} -> result
      _            -> :timer.sleep(1 <<< count) # milliseconds
                      retry(to_retry, count+1, max)
    end
  end

  # When the count has exceeded its max, try one last time.
  defp retry(to_retry, _, _) do
    # one last time
    to_retry.()
  end

end
