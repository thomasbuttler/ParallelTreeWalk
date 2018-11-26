defmodule ParallelTreeWalkTest do
  use ExUnit.Case

  test "basic traversal works" do
    test_files = ["test/dir/a.txt", "test/dir/b.txt", "test/dir/badlink", "test/dir/c/d/f.txt", "test/dir/goodlink"]
    {:ok, walker} = DirWalker.start_link("test/dir")
    files = DirWalker.next(walker, 99)
    assert length(files) == 5
    assert Enum.sort(files) == Enum.sort(test_files)
  end


end
