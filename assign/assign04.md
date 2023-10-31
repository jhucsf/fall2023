---
layout: default
title: "Assignment 4: Parallel merge sort"
---

**Due**: Friday, November 10th by 11 pm

Assignment type: **Pair**, you may work with one partner

## Getting started

Download [csf\_assign04.zip](csf_assign04.zip) and unzip it.

You will modify the code in the `parsort.c` source file. You can compile
the program using the provided `Makefile`.  To run the program,
the invocation is

<div class="highlighter-rouge"><pre>
./parsort <i>filename</i> <i>threshold</i>
</pre></div>

where *filename* is the file containing the data to sort, and *threshold*
is the number of elements below (inclusive) which the program should use a
sequential sort.

## Grading criteria

Your assignment grade will be determined as follows:

* Sequential sorting using `qsort`: 20%
* Parallel sorting using subprocesses: 50%
* Experiments and report: 15%
* Error reporting: 5%
* Design and coding style: 10%

## Your task

Your task is to write a program that will sort 64-bit signed integers
(stored in a file in little-endian binary format), using a variation
of [Merge sort](https://en.wikipedia.org/wiki/Merge_sort), *modifying*
the data in the file so that the original data values are in sorted order
from least to greatest.

In addition,

* you will *parallelize* the computation with a *fork/join* style computation
  using child processes, and
* your program will access the file data using memory-mapped file I/O

This might sound complicated! Fortunately, this program can be implemented
quite easily in about 200 lines of C code.

### Fork/join computation

The [fork/join](https://en.wikipedia.org/wiki/Fork%E2%80%93join_model) model
of parallel computation is a technique for parallelizing divide and conquer
algorithms.

The outline of a fork/join computation is the following:

```
if (problem is small enough)
  solve the problem sequentially
else {
  in parallel {
    solve the left half of the problem
    solve the right half of the problem
  }
  combine the solutions to the left/right halves of the problem
}
```

In the case of merge sort, a fork/join approach will look something
like this:

```
if (number of elements is at or below the threshold)
  sort the elements sequentially
else {
  in parallel {
    recursively sort the left half of the sequence
    recursively sort the right half of the sequence
  }
  merge the sorted sequences into a temp array
  copy the contents of the temp array back to the original array
}
```

In your program, "sort the elements sequentially" should be delegated to the
[qsort function](https://man7.org/linux/man-pages/man3/qsort.3.html).

Recursively sorting in parallel can be implemented by using
[fork](https://man7.org/linux/man-pages/man2/fork.2.html) two times to create two
child processes, and having each one recursively sort half of
the array. (This will work because the data to be sorted will
be accessed as a memory-mapped file that can be shared by all
of the processes.) Note that the `merge_sort` function provided in
the starter code is already a correct implementation of the sequential
merge sort algorithm. You will just need to modify it to use
child processes to do the recursive sorting in parallel.

<!--
Merging the elements sequentially can be implemented using
a function call to a `merge` function. An implementation of this
function is provided in the starter code. We will also note that
the solution to the in-class assembly language exercise available
in the Canvas files area has a full C implementation of merge sort
that you can use as a reference. (It's fine to copy code from
this implementation, but note that you will likely need to adapt it
significantly.)
-->

### Memory-mapped file I/O

The [mmap](https://man7.org/linux/man-pages/man2/mmap.2.html) system call allows
a process to map file data into its address space. If the process
passes the `PROT_READ|PROT_WRITE` options for the *prot* argument and
`MAP_SHARED` option to the *options* argument, then any modifications
the process makes to the memory within the file mapping will be written
back to the actual file. Since descendants created with `fork()` share their
initial memory space with their parent, the file only needs to be mmap'ed into
memory once so long as each child works on a different region of mapped memory.

Let's say that you want to map the contents of a file into memory so you can sort it.
First, you will need to use the [open](https://man7.org/linux/man-pages/man2/open.2.html)
syscall to open the file in read-write mode and get a file descriptor:

```c
int fd = open(filename, O_RDWR);
if (fd < 0) {
  // file couldn't be opened: handle error and exit
}
```

Next, `mmap` will need to know how many bytes of data the file has. This can be
accomplished using the [fstat](https://man7.org/linux/man-pages/man3/fstat.3p.html) system
call:

```c
struct stat statbuf;
int rc = fstat(fd, &statbuf);
if (rc != 0) {
    // handle fstat error and exit
}
size_t file_size_in_bytes = statbuf.st_size;
```

Once the program knows the size of the file, creating a shared read-write mapping will
allow the program, and all its descendants, to modify the file in-place in memory:

```c
int64_t *data = mmap(NULL, file_size_in_bytes, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0)
// you should immediately close the file descriptor here since mmap maintains a separate
// reference to the file and all open fds will gets duplicated to the children, which will
// cause fd in-use-at-exit leaks.
// TODO: call close()
if (data == MAP_FAILED) {
    // handle mmap error and exit
}
// *data now behaves like a standard array of int64_t. Be careful though! Going off the end
// of the array will silently extend the file, which can rapidly lead to disk space
// depletion!
```

Passing in `NULL` for the requested mapping address gives `mmap` complete freedom to
choose any address in memory to map. Since we don't care where the file ends up in memory,
so long as we can access it, this is what we want. Similarly, we want to map the
entire file, so we set the offset to zero.

Note: Don't forget to call [munmap](https://man7.org/linux/man-pages/man2/mmap.2.html) and
[close](https://man7.org/linux/man-pages/man2/close.2.html) before returning from the
topmost process in your program before returning to prevent leaking resources. Note that
closing a file descriptor _does not_ `unmap` the memory; both calls must be used.

### Creating child processes

The `fork()` call can be used to spawn child processes from the current process. The child
will start executing at the point of the fork call, and will share its initial memory
space with the parent. Recall that the fork call will always return the `pid` zero to the
newly started subprocess, and the actual `pid` to the parent process:

```c
pid_t pid = fork()
if (pid == -1) {
    // fork failed to start a new process
    // handle the error and exit
} else if (pid == 0) {
    // this is now in the child process
}
// if pid is not 0, we are in the parent process
// WARNING, if the child process path can get here, things will quickly break very badly
```

You must make sure that the child branch exits after it has completed its work. Failure to
make the child exit will allow it to continue executing through the parent's code path,
which will lead to memory corruption and other difficult-to-debug behaviors. We highly
recommend that you hand over control to a function and exit the child process immediately
afterwards:

```c
if (pid == 0) {
    int retcode = do_child_work();
    exit(retcode);
    // everything past here is now unreachable in the child
}
```

To pause program execution until a child process has completed, we recommend using the
[waitpid](https://man7.org/linux/man-pages/man3/wait.3p.html) call:

```c
int wstatus;
// blocks until the process indentified by pid_to_wait_for completes
pid_t actual_pid = waitpid(pid_to_wait_for, &wstatus, 0);
if (actual_pid == -1) {
    // handle waitpid failure
}
```

The `wstatus` argument provides an opaque handle that can be used with special macros to
query information about the how the subprocess exited. The `WIFEXITED(wstatus)` macro
will evaluate to a true value if the subprocess exited normally, and the
`WEXITSTATUS(wstatus)` macro can be used to retrieve the return code that the subprocess
exited with:

```c
if (!WIFEXITED(wstatus)) {
    // subprocess crashed, was interrupted, or did not exit normally
    // handle as error
}
if (WEXITSTATUS(wstatus) != 0) {
    // subprocess returned a non-zero exit code
    // if following standard UNIX conventions, this is also an error
}
```

Thus, the subprocess can notify its parent if its operation succeeded by returning a suitable
return code. Remember to propagate error conditions up to the topmost process so it can
report that the sort job failed using a non-zero error code.

Note: You must wait on every new process you start. This means that every fork call should
have a corresponding `waitpid` call. Failure to due this in a long-running process creates
a "pid leak", and can lead to pid exhaustion and the inability to start any new processes
on the system due to the accumulation of the "zombie processes" (yes this is the technical
term). While the kernel and the `init` process will clean up your zombies after the
topmost process exits, it is a good practice to ensure that you promptly deal with zombie
processes in your program. We will be manually checking your code to ensure that you don't
leave zombies around while your program executes.

### Handling errors

If the `parsort` program encounters an error, it should print a message
of the form

<div class='highlighter-rouge'><pre>
Error: <i>explanation</i>
</pre></div>

to the standard error stream (i.e., `stderr`), and exit with a non-zero exit code.

Examples of errors that should be handled are:

* failure to open the file with the integers to be sorted
* failure to `mmap` the file data
* failure to create a child process using `fork`
* a child process not exiting normally, or exiting with a non-zero exit code
* failure of the "top-level" process to `munmap` the file data and
  `close` the file

### Generating test data, running the program

You can create some random test data using the `gen_rand_data` executable we have included
in the starter code:

```
make gen_rand_data
./gen_rand_data [size] [output filename]
```

For instance, to generate 1000 integers, you can use:

```
./gen_rand_data 8000 test.in
```

which will generate 8000 bytes of data (1000 `int64`s) and place it in a file called
`test.in`. Be sure that your specified size is a multiple of 8 so that your `parsort` and
`is_sorted` programs will function correctly!

You can also use the `M` suffix on the *size* argument to specify the output file
size in megabytes. For example, the following command would create a file
`/tmp/test_1M.in` with 131,072 8-byte integer values:

```
./gen_rand_data 1M /tmp/test_1M.in
```

We suggest using the `/tmp` directory (the system temporary directory) to create your test
files to prevent accumulating many small test files alongside your assignment, and to
avoid interactions with the network file server that might affect the performance
of the program. However, if you do decide to use `/tmp` please note the following points:

* `/tmp` is shared amongst all users of the system, so you should probably create a
  subfolder that will be reasonably unique to you so you don't accidentally overwrite
  someone else's file.
* `/tmp` is local to the current machine. E.g. `/tmp` on ugrad1 is independent of `/tmp`
  on ugrad2.
* Since `/tmp` is shared, you **must ensure** that you set file permissions correctly on
  your created directory (`chmod -R 700 /tmp/mydir`). You should also keep your actual
  implementation out of `/tmp`.
* You must not create every large files in `/tmp` and you must ensure that you delete
  everything you leave there _before logging off_.

If you create a few files that are no more than, say, 16 megabytes in size, and if you
clean them up properly before logging out, you should be fine.

To check that your sort program works correctly, you can use the `is_sorted` program we have
included in the starter code:

```
# generate the file with 1000 integers
./gen_rand_data 8000 test.in
# sort the file
./parsort data.in 500
# verify that the file is sorted correctly
make is_sorted
./is_sorted data.in
```

If the file is correctly sorted, `is_sorted` will print "`Data values are sorted!`",
otherwise, it will print an informative error message.

Remember that you are writing a parallel program that can consume resources at an
exponential rate. If you are working on a shared system (e.g. the ugrad machines), you
must ensure that you test in a responsible manner. If your program appears to be frozen,
or taking an inordinate amount of time, you must immediately terminate it. You should
test your program on small inputs first, before moving on to larger ones to contain the
blast radius of any potential programming mistakes that you might have made. Do not
suspend your program using `ctrl-z`; you must use `ctrl-c` to ensure that the entire
process tree receives an interrupt signal and is terminated. Estimate the number of
processes that your program will attempt to spawn with the given parameters before running
the command. You should never try spawning more than a hundred processes at your highest
limits on a shared system, and far fewer if they are expected to be long-running
processes.

You can collect timing info for a given command be prefixing it with the time command:

```
time ./parsort test.in 1000
```

This will report your timing information in the following format:

```
real    0m0.010s
user    0m0.002s
sys     0m0.001s
```

You should use the `real` time reported to get the total wall-clock time your program
takes, since the other times will serialize the time taken across all descendants. Since
this will be very sensitive to system load, you should run each experiment multiple times,
and eliminate any clear outliers before including a result in your report. You should also
do you best to run your experiment when the host system is at low load (you can find the
current load by using the `top` command). You will need to tweak the amount of data you
test against until you are able to distinguish results between different threshold values
on the same data size.

### Hints and tips

Ensure that only the topmost process (i.e. the first process executed) ever attempts to
open the file, map memory, and carry out cleanup. Attempting `munmap()` the file multiple
times will lead to crashes and other unpredictable behaviour.

We highly recommend that you follow the guidance in the starter code and implement your
program in C. Using C++ will make this assignment significantly harder.

### Experiments and analysis

To make sure that your `parsort` program is exhibiting the expected degree of
parallelism, we would like you to perform an experiment where you create
a random data file of 16 megabytes in size, and then time sorting this file
multiple times, while adjusting the threshold to achieve increasing amounts
of parallel execution.

You should run the following commands:

```
make clean
make
mkdir -p /tmp/$(whoami)
./gen_rand_data 16M /tmp/$(whoami)/data_16M.in
cp /tmp/$(whoami)/data_16M.in /tmp/$(whoami)/test_16M.in
time ./parsort /tmp/$(whoami)/test_16M.in 2097152 
cp /tmp/$(whoami)/data_16M.in /tmp/$(whoami)/test_16M.in
time ./parsort /tmp/$(whoami)/test_16M.in 1048576
cp /tmp/$(whoami)/data_16M.in /tmp/$(whoami)/test_16M.in
time ./parsort /tmp/$(whoami)/test_16M.in 524288
cp /tmp/$(whoami)/data_16M.in /tmp/$(whoami)/test_16M.in
time ./parsort /tmp/$(whoami)/test_16M.in 262144
cp /tmp/$(whoami)/data_16M.in /tmp/$(whoami)/test_16M.in
time ./parsort /tmp/$(whoami)/test_16M.in 131072
cp /tmp/$(whoami)/data_16M.in /tmp/$(whoami)/test_16M.in
time ./parsort /tmp/$(whoami)/test_16M.in 65536
cp /tmp/$(whoami)/data_16M.in /tmp/$(whoami)/test_16M.in
time ./parsort /tmp/$(whoami)/test_16M.in 32768
cp /tmp/$(whoami)/data_16M.in /tmp/$(whoami)/test_16M.in
time ./parsort /tmp/$(whoami)/test_16M.in 16384
rm -rf /tmp/$(whoami)
```

The `parsort` commands start with a completely sequential sort,
and then tests with increasing degrees of parallelism.
For example, at the smallest threshold of 16384 elements, there
will be 128 processes doing sequential sorting at the
base cases of the recursion.

We have provided a shell script called `run_experiments.sh` which
runs these commands, so to collect your experimental data you could
just run the command

```
./run_experiments.sh
```

We suggest using one of the numbered ugrad machines (ugrad1.cs.jhu.edu
to ugrad24.cs.jhu.edu) to do your experiment. When you log in, you can
run the `top` command to see what processes are running. (Note that you
can type `q` to exit from `top`.) If any processes
are consuming significant CPU time, you should consider logging into
a different system, until you find one where no processes are consuming
significant CPU time.

When you run the commands, copy the output of the `time` command. The
`real` time will indicate the amount of time that elapsed between when
the program started and exited, which is a pretty good measure of
how long the sorting took.  You *should* see that decreasing the
threshold decreased the total time, although depending on the number
of CPU cores available, eventually a point of dimimishing returns
will be reached.

In your `README.txt`, write a brief report which

1. Indicates the amount of time that your `parsort` program took
   so sort the test data for each threshold value, and
2. States a reasonable explanation for *why* you saw the times you did

For \#2, think about how the computation unfolds, and in particular,
what parts of the computation are being executed in different processes,
and thus which parts of the computation could be scheduled by the
OS kernel in parallel on different CPU cores. We don't expect a completely
rigorous and in-depth explanation, but we *would* like you to
give an intuitive explanation for the results that you observed.


### Note on the autograder

Passing the autograder will be a necessary but insufficient condition for full credit.
This means that you may still lose functionality points, even if you pass all of the
autograder tests. Due to the nature of testing parallel programs, there  will be a
significant number of points up for manual review, so please structure your code
accordingly. Some of the things we may manually verify (bot not limited to) are:

* Ensuring that your implementation is actually parallel. (Your
  [experiments](#experiments-and-analysis) should have already allowed you to
  determine whether your program is exhibiting any parallel speedup.)
* Ensuring that you did not leave zombies around during execution.
* Ensuring that the correct number of children are created for a given threshold
  and data size value.

## Submitting

Edit the `README.txt` file to include the report and summarize each team member's contributions.

You can create a zipfile of your solution using the command `make solution.zip`.

Submit your zipfile to Gradescope as **Assignment 4**.
