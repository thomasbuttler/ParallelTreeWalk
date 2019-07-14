<?xml version="1.0" encoding="utf-8"?>
<!-- Created by Leo: http://leoeditor.com/leo_toc.html -->
<leo_file xmlns:leo="http://leoeditor.com/namespaces/leo-python-editor/1.1" >
<leo_header file_format="2" tnodes="0" max_tnode_index="0" clone_windows="0"/>
<globals body_outline_ratio="0.5" body_secondary_ratio="0.5">
	<global_window_position top="50" left="50" height="500" width="700"/>
	<global_log_window_position top="0" left="0" height="0" width="0"/>
</globals>
<preferences/>
<find_panel_settings/>
<vnodes>
<v t="tbuttler.20180908205248.2"><vh>@clean README.md</vh>
<v t="tbuttler.20180908205248.3"><vh>ParallelTreeWalk</vh></v>
</v>
<v t="tbuttler.20181125204114.1"><vh>lib</vh>
<v t="tbuttler.20180908211411.2"><vh>@clean parallel_tree_walk.ex</vh>
<v t="tbuttler.20180908232353.1"><vh>defp pool_name()</vh></v>
<v t="tbuttler.20180908232425.1"><vh>start(_type, _args)</vh></v>
<v t="tbuttler.20180908232444.1"><vh>procdir(path_name)</vh></v>
<v t="tbuttler.20180908232512.1"><vh>procdir(path_name, major, proc_entry, filter_entry)</vh></v>
<v t="tbuttler.20180909003721.1"><vh>main(_)</vh></v>
<v t="tbuttler.20180915033213.1"><vh>wait_until_finished()</vh></v>
</v>
<v t="tbuttler.20180908232152.4"><vh>@clean parallel_tree_walk/worker.ex</vh>
<v t="tbuttler.20180908232939.1"><vh>def start_link([])</vh></v>
<v t="tbuttler.20180908232947.1"><vh>def init(state)</vh></v>
<v t="tbuttler.20180908232955.1"><vh>def handle_call(dir_data, _from, state)</vh></v>
<v t="tbuttler.20180908233001.1"><vh>def procdir(pid, dir_data)</vh></v>
</v>
<v t="tbuttler.20180908232152.2"><vh>@clean parallel_tree_walk/proc_dir.ex</vh>
<v t="tbuttler.20180908233156.1"><vh>procdir(data = {path_name, major, _proc_entry, _proc_filter})</vh></v>
<v t="tbuttler.20180908233204.1"><vh>procdir({path_name, major, proc_entry, proc_filter}, file_stat)</vh></v>
<v t="tbuttler.20180908233233.1"><vh>use Bitwise</vh></v>
<v t="tbuttler.20180908233215.1"><vh>defp retry(to_retry, count, max) when count &lt; max</vh></v>
<v t="tbuttler.20180908233220.1"><vh>defp retry(to_retry, _, _)</vh></v>
</v>
</v>
<v t="tbuttler.20181125204159.1"><vh>test</vh>
<v t="tbuttler.20181125204226.2"><vh>@clean ParallelTreeWalk_test.exs</vh></v>
<v t="tbuttler.20181125204226.4"><vh>@clean test_helper.exs</vh></v>
<v t="tbuttler.20181125204539.1"><vh>dir</vh>
<v t="tbuttler.20181125204557.1"><vh>@clean a.txt</vh></v>
<v t="tbuttler.20181125204620.1"><vh>@clean b.txt</vh></v>
<v t="tbuttler.20181125204627.1"><vh>@clean c/d/f.txt</vh></v>
</v>
</v>
<v t="tbuttler.20180909002850.2"><vh>@clean mix.exs</vh></v>
<v t="tbuttler.20180909022109.1"><vh>@clean .gitignore</vh></v>
</vnodes>
<tnodes>
<t tx="tbuttler.20180908205248.2">@others
@language md
@tabwidth -4
</t>
<t tx="tbuttler.20180908205248.3">Library to visit the files in a directory tree
==============================================

This library is intended for use with

* POSIX compatible directory trees
* *UNORDERD* access to files
* *idempotent* operations on files (i.e., the same operation can be done one *or more* times, and still get the same result; e.g., "change owner bin to owner root"; e.g., *NOT* "change owner bin to owner root; change owner daemon to owner bin")
* input bound processing: the underying Erlang virtual machine should be invoked with something like +A32 because processing is spending its time in each of those threads idle waiting for the file server to respond.

Run with:
---------
* mix deps.get
* iex --erl +A32 -S mix
* iex(1)&gt; ParallelTreeWalk.procdir(".")
* ...or...
* mix escript.build
* ./parallel_tree_walk .

*HOWEVER*: the runnable stuff is just an example; one will want to write functions to operate on the files delivered by the library.  The important entry point is

    procdir(path_name, major, proc_entry, filter_entry)

where

* path_name is the path to a directory or file
* major is the major device number reported by lstat(), and ensures that the program does not descend into mount points; *however* if its value is false (:false, nil, :nil) it *will* cross mount points
* proc_entry is a lambda
  * expecting as arguments
    * a file path
    * the lstat data (as a %File.Stat map) of the file path; that the lstat data is expensive (in time) to acquire is a primary motivation for this library
  * returning
    * :false to prevent further descent into this tree (which only make sense for a directory; there's nothing to descend into for a regular file)
    * anything else continues processing
* proc_filter is a lambda
  * expecting as argument
    * the last component of a file name
  * returning
    * true for things to be processed
    * :false otherwise; use it to prune the tree by file name, e.g., to skip ".git" directories.

Test Status: [![Build Status](https://travis-ci.org/thomasbuttler/ParallelTreeWalk.svg?branch=master)](https://travis-ci.org/thomasbuttler/ParallelTreeWalk)

Current Best Example
--------------------
[FixId](https://github.com/thomasbuttler/FixId): a chown/chgrp utility

To Do
-----
* develop chmod example
* improve @moduledoc, @doc
* provide @spec
* replace spawn/1 with Node.spawn/4

NOTES:
------

* do not apply a chmod to a symlink: the Linux kernel ignores the permissions mode of the symlink itself (thus one does not need to change those permissions), and applying chmod to the symlink changes the target of the symlink, which should have complex guardrails.
* missing lchown:
  * do not apply chown to a symlink, or
  * [better]
    * capture the name of the symlink
    * capture the target of the symlink
    * recreate the symlink as root
      * linux symlink permission semantic:
        * owner, group, and mode of symlink ignored
        * permission to replace or remove symlink specified by containing directory

</t>
<t tx="tbuttler.20180908211411.2">@language elixir
# thank you to https://github.com/thestonefox/elixir_poolboy_example
defmodule ParallelTreeWalk do
  use Application

  @moduledoc """
  Provides a means to process a directory tree in parallel.  Useful
  when file system I/O is about 100 times slower than processing, e.g.,
  with NFS.
  """

  @others
end
</t>
<t tx="tbuttler.20180908232152.2">@language elixir
defmodule ParallelTreeWalk.ProcDir do
  require Logger

  @moduledoc """
  Implementation of directory tree processing.
  """
  @others
end
</t>
<t tx="tbuttler.20180908232152.4">@language elixir
defmodule ParallelTreeWalk.Worker do
  use GenServer

  @moduledoc """
  ParallelTreeWalk.Worker provides the callbacks that allow
  processing of directory in a BEAM process managed by :poolboy
  """

  @others
end
</t>
<t tx="tbuttler.20180908232353.1"># Provides a separate management space for :poolboy
@spec pool_name() :: atom
defp pool_name() do
  :parallel_tree_walk_pool
end

</t>
<t tx="tbuttler.20180908232425.1">@raw
  @doc """
@end_raw
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

</t>
<t tx="tbuttler.20180908232444.1">@raw
  @doc """
@end_raw
An example use of procdir/4

Major device numbers are unique to the file system, and minor numbers are always zero,
*except* when the file is a device (block or character).  Practically, it means we can
use a difference in the major device number of directories to identify a mount point.
"""
@spec procdir(String.t) :: atom
def procdir(path_name) do
  {:ok, %File.Stat{major_device: major}} = File.lstat(path_name)

  proc_entry = fn name, _stat -&gt;
    IO.puts("#{name}")
    true
  end

  # accept all, for this demo
  filter_entry = fn _name -&gt; true end
  procdir(path_name, major, proc_entry, filter_entry)
  wait_until_finished()
end

</t>
<t tx="tbuttler.20180908232512.1">@raw
  @doc """
@end_raw
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
@spec procdir(String.t, integer(), (String.t, %File.Stat{} -&gt; boolean), (String.t -&gt; boolean)) :: atom
def procdir(path_name, major, proc_entry, filter_entry) do
  case :poolboy.checkout(pool_name(), false) do
    # :false above means do not block
    :full -&gt;
      # IO.puts("all threads busy, top continuing with #{path_name}")
      # all threads busy; don't deadlock, just keep going
      ParallelTreeWalk.ProcDir.procdir({path_name, major, proc_entry, filter_entry})

    # todo: change spawn to Node.spawn/4
    pid -&gt;
      spawn(fn -&gt;
        # IO.puts("top invokes pool worker processing #{path_name}")
        try do
          ParallelTreeWalk.Worker.procdir(pid, {path_name, major, proc_entry, filter_entry})
        after
          :ok = :poolboy.checkin(pool_name(), pid)
        end
      end)
  end
end

</t>
<t tx="tbuttler.20180908232939.1">@raw
  @doc """
@end_raw
start_link/1 invoked by :poolboy, a wrapper for :gen_server.start_link/3
"""
@spec start_link([]) :: GenServer.on_start()
def start_link([]) do
  :gen_server.start_link(__MODULE__, [], [])
end

</t>
<t tx="tbuttler.20180908232947.1">@raw
  @doc """
@end_raw
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

</t>
<t tx="tbuttler.20180908232955.1">@raw
  @doc """
@end_raw
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

</t>
<t tx="tbuttler.20180908233001.1">@raw
  @doc """
@end_raw
procdir/2 invoked by :poolboy
"""
@spec procdir(GenServer.server(), {String.t, integer(), (String.t, integer(), fun(), fun() -&gt; boolean), (String.t -&gt; boolean)}) :: term()
def procdir(pid, dir_data) do
  :gen_server.call(pid, dir_data)
end
</t>
<t tx="tbuttler.20180908233156.1">@raw
  @doc """
@end_raw
ParallelTreeWalk.ProcDir.procdir invokes the File.lstat/2 call,
then optionally use the result to prevent crossingmountpoints.
File.lstat/2 is wrapped in ParallelTreeWalk.ProcDir.retry/3 to
skip ephemeral errors.
"""
@spec procdir({String.t, integer(), (String.t, %File.Stat{} -&gt; boolean), (String.t -&gt; boolean)}) :: :ok
def procdir(data = {path_name, major, _proc_entry, _proc_filter}) do
  case retry(fn -&gt; File.lstat(path_name, [{:time, :posix}]) end, 0, 10) do
    {:ok, file_stat} -&gt;
      case file_stat do
        %File.Stat{major_device: ^major} -&gt;
          procdir(data, file_stat)

        %File.Stat{type: :directory} -&gt;
          case major do
            # caller wants to cross file system boundaries
            false -&gt; procdir(data, file_stat)
            _ -&gt; :will_not_cross_mount_points
          end

        _ -&gt;
          # still process device with differing major
          procdir(data, file_stat)
      end

    result -&gt;
      Logger.warn("File.lstat of #{path_name} repeatedly failed: #{inspect(result)}")
      :ok
  end
end

</t>
<t tx="tbuttler.20180908233204.1">@raw
  @doc """
@end_raw
ParallelTreeWalk.ProcDir.procdir/2 invokes the supplied entry processing,
and, in the case that the entry is a directory, recurses into processing
the directory's entries.
"""
@spec procdir({String.t, integer(), (String.t, %File.Stat{} -&gt; boolean), (String.t -&gt; boolean)}, %File.Stat{}) :: atom()
def procdir({path_name, major, proc_entry, proc_filter}, file_stat) do
  case proc_entry.(path_name, file_stat) do
    false -&gt;
      :pruned

    _ -&gt;
      case file_stat do
        %File.Stat{type: :directory} -&gt;
          case retry(fn -&gt; File.ls(path_name) end, 0, 10) do
            # note recursion to top level of module, where pool checkin/checkout occur
            {:ok, entries} -&gt;
              # IO.puts("PTW.ProcDir.procdir/2 with #{path_name} processing #{entries}")
              for entry &lt;- entries, proc_filter.(entry) do
                new_path = Path.join(path_name, entry)
                ParallelTreeWalk.procdir(new_path, major, proc_entry, proc_filter)
              end

            result -&gt;
              Logger.warn("File.ls of #{path_name} repeatedly failed: #{inspect(result)}")
              :ok
          end

        _ -&gt;
          :finished_with_non_directory
      end
  end
end

</t>
<t tx="tbuttler.20180908233215.1"># Attempt, with exponential backoff, to run the
# supplied function.
@spec retry(( -&gt; any), integer(), integer()) :: {:ok, term} | {:error, term}
defp retry(to_retry, count, max) when count &lt; max do
  result = to_retry.()

  case result do
    {:ok, _data} -&gt;
      result

    # milliseconds
    _ -&gt;
      :timer.sleep(1 &lt;&lt;&lt; count)
      retry(to_retry, count + 1, max)
  end
end

</t>
<t tx="tbuttler.20180908233220.1"># When the count has exceeded its max, try one last time.
defp retry(to_retry, _, _) do
  # one last time
  to_retry.()
end
</t>
<t tx="tbuttler.20180908233233.1"># for left shift operator &lt;&lt;&lt;
use Bitwise

</t>
<t tx="tbuttler.20180909002850.2">@language unknown_language
# cargo culted from https://github.com/thestonefox/elixir_poolboy_example/blob/master/mix.exs
defmodule ParallelTreeWalk.Mixfile do
  use Mix.Project

  def project do
    [
      app: :parallel_tree_walk,
      version: "0.0.1",
      elixir: "~&gt; 1.0",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      escript: escript(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [
      mod: {ParallelTreeWalk, []},
      applications: [:logger, :poolboy]
    ]
  end

  def escript do
    [
      main_module: ParallelTreeWalk,
      emu_args: "+SDio 64 +A64"
    ]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~&gt; 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [
      {:poolboy, "~&gt; 1.5"},
      {:dialyxir, "~&gt; 0.5.0", only: [:dev], runtime: false}
    ]
  end
end
</t>
<t tx="tbuttler.20180909003721.1">@raw
  @doc """
@end_raw
Entry point for escript version.

## Arguments
  - args: a list of strings, usually tokenized by invocation from the command line
"""
@spec main(list(String.t)) :: atom
def main(args \\ []) do
  try do
    procdir(List.to_string(args))
  catch
    type, value -&gt;
      IO.puts("Error\n  #{inspect(type)}\n  #{inspect(value)}")
  end
end

</t>
<t tx="tbuttler.20180909022109.1">_build
deps
mix.lock
/parallel_tree_walk
</t>
<t tx="tbuttler.20180915033213.1">@raw
  @doc """
@end_raw
Usually, you don't want to exit or otherwise proceed until the
directory tree processing has finished.  wait_until_finished/0
waits until that is the case, and returns :ok
"""
@spec wait_until_finished() :: atom
def wait_until_finished() do
  # look for 0 allocated poolboy processes
  case :poolboy.status(pool_name()) do
    {_, _, _, 0} -&gt;
      :ok

    _ -&gt;
      :timer.sleep(100)
      wait_until_finished()
  end
end
</t>
<t tx="tbuttler.20181125204114.1">@path lib
</t>
<t tx="tbuttler.20181125204159.1">@path test
</t>
<t tx="tbuttler.20181125204226.2">@language elixir
defmodule ParallelTreeWalkTest do
  use ExUnit.Case

  test "basic traversal works" do
    path_name = "test/dir"
    test_files = ["test/dir", "test/dir/a.txt", "test/dir/b.txt", "test/dir/badlink", "test/dir/c", "test/dir/c/d", "test/dir/c/d/e", "test/dir/c/d/f.txt", "test/dir/goodlink", "test/dir/dirlink"]
    {:ok, %File.Stat{major_device: major}} = File.lstat(path_name)
    filter_entry = fn(_name) -&gt;
      true
    end      # accept all, for this test
    store = :ets.new(:store, [:public])
    proc_entry = fn(name, _stat) -&gt;
      :ets.insert(store, {name, 1})
    end
    ParallelTreeWalk.procdir(path_name, major, proc_entry, filter_entry)
    ParallelTreeWalk.wait_until_finished()
    files = for {n,_} &lt;- :ets.match_object(store, {:_,:_}) do
      n
    end
    :ets.delete(store)
    assert length(files) == 10
    assert Enum.sort(files) == Enum.sort(test_files)
  end

  test "filter works" do
    path_name = "test/dir"
    test_files = ["test/dir", "test/dir/a.txt", "test/dir/b.txt", "test/dir/badlink", "test/dir/goodlink", "test/dir/dirlink"]
    {:ok, %File.Stat{major_device: major}} = File.lstat(path_name)
    filter_entry = fn(name) -&gt;
      name != "c"
    end      # accept all except for name "c", for this test
    store = :ets.new(:store, [:public])
    proc_entry = fn(name, _stat) -&gt;
      :ets.insert(store, {name, 1})
    end
    ParallelTreeWalk.procdir(path_name, major, proc_entry, filter_entry)
    ParallelTreeWalk.wait_until_finished()
    files = for {n,_} &lt;- :ets.match_object(store, {:_,:_}) do
      n
    end
    :ets.delete(store)
    assert length(files) == 6
    assert Enum.sort(files) == Enum.sort(test_files)
  end

end
</t>
<t tx="tbuttler.20181125204226.4">@language elixir
ExUnit.start()

git_wont_track_empty_dir = "test/dir/c/d/e"

File.mkdir(git_wont_track_empty_dir)
</t>
<t tx="tbuttler.20181125204539.1">@path dir
</t>
<t tx="tbuttler.20181125204557.1"></t>
<t tx="tbuttler.20181125204620.1"></t>
<t tx="tbuttler.20181125204627.1"></t>
</tnodes>
</leo_file>
