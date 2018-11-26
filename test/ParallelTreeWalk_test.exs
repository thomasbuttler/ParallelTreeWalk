defmodule ParallelTreeWalkTest do
  use ExUnit.Case

  test "basic traversal works" do
    test_files = ["test/dir/a.txt", "test/dir/b.txt", "test/dir/badlink", "test/dir/c/d/f.txt", "test/dir/goodlink"]
    {:ok, %File.Stat{major_device: major}} = File.lstat(path_name)
    filter_entry = fn(_name) -> true end      # accept all, for this test
    store = :ets.new(test_store, [])
    proc_entry = fn(name, _stat) ->
      :ets.insert(store, {name})
    end
    ParallelTreeWalk.procdir("test/dir", major, proc_entry, filter_entry)
    ParallelTreeWalk.wait_for_empty_poolboy()
    files = for {n} -> :ets.match_object(store, :_) do n end
    :ets.delete(store)
    assert length(files) == 5
    assert Enum.sort(files) == Enum.sort(test_files)
  end

end
