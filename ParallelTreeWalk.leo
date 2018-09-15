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
<v t="tbuttler.20180908211411.2"><vh>@clean lib/parallel_tree_walk.ex</vh>
<v t="tbuttler.20180908232353.1"><vh>defp pool_name()</vh></v>
<v t="tbuttler.20180908232425.1"><vh>start(_type, _args)</vh></v>
<v t="tbuttler.20180908232444.1"><vh>procdir(path_name)</vh></v>
<v t="tbuttler.20180908232512.1"><vh>procdir(path_name, major, proc_entry, filter_entry)</vh></v>
<v t="tbuttler.20180909003721.1"><vh>main(_)</vh></v>
<v t="tbuttler.20180915033213.1"><vh>wait_for_empty_poolboy()</vh></v>
</v>
<v t="tbuttler.20180908232152.4"><vh>@clean lib/parallel_tree_walk/worker.ex</vh>
<v t="tbuttler.20180908232939.1"><vh>def start_link([])</vh></v>
<v t="tbuttler.20180908232947.1"><vh>def init(state)</vh></v>
<v t="tbuttler.20180908232955.1"><vh>def handle_call(dir_data, _from, state)</vh></v>
<v t="tbuttler.20180908233001.1"><vh>def procdir(pid, dir_data)</vh></v>
</v>
<v t="tbuttler.20180908232152.2"><vh>@clean lib/parallel_tree_walk/proc_dir.ex</vh>
<v t="tbuttler.20180908233156.1"><vh>procdir(data = {path_name, major, _proc_entry, _proc_filter})</vh></v>
<v t="tbuttler.20180908233204.1"><vh>procdir({path_name, major, proc_entry, proc_filter}, file_stat)</vh></v>
<v t="tbuttler.20180908233233.1"><vh>use Bitwise</vh></v>
<v t="tbuttler.20180908233215.1"><vh>defp retry(to_retry, count, max) when count &lt; max</vh></v>
<v t="tbuttler.20180908233220.1"><vh>defp retry(to_retry, _, _)</vh></v>
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
* ./parallel_tree_walk

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

To Do:

* develop command line processing (or start a separate command line application)
* develop chmod and chown examples

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

  @others
end
</t>
<t tx="tbuttler.20180908232152.2">@language unknown_language
defmodule ParallelTreeWalk.ProcDir do
  require Logger
  
  @others

end
</t>
<t tx="tbuttler.20180908232152.4">@language elixir
defmodule ParallelTreeWalk.Worker do
  use GenServer

  @others
end
</t>
<t tx="tbuttler.20180908232353.1">defp pool_name() do
  :parallel_tree_walk_pool
end

</t>
<t tx="tbuttler.20180908232425.1">def start(_type, _args) do
  poolboy_config = [
    {:name, {:local, pool_name()}},
    {:worker_module, ParallelTreeWalk.Worker},
    {:size, :erlang.system_info(:thread_pool_size)},
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
<t tx="tbuttler.20180908232444.1"># major device numbers are unique to the file system, and minor numbers are always zero,
# *except* when the file is a device (block or character).  Practically, it means we can
# use a difference in the major device number of directories to identify a mount point.
def procdir(path_name) do # /1 example
  {:ok, %File.Stat{major_device: major}} = File.lstat(path_name)
  proc_entry = fn(name, _stat) -&gt;
    IO.puts("#{name}")
    true
  end
  filter_entry = fn(_name) -&gt; true end      # accept all, for this demo
  procdir(path_name, major, proc_entry, filter_entry)
  wait_for_empty_poolboy()
end

</t>
<t tx="tbuttler.20180908232512.1">def procdir(path_name, major, proc_entry, filter_entry) do # /4 version
  case :poolboy.checkout(pool_name(), :false) do
    # :false above means do not block
    :full -&gt;
      # all threads busy; don't deadlock, just keep going
      ParallelTreeWalk.ProcDir.procdir({path_name, major, proc_entry, filter_entry})
    # todo: change spawn to Node.spawn/4
    pid   -&gt; spawn(fn() -&gt;
        try do
          ParallelTreeWalk.Worker.procdir(pid, {path_name, major, proc_entry, filter_entry})
        after
          :poolboy.checkin(pool_name(), pid)
        end
      end)
  end
end

</t>
<t tx="tbuttler.20180908232939.1">def start_link([]) do
  :gen_server.start_link(__MODULE__, [], [])
end

</t>
<t tx="tbuttler.20180908232947.1">def init(state) do
  {:ok, state}
end

</t>
<t tx="tbuttler.20180908232955.1">def handle_call(dir_data, _from, state) do
  ParallelTreeWalk.ProcDir.procdir(dir_data)
  {:reply, [], state}
end

</t>
<t tx="tbuttler.20180908233001.1">def procdir(pid, dir_data) do
  :gen_server.call(pid, dir_data)
end
</t>
<t tx="tbuttler.20180908233156.1">def procdir(data = {path_name, major, _proc_entry, _proc_filter}) do
  case retry(fn() -&gt; File.lstat(path_name) end, 0, 10) do
    {:ok, file_stat} -&gt;
      case file_stat do
        %File.Stat{major_device: ^major} -&gt;
          procdir(data, file_stat)
        %File.Stat{type: :directory}     -&gt;
          case major do
            false -&gt; procdir(data, file_stat) # caller wants to cross file system boundaries
            _     -&gt; :will_not_cross_mount_points
          end
        _                                -&gt;
          procdir(data, file_stat) # still process device with differing major
      end
    result           -&gt;
      Logger.warn("File.lstat of #{path_name} repeatedly failed: #{inspect(result)}")
  end    
end

</t>
<t tx="tbuttler.20180908233204.1">def procdir({path_name, major, proc_entry, proc_filter}, file_stat) do
  case proc_entry.(path_name, file_stat) do
    :false -&gt; :pruned
    _      -&gt;
      case file_stat do
      %File.Stat{type: :directory} -&gt;
        case retry(fn() -&gt; :file.list_dir_all(path_name) end, 0, 10) do
          # note recursion to top level of module, where pool checkin/checkout occur
          {:ok, entries} -&gt;
            for entry &lt;- entries, proc_filter.(entry), do:
              ParallelTreeWalk.procdir(Path.join(path_name,entry), major, proc_entry, proc_filter)
          result         -&gt;
            Logger.warn(":file.list_dir_all of #{path_name} repeatedly failed: #{inspect(result)}")
        end
      _ -&gt; :finished_with_non_directory
    end
  end
end

</t>
<t tx="tbuttler.20180908233215.1">defp retry(to_retry, count, max) when count &lt; max do
  result = to_retry.()
  case result do
    {:ok, _data} -&gt; result
    _            -&gt; :timer.sleep(1 &lt;&lt;&lt; count) # milliseconds
                    retry(to_retry, count+1, max)
  end
end

</t>
<t tx="tbuttler.20180908233220.1">defp retry(to_retry, _, _) do
  # one last time
  to_retry.()
end
</t>
<t tx="tbuttler.20180908233233.1">use Bitwise # for left shift operator &lt;&lt;&lt;

</t>
<t tx="tbuttler.20180909002850.2">@language unknown_language
# cargo culted from https://github.com/thestonefox/elixir_poolboy_example/blob/master/mix.exs
defmodule ParallelTreeWalk.Mixfile do
  use Mix.Project

  def project do
    [app: :parallel_tree_walk,
     version: "0.0.1",
     elixir: "~&gt; 1.0",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     escript: escript(),
     deps: deps()]
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
    [main_module: ParallelTreeWalk]
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
      {:poolboy, "~&gt; 1.5"}
    ]
  end

end
</t>
<t tx="tbuttler.20180909003721.1">def main(_) do
  procdir(".")
end

</t>
<t tx="tbuttler.20180909022109.1">_build
deps
mix.lock
/parallel_tree_walk
</t>
<t tx="tbuttler.20180915033213.1">defp wait_for_empty_poolboy() do
  case :poolboy.status(pool_name()) do
  {_, _, _, 0} -&gt; :ok
  _            -&gt; :timer.sleep(10)
                  wait_for_empty_poolboy()
  end
end

</t>
</tnodes>
</leo_file>
