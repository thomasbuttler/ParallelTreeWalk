Library to visit the files in a directory tree
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
* iex(1)> ParallelTreeWalk.procdir(".")
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
[FixId](https://github.com/thomasbuttler/FixId): a chown/chgrp utitlity

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

