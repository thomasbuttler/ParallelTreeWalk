# ParallelTreeWalk
Library to visit the files in a directory tree

This library is intended for use with
* POSIX compatible directory trees
* *UNORDERD* access to files
* *idempotent* operations on files (i.e., the same operation can be done one *or more* times, and still get the same result; e.g., "change owner bin to owner root"; e.g., *NOT* "change owner bin to owner root; change owner daemon to owner bin")
* input bound processing: the underying Erlang virtual machine should be invoked with something like +A32 because your processing is spending its time in each of those threads idle waiting for the file server to respond.
