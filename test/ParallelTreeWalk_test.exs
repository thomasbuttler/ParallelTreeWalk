defmodule ParallelTreeWalkTest do
  use ExUnit.Case

  test "basic traversal works" do
    path_name = "test/dir"
    test_files = ["test/dir", "test/dir/a.txt", "test/dir/b.txt", "test/dir/badlink", "test/dir/c", "test/dir/c/d", "test/dir/c/d/e", "test/dir/c/d/f.txt", "test/dir/goodlink"]
    {:ok, %File.Stat{major_device: major}} = File.lstat(path_name)
    filter_entry = fn(_name) ->
      true
    end      # accept all, for this test
    store = :ets.new(:store, [:public])
    proc_entry = fn(name, _stat) ->
      :ets.insert(store, {name, 1})
    end
    ParallelTreeWalk.procdir(path_name, major, proc_entry, filter_entry)
    ParallelTreeWalk.wait_until_finished()
    files = for {n,_} <- :ets.match_object(store, {:_,:_}) do
      n
    end
    :ets.delete(store)
    assert length(files) == 9
    assert Enum.sort(files) == Enum.sort(test_files)
  end

  test "filter works" do
    path_name = "test/dir"
    test_files = ["test/dir", "test/dir/a.txt", "test/dir/b.txt", "test/dir/badlink", "test/dir/goodlink"]
    {:ok, %File.Stat{major_device: major}} = File.lstat(path_name)
    filter_entry = fn(name) ->
      name != "c"
    end      # accept all, for this test
    store = :ets.new(:store, [:public])
    proc_entry = fn(name, _stat) ->
      :ets.insert(store, {name, 1})
    end
    ParallelTreeWalk.procdir(path_name, major, proc_entry, filter_entry)
    ParallelTreeWalk.wait_until_finished()
    files = for {n,_} <- :ets.match_object(store, {:_,:_}) do
      n
    end
    :ets.delete(store)
    assert length(files) == 5
    assert Enum.sort(files) == Enum.sort(test_files)
  end

end
