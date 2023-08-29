---
layout: mathjax
title: "Assignment 1: Big integers"
---

Milestone 1: due Wednesday Sep 6th by 11pm

Milestone 2: due Wednesday Sep 13th by 11pm

Assignment type: **Pair**, you may work with one partner

*Update 8/29*: The original starter code had a mistake in the function header
comments in `uint256.c` for the `uint256_create` and `uint256_get_bits`
functions. Where they referred to "index 3" as the index of the array
element containing the most-significant bits of the representation,
they should actually refer to "index 7."  The starter code has been updated,
but if you downloaded the starter code before it was fixed, you should
apply this change manually.

# Overview

In this assignment, you will implement a simple C library implementation operations
on a 256-bit unsigned integer data type.

This is a substantial assignment! We strongly recommend that you start working
on it as early as possible, and plan to make steady progress rather than waiting
until the last minute to complete it.

To complete the assignment, you will implement a number of C functions,
and you will also write unit tests to test these functions.

## Milestones, grading criteria

The grading breakdown is as follows:

Milestone 1 (15% of the assignment grade):

* Implementation of functions (15%)
    - `uint256_create_from_u32` 
    - `uint256_create` 
    - `uint256_get_bits` 

Milestone 2 (85% of the assignment grade):

* Implementation of functions (65%)
    - `uint256_create_from_hex`
    - `uint256_format_as_hex`
    - `uint256_add`
    - `uint256_sub`
    - `uint256_negate`
    - `uint256_rotate_left` (worth no more than 4% of assignment grade)
    - `uint256_rotate_right` (worth no more than 4% of assignment grade)
* Comprehensiveness and quality of your unit tests (10%)
* Design and coding style (10%)

**Important!** Milestone 1 is intended as a warm-up, since you might not have
written C code in a while. For that reason, it is a very lightweight milestone.
Milestone 2 will require significantly more work.

## Getting started

To get started, download [csf\_assign01.zip](csf_assign01.zip), which contains the
skeleton code for the assignment, and then unzip it.

Note that you can download the zipfile from the command line using the `curl` program:

```bash
curl -O https://jhucsf.github.io/fall2023/assign/csf_assign01.zip
```

Note that in the `-O` option, it is the letter "O", not the numeral "0".

# Unsigned integers

You should be familiar with unsigned integer data types from your previous
experience programming in C and C++. (And, of course, we are covering the properties
of machine-level integer data types in the course.)

In C, the `uint32_t` data type is an unsigned 32-bit integer data type,
and it can represent integer values in the range $$0$$ to $$2^{32}-1$$, inclusive.

In this assignment, you will implement functions implementing operations on
a data type called `UInt256`, which is a 256-bit unsigned integer data type.
Its internal representation contains an array of 8 `uint32_t` values:

```c
typedef struct {
  uint32_t data[8];
} UInt256;
```

The elements of the `data` array are in order from least significant to
most significant. So, element 0 contains bits 0–31,
element 1 contains bits 32–63, etc.

The functions you must implement are declared in the header file `uint256.h`
and defined in the source file `uint256.c`.

## Implementing the functions, testing

Each function has a detailed comment describing the expected behavior.

A unit test program is provided.  Its code is in the source file
`uint256_tests.c`. You can compile the test program by running the
`make` command. So, the following commands will build the test program
and execute it:

```bash
make
./uint256_tests
```

Note that while the unit test program contains some basic tests that you should
find useful, they are by no means comprehensive. So, you should understand
that *you are expected to add your own tests.*  For Milestone 2, part of the
grading criteria includes the comprehensiveness of the tests you write.

**Important restriction**: In your implementation of the functions,
you must not use any data types (or operations on data types)
where the size is greater than 64 bits. For example, using the
`__int128` or `uint128_t` data types is not permitted.

## Hints and tips

**Addition**

To add two `UInt256` values, you should use the "grade school" algorithm
for addition. Treat the elements of the `data` arrays of the values
being added as the "columns" of the addition, starting with the elements
at index 0 (the least significant "column".) Each column of the sum is
the sum of the corresponding column values of the values being added.
*However*, you will need to handle the possibility that the sum of column
values could exceed the range of values that can be represented by
`uint32_t`, in which case you will need to carry a 1 into the next
(more significant) column.

You can determine if the addition of two `uint32_t` values overflows
as follows:

```c
uint32_t leftval = /* some value */,
         rightval = /* some value */,
         sum;

sum = leftval + rightval;
if (sum < leftval) {
  // the addition overflowed
}
```

Note that it is possible that the sum of two `UInt256` values could
overflow the range of values which can be represented. This will happen
if a 1 is carried out of the most significant column. You do not need
to do anything special to handle this possibility. So, for example,
if you add 1 to the maximum `UInt256` value that can be represented,
the result should be 0:

```c
UInt256 max;
for (int i = 0; i < 8; ++i) { max.data[i] = ~(0U); }

UInt256 one = uint256_create_from_u32(1UL);

UInt256 sum = uint256_add(max, one);

// these assertions should succeed
ASSERT(sum.data[7] == 0U);
ASSERT(sum.data[6] == 0U);
ASSERT(sum.data[5] == 0U);
ASSERT(sum.data[4] == 0U);
ASSERT(sum.data[3] == 0U);
ASSERT(sum.data[2] == 0U);
ASSERT(sum.data[1] == 0U);
ASSERT(sum.data[0] == 0U);
```

**Subtraction and negation**

You should implement subtraction as follows. Let's say that `uint256_sub`
needs to compute the difference $$a-b$$. It should implement this subtraction
as $$a + (-b)$$, where $$-b$$ is the two's complement negation of $$b$$.
Recall that the two's complement negation of a bitstring is found by
inverting all of its bits, and then adding 1. The `uint256_negate` function
computes the two's complement negation of a `UInt256` value, and it
will make sense to call this function from `uint256_sub`.

As with addition, you do not need to do anything special to handle the
case where a difference would produce a value that can't be represented
(because it would be negative.)  So, for example, subtracting 1 from 0
should yield a difference that is equal to the maximum value that can
be represented.

**Rotate left and right**

For the `uint256_rotate_left` and `uint256_rotate_right` functions, you
will need to think of a `UInt256` value as being a sequence of 256 bits.

"Rotate" operations are like shifts, in that bits are moved some number of
positions left or right. However, in a shift, when bits are shifted out
of a value, they disappear, and bits shifted in on the other end are
typically 0. In a rotate operation, any bits shifted out on one end are
shifted back in on the other end, so that no bits are lost.

To understand how this works, let's consider an 8 bit value consisting
of the following sequence of bits:

```
01111001
```

In hexadecimal, this value could be represented as

```
79
```

Rotating this value 3 bits to the left would shift out the
three most signifiant bits (011) on the left side, and shift
them back in on the right side, resulting in the bit string

```
11001011
```

which in hexadecimal is

```
CB
```

The original bit string rotated right by 3 positions would shift out the
three least significant bits (001) on the right and shift them back in
on the left side, resulting in the bit string

```
00101111
```

which in hexadecimal is

```
2F
```

These examples illustrate the basic concept of rotations: you will need to figure out how
to implement them for `UInt256` values.

The `uint256_tests.c` program contains a few basic tests demonstrating how
the `uint256_rotate_left` and `uint256_rotate_right` functions are expected to
work.

Note that these functions will probably be the most difficult to implement of all
of the functions in the assignment. You will probably find drawing diagrams on paper
to be useful. Writing good unit tests will be especially important for these
functions.

**Conversion from hex**

When implementing the `uint256_create_from_hex` function, you may assume
that the character string passed as its parameter consists entirely of
hex digits `0`–`9` and `a`-`f`. You do not need to check the string for
invalid characters. However, you should *not* assume that the string's
length is 64 characters or less. If the string has a length greater than
64, only the *rightmost* 64 hex digits should be used in the conversion.

We strongly recommend using the `strtoul` function to convert chunks of
hex digits (up to 8 at a time) to `unsigned long` values. (Note that as
long as you convert no more than 8 hex digits, the converted value is
guaranteed to fit into `uint32_t`.) A possible algorithm is to start with
the rightmost 8 hex digits, convert them (and assign the resulting value
to `data[0]`), and then continue working left (towards the beginning of
the string) until up to 64 hex digits have been converted.

**Conversion to hex**

The `uint256_format_as_hex` function should dynamically allocate (using
`malloc`) a sufficiently large array of `char` elements to store
a string of hex digits representing the value of the `UInt256` value
being converted.  We recommend using the `sprintf` function to convert
a `uint32_t` value to a sequence of hex digits.  For example:

```c
char    *buf = /* buffer w/ room for at least 8 chars plus NUL terminator */;
uint32_t val = /* some value */;

sprintf(buf, "%x", val);   // format without leading 0s

sprintf(buf, "%08x", val); // format with leading 0s
```

You will need to write a loop to make sure that the value of
each element of the `data` array is represented in the resulting hex
string.  Note that the resulting hex string should **not** have
unnecessary leading `0` digits.  In other words, the hex string should have
the minimum number of hex digits needed to represent the
the `UInt256` value.

## Writing tests

You can use the unit tests provided with the assignment skeleton
as a guide for adding your own tests. The basic idea is that
each test function should call functions to perform computations
on `UInt256` values, and then use `ASSERT` to check the resulting
values.

Your unit tests should include as many "corner" cases as possible.
For example:

* adding 0 to a value
* subtracting 0 from a value
* causing an addition to overflow
* causing a subtraction to (negatively) overflow

You can add new tests and assertions to the existing test functions,
but it is probably a good idea to add some completely new test functions
of your own. To add a test function,

1. add a function prototype for it (towards the top of the test program),
2. add a call to the `TEST` macro in the test program's `main` function,
3. implement the test program (somewhere towards the bottom of the test program)

Note that if you omit step 2, your test function will never be executed.

A Ruby script called `genfact.rb` is provided with the starter code.
Running this script will generate an arbitrary arithmetic fact that you
could turn into a unit test. When run without a command line argument,
the script generates an addition, subtraction, or multiplication fact
(chosen randomly.) You can provide the argument `add`. `sub`, or `mul`
to force the generation of an addition, subtraction, or multiplication
fact.

For example, let's say you run `genfact.rb` and it produces the fact

```
50a3b0bc4719744b525c1526194488054b5feaa98f8991d5daade3febd3f2275 + 996fc7bd0d5717312594becc2b92cedeb3da172d39edfa60f3e33d1490066acb = ea13787954708b7c77f0d3f244d756e3ff3a01d6c9778c36ce9121134d458d40
```

This fact could be implemented as a unit test as follows:

```c
UInt256 left, right, result;

  left.data[0] = 0xbd3f2275U;
  left.data[1] = 0xdaade3feU;
  left.data[2] = 0x8f8991d5U;
  left.data[3] = 0x4b5feaa9U;
  left.data[4] = 0x19448805U;
  left.data[5] = 0x525c1526U;
  left.data[6] = 0x4719744bU;
  left.data[7] = 0x50a3b0bcU;
  right.data[0] = 0x90066acbU;
  right.data[1] = 0xf3e33d14U;
  right.data[2] = 0x39edfa60U;
  right.data[3] = 0xb3da172dU;
  right.data[4] = 0x2b92cedeU;
  right.data[5] = 0x2594beccU;
  right.data[6] = 0x0d571731U;
  right.data[7] = 0x996fc7bdU;
  result = uint256_add(left, right);
  ASSERT(0x4d458d40U == result.data[0]);
  ASSERT(0xce912113U == result.data[1]);
  ASSERT(0xc9778c36U == result.data[2]);
  ASSERT(0xff3a01d6U == result.data[3]);
  ASSERT(0x44d756e3U == result.data[4]);
  ASSERT(0x77f0d3f2U == result.data[5]);
  ASSERT(0x54708b7cU == result.data[6]);
  ASSERT(0xea137879U == result.data[7]);
```

## Running and debugging tests

By default running the test program with the invocation `./uint256_tests`
will run each test function in order. However, you can run just one
test function by naming it on the command line. For example, the invocation

```bash
./uint256_tests test_add_2
```

will execute only the `test_add_2` test function.  This is useful when
you are focusing on getting a specific test to pass. Also, because C
is a memory-unsafe language, it's possible for an earlier test to corrupt
the state of the program in a way that could affect the execution of
later tests, so in general running only one test function will produce
a more trustworthy result than running all of the test functions.

If a unit test function fails, you can use `gdb` to debug the test function.
For example, let's say that the unit test `test_add_2` is failing.
Start by invoking `gdb` on the test program:

```bash
gdb ./uint256_tests
```

At the `gdb` prompt, set a breakpoint at the beginning of
`test_add_2`, then run the program:

```
(gdb) break test_add_2
Breakpoint 1 at 0x3d44: file uint256_tests.c, line 203.
(gdb) run test_add_2
Starting program: /home/daveho/git/csf-fall2023-private/src/csf_assign01_solution/uint256_tests test_add_2
test_add_2...
Breakpoint 1, test_add_2 (objs=0x7ffff7fac6a0 <_IO_2_1_stdout_>) at uint256_tests.c:203
203	void test_add_2(TestObjs *objs) {
(gdb) n
211	  left.data[0] = 0x4810cb5eU;
(gdb)
```

At this point, you can use the `next` and `step` commands to execute the
code.  By stepping into the function call associated with the assertion
failure, you can trace the execution and inspect data in order to pinpoint
the cause of the issue.

## Memory correctness

In all C and C++ code you write, we expect that there are no memory errors,
including

* invalid reads
* invalid writes
* uses of uninitialized values
* memory leaks

We expect you to use the [valgrind](https://www.valgrind.org/) memory trace tool
to check program execution for occurrences of memory errors. For this assignment,
run

```bash
valgrind --leak-check=full ./uint256_tests
```

There should be no dynamic memory errors, and assuming that all of
the unit tests pass, there should be no memory leaks.

# Submitting

Before you submit, prepare a `README.txt` file so that it contains your
names, and briefly summarizes each of your contributions to the submission
(i.e., who worked on what functionality.) This may be very brief if you
did not work with a partner.

To submit your work:

Run the following commands to create a `solution.zip` file:

```
rm -f solution.zip
zip -9r solution.zip Makefile *.h *.c README.txt
```

Upload `solution.zip` to [Gradescope](https://www.gradescope.com/)
as **Assignment 1 MS1** or **Assignment 1 MS2**, depending on which
milestone you are submitting.

Please check the files you uploaded to make sure they are the ones you
intended to submit.

## Autograder

When you upload your submission to Gradescope, it will be tested by
the autograder, which executes unit tests for each required function.
Please note the following:

* If your code does not compile successfully, all of the tests will fail
* The autograder runs `valgrind` on your code, but it does *not* report
  any information about the result of running `valgrind`: points will be
  deducted if your code has memory errors or memory leaks!
