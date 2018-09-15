defmodule ParallelTreeWalk.ProcDir do
  require Logger
  
  def procdir(data = {path_name, major, _proc_entry, _proc_filter}) do
    case retry(fn() -> File.lstat(path_name) end, 0, 10) do
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
    end    
  end

  def procdir({path_name, major, proc_entry, proc_filter}, file_stat) do
    case proc_entry.(path_name, file_stat) do
      :false -> :pruned
      _      ->
        case file_stat do
        %File.Stat{type: :directory} ->
          case retry(fn() -> :file.list_dir_all(path_name) end, 0, 10) do
            # note recursion to top level of module, where pool checkin/checkout occur
            {:ok, entries} ->
              for entry <- entries, proc_filter.(entry), do:
                ParallelTreeWalk.procdir(Path.join(path_name,entry), major, proc_entry, proc_filter)
            result         ->
              Logger.warn(":file.list_dir_all of #{path_name} repeatedly failed: #{inspect(result)}")
          end
        _ -> :finished_with_non_directory
      end
    end
  end

  use Bitwise # for left shift operator <<<

  defp retry(to_retry, count, max) when count < max do
    result = to_retry.()
    case result do
      {:ok, _data} -> result
      _            -> :timer.sleep(1 <<< count) # milliseconds
                      retry(to_retry, count+1, max)
    end
  end

  defp retry(to_retry, _, _) do
    # one last time
    to_retry.()
  end

end
