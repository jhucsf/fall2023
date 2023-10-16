---
layout: default
title: "Assignment 3: Cache simulator"
---

**Due**:

* Milestone 1: Wednesday, October 11th (no late hours)
* Milestone 2: Wednesday, October 25th by 11pm (max 48 late hours)
* Milestone 3: Wednesday, November 1st by 11pm

Assignment type: **Pair**, you may work with one partner

**Late hour usage**: If you anticipate using more than 48 late hours
on Milestone 3, please post privately (to instructors and TAs) on Piazza
to request permission. Note that late hours may *not* be used on
Milestone 1, and at most 48 late hours may be used on Milestone 2.

# Cache simulator

**Acknowledgment**: This assignment was originally developed by
[Peter Fröhlich](https://www.cs.jhu.edu/~phf) for [his version of
CSF](https://www.cs.jhu.edu/~phf/2018/fall/cs229).

This problem focuses on simulating and evaluating
[caches](https://en.wikipedia.org/wiki/Cache_(computing)). We’ll give
you a number of **memory traces** from real benchmark programs. You’ll
implement a program to **simulate** how a variety of caches perform on
these traces. You’ll then use your programs and the given traces to
determine the **best overall cache configuration**.

## Milestone 1 (5 points)

For this submission, you must have started working on
your code and have at least one submission uploaded to
[Gradescope](https://www.gradescope.com).

A good idea would be to make sure that parsing command-line options and
reading traces works correctly.  Getting some of the core data structures
and functions in place to do the actual cache simulation would also be a
great idea, even if they're not fully implemented yet.

## Milestone 2 (15 points)

For this submission, you must have implemented your cache simulation for LRU.

## Milestone 3 (80 points)

All functions must be written with full assignment specifications met.

## Grading criteria

Milestone grades will be determined as a combination of effort and code
functionality. Your final grade will be determined as follows:

* Gracefully handling invalid parameters: 1.5%
* Accurate load count: 9%
* Accurate store count: 9%
* Accurate load hits: 12.5%
* Accurate load misses: 12.5%
* Accurate store hits: 12.5%
* Accurate store misses: 12.5%
* Accurate total cycles: 5.5%
* Report on best cache: 10%
* Design, coding style, and contributions: 10%
* Effort shown in Milestone 1: 5%

For the numeric results, the `Total cycles` output only needs to be
within &plusmn;10%, while the other results must be exact.

Make sure you follow the [style guidelines](style.html).

Your program should execute without memory errors or memory leaks.
Memory errors such as invalid reads or write, or uses of uninitialized
memory, will result in a deduction of up to 10 points.  Memory leaks
will result in a deduction of up to 5 points.

## Programming Languages

You can use either C or C++ for this assignment. You’re allowed to use
the **standard** library of your chosen language as much as you would
like to, but you are **not** allowed to use any additional
(non-standard) libraries.

One advantage of choosing C++ is that you can use the built-in
container data structures such as `map`, `vector`, etc.
(Note however that it is entirely possible to create a straightforward
and robust implementation of this program using dynamically-allocated
arrays.) Regardless of which language you use, we highly encourage you to
write modular, well-designed code, and to develop data types and
functions to manage the complexity of the program.  Strive for simplicity.

You must provide a `Makefile` such that

* `make clean` removes all object files and executables, and
* `make` or `make csim` compiles and links your program, producing an executable called `csim`

Your code should compile cleanly with gcc 7.x using the `-Wall -Wextra -pedantic` compiler flags.
**Important**: your `Makefile` **must** use these options.  If your `Makefile`
does *not* compile your code with these options, you will forfeit all of
the points for design and coding style.

## Part (a): Cache Simulator

You will design and implement a **cache simulator** that can be used to
study and compare the effectiveness of various cache configurations.
Your simulator will read a **memory access trace** from standard input,
simulate what a cache based on certain parameters would do in response
to these memory access patterns, and finally produce some summary
statistics to standard output. Let’s start with the file format of the
memory access traces:

    s 0x1fffff50 1
    l 0x1fffff58 1
    l 0x1fffff88 6
    l 0x1fffff90 2
    l 0x1fffff98 2
    l 0x200000e0 2
    l 0x200000e8 2
    l 0x200000f0 2
    l 0x200000f8 2
    l 0x30031f10 3
    s 0x3004d960 0
    s 0x3004d968 1
    s 0x3004caa0 1
    s 0x3004d970 1
    s 0x3004d980 6
    l 0x30000008 1
    l 0x1fffff58 4
    l 0x3004d978 4
    l 0x1fffff68 4
    l 0x1fffff68 2
    s 0x3004d980 9
    l 0x30000008 1

As you can see, each memory access performed by a program is recorded on
a separate line. There are three “fields” separated by white space. The
first field is either `l` or `s` depending on whether the processor is
“loading” from or “storing” to memory. The second field is a 32-bit
memory address given in hexadecimal; the `0x` at the beginning means
“the following is hexadecimal” and is not itself part of the address.
You can **ignore** the third field for this assignment.

Note that you should assume that each load or store in the trace accesses
at most 4 bytes of data, and that no load or store accesses data which spans
multiple cache blocks (a.k.a. "lines".)

Your cache simulator will be configured with the following cache design
parameters which are given as command-line arguments (see below):

  - number of sets in the cache (a positive power-of-2)
  - number of blocks in each set (a positive power-of-2)
  - number of bytes in each block (a positive power-of-2, at least 4)
  - `write-allocate` or `no-write-allocate`
  - `write-through` or `write-back`
  - `lru` (least-recently-used) or `fifo` evictions

Note that certain combinations of these design parameters account for
direct-mapped, set-associative, and fully associative caches:

  - a cache with n sets of 1 block each is direct-mapped
  - a cache with n sets of m blocks each is m-way set-associative
  - a cache with 1 set of n blocks is fully associative

The smallest cache you must be able to simulate has 1 set with 1 block
with 4 bytes; this cache can only remember a single 4-byte memory
reference and nothing else; it can therefore only be beneficial if
consecutive memory references in a trace go to the exact same address.
**You should probably use this tiny cache for basic sanity testing.**

A few reminders about the other three parameters: The **write-allocate**
parameter determines what happens for a **cache miss** during a
**store**:

  - for `write-allocate` we bring the relevant memory block into the
    cache *before* the store proceeds
  - for `no-write-allocate` a cache miss during a store does *not*
    modify the cache  

Note that this parameter interacts with the following one. The
**write-through** parameter determines whether a store **always** writes
to memory **immediately** or not:

  - for `write-through` a store writes to the cache as well as to memory
  - for `write-back` a store writes to the cache *only* and marks the
    block *dirty*; if the block is evicted later, it has to be written
    back to memory before being replaced

**It doesn’t make sense to combine `no-write-allocate` with `write-back`
because we wouldn’t be able to actually write to the cache for the
store\!**

The last parameter is only relevant for associative caches: in
direct-mapped caches there is no choice for which block to evict\!

  - for `lru` (least-recently-used) we evict the block that has not been
    **accessed** the longest
  - for `fifo` (first-in-first-out) we evict the block that has been
    **in the cache** the longest

Your cache simulator should assume that loads/stores from/to the cache
take **one** processor cycle; loads/stores from/to memory take **100**
processor cycles for **each** 4-byte quantity that is transferred. There
are plenty of things about caches in real processors that you do **not**
have to simulate, for example write buffers or smart ways to fill cache
blocks; implementing all the options above correctly is already somewhat
challenging, so we’ll leave it at that.

We expect to be able to run your simulator as follows:

`./csim 256 4 16 write-allocate write-back lru < sometracefile`

This would simulate a cache with 256 sets of 4 blocks each (aka a 4-way
set-associative cache), with each block containing 16 bytes of memory;
the cache performs write-allocate but no write-through (so it does
write-back instead), and it evicts the least-recently-used block if it
has to. (As an aside, note that this cache has a total size of 16384
bytes (16 kB) if we ignore the space needed for tags and other
meta-information.)

After the simulation is complete, your cache simulator is expected to
print the following summary information in **exactly** the format given
below:

<div class="highlighter-rouge"><pre>
Total loads: <i>count</i>
Total stores: <i>count</i>
Load hits: <i>count</i>
Load misses: <i>count</i>
Store hits: <i>count</i>
Store misses: <i>count</i>
Total cycles: <i>count</i>
</pre></div>

The <tt><i>count</i></tt> value is simply an occurrence count.  As a concrete example,
here is an example invocation of the program on one of the example traces, `gcc.trace`:

```
./csim 256 4 16 write-allocate write-back fifo < gcc.trace
```

This invocation should produce the following output:

```
Total loads: 318197
Total stores: 197486
Load hits: 314171
Load misses: 4026
Store hits: 188047
Store misses: 9439
Total cycles: 9845283
```

Note that due to slight variations in how you might reasonably interpret the
simulator specification, your `Total cycles` value could be slightly different,
but should be fairly close.  For all of the other counts, your simulator's
output should exactly match the output above.

We **strongly** encourage you to use Piazza to post traces and simulator results,
so that you can compare your results with other students' results.

### Reporting invalid cache parameters

Before starting the simulation, your simulator should check to make sure
that the simulation parameters are reasonable.  Examples of invalid
configuration parameters include (but are not limited to):

* block size is not a power of 2
* number of sets is not a power of 2
* block size is less than 4
* `write-back` and `no-write-allocate` were both specified

If the configuration parameters are invalid, the program should

1. Print an error message to `stderr` or `std::cerr`, and
2. Exit with a non-zero exit code

### Example traces

Here are some traces you can use for testing and empirical evaluation:

* [gcc.trace](assign03/gcc.trace)
* [read01.trace](assign03/read01.trace)
* [read02.trace](assign03/read02.trace)
* [read03.trace](assign03/read03.trace)
* [swim.trace](assign03/swim.trace)
* [write01.trace](assign03/write01.trace)
* [write02.trace](assign03/write02.trace)

Your can download these trace files easily from the command line using
`curl`, e.g.

```
curl -O https://jhucsf.github.io/fall2023/assign/assign03/read01.trace
```

(Note that in the `-O` option, it's the upper case letter "O", not the
digit "0".)

`gcc.trace` and `swim.trace` are traces from real programs, so you should
consider using them in your empirical evaluation.

### Hints

Your simulation is only concerned with hits and misses, at no point do
you need the **actual** data that’s stored in the cache; that’s the
reason why the trace files do not contain that information in the first
place.

Don’t try to implement all the options right away, start by writing a
simulator that can only run direct-mapped caches with write-through and
no-write-allocate. Once you have that working, extend step-by-step to
make the other design parameters work. Also, sanity-check your simulator
frequently with simple, hand-crafted traces for which you can still
derive manually what the behavior should be.

Note that accurate cycle counting is only worth 6% of the total assignment
grade.  Make sure that loads and stores are modeled correctly with accurate
hit and miss counts before being too concerned about counting cycles.

### Part (b): Best cache, contributions

For part (b), you’ll use the memory traces as well as your
simulator to determine which cache configuration has the **best overall
effectiveness**. You should take a variety of properties into account:
hit rates, miss penalties, total cache size (including overhead), etc.
In your `README.txt`, describe in detail what experiments you ran (and
why\!), what results you got (and how\!), and what, in your opinion, is
the best cache configuration of them all.

Finally, you will write a brief summary of how you divided up the work
between partners and what each person contributed. This section is not
required if you worked alone.

### Credits

The memory traces above come from a similar programming assignment by
Steven Swanson at the University of California, San Diego. Thank you
Steven\!

## Submitting

For each milestone submission, create a zipfile that has your `Makefile`,
source and header files, and `README.txt` file. All of the files should
be in the top level directory of the zipfile. As an example, if your
zipfile is called `assign3.zip`, the command `unzip -l assign3.zip`
might produce the following output:

```
Archive:  assign3.zip
  Length      Date    Time    Name
---------  ---------- -----   ----
    15225  2020-02-25 12:27   main.c
      149  2020-02-25 12:27   Makefile
    12075  2020-02-25 12:28   README.txt
---------                     -------
    27449                     3 files
```

Your exact output will almost certainly differ, for example, depending on
how you structured your cache simulator program.

Upload your zipfile to [Gradescope](https://www.gradescope.com) as **Assignment 3 MS1**,
**Assignment 3 MS2**, or **Assignment 3 MS3** as appropriate (depending on the milestone).
