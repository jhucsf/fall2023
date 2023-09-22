---
layout: default
title: "Assignment 2: Word count"
---

Milestone 1: Due Monday, Sep 25th by 11 pm

Milestone 2: Due Thursday, Oct 5th by 11 pm

*Update 9/21*: Corrected pseudo-code for main input loop of `main` function.
(It should be calling `wc_dict_find_or_insert`, not
`wc_find_or_insert`.)

*Update 9/21*: Updated the restrictions on library function calls to
explicitly allow calls to `malloc` and `free` in `main`, for the purposes
of allocating and deallocating the hash table array.

# Overview

In this assignment, you will implement a *word count* program in both
C and x86-64 assembly language. The word count program is supported by
a number of functions which you will implement in both C and assembly
language. Unit tests are provided to test both the C and assembly language
implementations of these functions: these tests allow you to work on
the functions one at a time and gain confidence that they work correctly
before incorporating them into the overall program. (We encourage you
to write additional unit tests as well, since the provided tests are
somewhat basic.)

This is a substantial assignment! We strongly recommend that you start working
on it as early as possible, and plan to make steady progress rather than waiting
until the last minute to complete it.

## Milestones, grading criteria

Milestone 1 (20%):

* C implementations of all functions (in `c_wcfuncs.c`)
* C implementation of the main program (in `c_wcmain.c`)
* Assembly language implementations of the following functions
  (in `asm_wcfuncs.S`): `wc_isspace`, `wc_isalpha`, and `wc_str_compare`

Milestone 2 (80%):

* Assembly language implementations of all remaining functions
  (in `asm_wcfuncs.S`)
* Assembly language implementation of the main program
  (in `asm_wcmain.S`, 4% of assignment grade)
* Design and coding style (10% of assignment grade)

## Getting started

To get started, download [csf\_assign02.zip](csf_assign02.zip), which contains the
skeleton code for the assignment, and then unzip it.

Note that you can download the zipfile from the command line using the `curl` program:

```bash
curl -O https://jhucsf.github.io/fall2023/assign/csf_assign02.zip
```

Note that in the `-O` option, it is the letter "O", not the numeral "0".

# Word count

The overall goal of the assignment is to create two implementations (C and
x86-64 assembly language) of a *word count* program. When the program is run,
it

1. Opens a text file named on the command line, or uses standard input if
   no command line argument was provided
2. Reads each *word* of text in the input, building a hash table of occurrence
   counts for each unique word
3. Prints a summary of number of words seen, number of unique words, and
   information about the most-frequently occurring unique word in the input
4. Closes the input file (if not reading from standard input)
5. Frees all allocated memory

Here is an example run of the `c_wordcount` program using the input file
`little_dorrit.txt`, which is the text of [Little Dorrit by Charles Dickens](https://www.gutenberg.org/ebooks/963)
as published by [Project Gutenberg](https://www.gutenberg.org/)
(user input is shown in **bold**):

<div class='highlighter-rouge'><pre>
$ <b>./c_wordcount little_dorrit.txt</b>
Total words read: 340410
Unique words read: 18735
Most frequent word: the (15723)
</pre></div>

This test input is available here:

> [little\_dorrit.txt](little_dorrit.txt)

For any test input, running the `asm_wordcount` program (or `casm_wordcount` program) should
result in behavior identical to `c_wordcount`.

## Important restrictions

In implementing the functions in `c_wcfuncs.c` and `asm_wcfuncs.S`, you are not
allowed to call C library functions other than the following ones:

* `fgetc`
* `malloc`
* `free`

In implementing `c_wcmain.c` and `asm_wcmain.S`, you are not allowed to call C
library functions other than the following ones:

* `fopen`
* `fclose`
* `printf`
* `fprintf`
* `malloc`
* `free`

Note that `c_wcmain.c` does not have an `#include <stdlib.h>` directive,
so you should add one if you need to call `malloc` and `free`.

Aside from adding `#include <stdlib.h>` to `c_wcmain.c`,
you should not add any additional `#include` directives in any source file.

## Expectations for assembly language code

For your implementations of assembly language functions, we expect the following.

Your code must be *hand-written*. Using a compiler to generate assembly
code from C code is *not* a legitimate way to complete the assembly language
functions.

We expect your assembly code to be *extensively* commented. One comment per
assembly instruction is a good rule of thumb. One way to think about this:
assembly code is ten times harder to write than high-level language code,
so you should have ten times more comments in your assembly code than
in your high-level language code.

## Functions to implement, unit tests

The header file `wcfuncs.h` defines a data type (`struct WordEntry`) and
C functions which will form the basis of the word count program.

The `struct WordEntry` data type is defined as follows:

```c
struct WordEntry {
  unsigned char word[MAX_WORDLEN + 1];
  uint32_t count; // number of occurrences of this word
  struct WordEntry *next;
};
```

Each `WordEntry` object represents one unique word appearing in the program
input, along with a count of how many times the word occurred.
The `next` field allows `WordEntry` objects to be arranged in a singly-linked
list, which in turn allows the program to maintain a hash table
to keep track of occurrence counts for all words observed in the input.

You will need to implement the following functions in both C and x86-64 assembly
language:

```c
uint32_t wc_hash(const unsigned char *w);
int wc_str_compare(const unsigned char *lhs, const unsigned char *rhs);
void wc_str_copy(unsigned char *dest, const unsigned char *source);
int wc_isspace(unsigned char c);
int wc_isalpha(unsigned char c);
int wc_readnext(FILE *in, unsigned char *w);
void wc_tolower(unsigned char *w);
void wc_trim_non_alpha(unsigned char *w);
struct WordEntry *wc_find_or_insert(struct WordEntry *head, const unsigned char *s,
                                    int *inserted);
struct WordEntry *wc_dict_find_or_insert(struct WordEntry *buckets[],
                                         unsigned num_buckets,
                                         const unsigned char *s);
void wc_free_chain(struct WordEntry *p);
```

Each function has a detailed comment explaining its intended behavior.
In addition, `wctests.c` contains unit tests demonstrating the expected
behavior of each function. (You are encouraged to add additional tests,
but you are not required to.)

As you implement each function, you can use the test program to test it.
For example, if you are ready to test your C implementation of the
`wc_isspace` function, you could run the commands

```
make c_wctests
./c_wctests test_isspace
```

To test the assembly language implementation of `wc_isspace`:

```
make asm_wctests
./asm_wctests test_isspace
```

## Unsigned characters

You will notice that all of the required functions consistently use
`unsigned char` as the data type for text characters. This is primarily
to avoid sign-extension issues when computing a string's hash code.

In the test program (`wctests.c`), there are calls to the C library
string functions which require casts to or from `char *` or `const char *`
to avoid compiler warnings. If you add your own test cases, you
may need to such casts. However, no such casts should be necessary
in `c_wcfuncs.c` or `c_wcmain.c`.

## Hash table implementation

The primary data structure for keeping track of word occurrence counts
will be a [hash table](https://en.wikipedia.org/wiki/Hash_table) using
chained hashing (a.k.a. separate chaining) to handle collisions.

Here is a brief summary of how this should work.

When the word count program reads a word from the input, it
converts it to lower case (using `wc_tolower`) and strips off any
trailing non-alphabetic characters (using `wc_trim_non_alpha`.)
It then uses the hash function (`wc_hash`) to compute
a 32 bit hash code from the word. Next, it finds the index in
the hash table where the word should be located: this is the
hash code mod *N*, where *N* is the number of "buckets" (array elements)
in the hash table. Each bucket is the head pointer of a singly-linked
list of `WordEntry` objects, one for each word present in the bucket.
By searching this list, the program can determine whether or not the
word was encountered previously. If no `WordEntry` object containing
the word is found, then the program is seeing the first occurrence of
the word in the input, and it should prepend a new `WordEntry` object
to the list.

The `wc_find_or_insert` function is responsible for finding or inserting
the `WordEntry` object for a word read from the input. It returns a
pointer to the `WordEntry` object representing the searched-for word,
allowing the word count program to update its occurrence count.

## Main program implementation

The `c_wcmain.c` and `asm_wcmain.S` source files implement (respectively)
the C and assembly language implementations of the word count program's
`main` function.

It should be very straightforward to implement the `main` function by calling
the functions declared in `wcfuncs.h`. For example, the main loop of the
program should work like this:

```
while ( next word is read successfully using wc_readnext ) {
  increase total word count by 1

  use wc_tolower to convert word to lower case

  use wc_trim_non_alpha to remove non-alphabetic characters at end of word

  use wc_dict_find_or_insert to find or insert the word in the hash table

  increment the WordEntry's count
}
```

In finding the unique word with the highest number of occurrences,
you will need to traverse the entire hash table (i.e., scan through
every `WordEntry` object in every bucket of the hash table.)
One situation that could arise is that there could be multiple `WordEntry`
objects that are tied for the highest occurrence count. In this case,
choose the candidate (among the words with the highest occurrence count)
that compares as least lexicographically as the one to display when
the summary stats are printed. You can use the `wc_str_compare` function
to do lexicographical comparisons of strings.

*Error handling*: if there is a command line argument specifying the
name of an input file, but the named file can't be opened, the program
should print an error message to `stderr` and exit with a non-zero
exit code. If the program executes successfully, it should exit with
exit code zero.

The `Makefile` provided by the starter code has three targets to build configurations
of the word count program:

* `make c_wordcount` will build the version that uses the C function implementations
  (in `c_wcfuncs.c`) and the C `main` function (in `c_wcmain.c`)
* `make asm_wordcount` will build the version that uses the assembly language
  function implementations (in `asm_wcfuncs.S`) and the assembly language
  main function (in `asm_wcmain.S`)
* `make casm_wordcount` will build a version that uses the assembly language function
  implementations (in `asm_wcfuncs.S`) and the C `main` function (in `c_wcmain.c`)

The `casm_wordcount` program is useful for validating that your assembly language
function implementations work correctly when called by the main program.

## Testing the main program

You should create some example input files to test your main programs on.

For example (user input in **bold**):

<div class='highlighter-rouge'><pre>
$ <b>curl -O https://jhucsf.github.io/fall2023/assign/oh_freddled_gruntbuggly.txt</b>
$ <b>cat oh_freddled_gruntbuggly.txt</b>
Oh freddled gruntbuggly,
Thy micturations are to me,
As plurdled gabbleblotchits,
On a lurgid bee,
Groop, I implore thee, my foonting turlingdromes,
And hooptiously drangle me,
With crinkly bindlewurdles,
Or else I shall rend thee in the gobberwarts with my blurglecruncheon,
See if I don't!
$ <b>./c_wordcount oh_freddled_gruntbuggly.txt</b>
Total words read: 45
Unique words read: 39
Most frequent word: i (3)
</pre></div>

## Suggested approach

### Milestone 1

The main task in Milestone 1 is to implement the C versions of the
required functions and the word count program's `main` function.
You should implement this part of the milestone before moving on
to implementing the assembly language functions. We recommend working on
one function at a time, from simplest to most complicated, using
the provided unit tests to verify their functionality. Adding your
own unit tests is encouraged, but not required.

For the three assembly language functions required for Milestone 1,
start with the simplest ones (`wc_isspace` and `wc_isalpha`).
Use unit tests to thoroughly test them. We *strongly* recommend
running the unit test program in `gdb` and stepping through the
assembly code so that you know exactly what your assembly instructions
are doing. Experiment with viewing the contents of registers.
When you implement `wc_str_compare` in assembly language, you
will need to use a loop which accesses elements of the two strings
being compared. You should experiment with using `gdb` to show you
the contents of memory. For example, if you want to see the first
element of the array referred-to by the first parameter (`lhs`),
you could use the following command in `gdb`:

```
print *(unsigned char*) $rdi
```

### Milestone 2

In `asm_wcfuncs.S` there are constants `WORDENTRY_WORD_OFFSET`,
`WORDENTRY_COUNT_OFFSET`, and `WORDENTRY_NEXT_OFFSET` which define the
offsets of the `word`, `count`, and `next` fields of the
`struct WordEntry` data type. You will probably want to add a definition
for the size of an instance of `struct WordEntry`:

```c
#define WORDENTRY_SIZE          (WORDENTRY_NEXT_OFFSET+8)
```

The `wc_find_or_insert` function will need to allocate an instance
of `struct WordEntry` using `malloc` in order to insert a new node
into the list.

Referring to the fields of a `struct WordEntry` object is fairly
straightforward. For example, if `%r13` points to a `struct WordEntry`
object, and you want to advance it to point to the next one in the
linked list, you could use the instruction

```
movq WORDENTRY_NEXT_OFFSET(%r13), %r13
```

## Memory correctness

In all C and C++ code you write, we expect that there are no memory errors,
including

* invalid reads
* invalid writes
* uses of uninitialized values
* memory leaks

We expect you to use the [valgrind](https://www.valgrind.org/) memory trace tool
to check program execution for occurrences of memory errors.
Examples of program executions which should proceed without any
memory errors include

```bash
valgrind --leak-check=full ./c_wctests
valgrind --leak-check=full ./asm_wctests
valgrind --leak-check=full ./c_wordcount little_dorrit.txt
valgrind --leak-check=full ./asm_wordcount little_dorrit.txt
valgrind --leak-check=full ./casm_wordcount little_dorrit.txt
```


There should be no dynamic memory errors, and (assuming that all of
the unit tests pass for the executions of `c_wctests` and
`asm_wctests`) there should be no memory leaks.

# Assembly language tips

Here are some specific tips and tricks in no particular order.

Don't forget that you need to prefix constant values with `$`.  For example,
if you want to set register `%r10` to 16, the instruction is

```
movq $16, %r10
```

and not

```
movq 16, %r10
```

If you want to use a label as a pointer (address), prefix it with
`$`.  For example,

```
movq $sSpaceChars, %r10
```

would put the address that `sSpaceChars` refers to in `%r10`.

When calling a function, the stack pointer (`%rsp`) must contain an address
which is a multiple of 16.  However, because the `callq` instruction
pushes an 8 byte return address on the stack, on entry to a function,
the stack pointer will be "off" by 8 bytes.  You can subtract 8 from
`%rsp` when a function begins and add 8 bytes to `%rsp` before returning
to compensate.  (See the example `addLongs` function.)  Pushing an
odd number of callee-saved registers also works, and has the benefit
that you can then use the callee-saved registers freely in your function.

If you want to define read-only string constants, the `.rodata` section
is the right place for them.  For example:

```
        .section .rodata
sSpaceChars: .string " \t\r\n\f\v"
```

The `.equ` assembler directive is useful for defining constant values,
for example:

```
	.equ MAX_WORDLEN, 63
```

You might find the following source code comment useful for reminding
yourself about calling conventions:

```
/*
 * Notes:
 * Callee-saved registers: rbx, rbp, r12-r15
 * Subroutine arguments:  rdi, rsi, rdx, rcx, r8, r9
 */
```

The GNU assembler allows you to define "local" labels, which start
with the prefix `.L`.  You should use these for control flow targets
within a function.  For example:

```
	cmpq $0, %rax                 /* see if read failed */
	jl .LreadError                /* handle read failure */

	...

.LreadError:
	/* error handling goes here */

```

**Hint about determining which characters are alphabetic**: character
codes that are either between 65 and 90 inclusive, or
97 to 122 inclusive, are alphabetic.

## Example assembly language function

Here is an assembly language function called `strLen` which returns the number
of characters in a NUL-terminated character string:

```
/*
 * Determine the length of specified character string.
 *
 * Parameters:
 *   s - pointer to a NUL-terminated character string
 *
 * Returns:
 *    number of characters in the string
 */
	.globl strLen
strLen:
	subq $8, %rsp                 /* adjust stack pointer */
	movq $0, %r10                 /* initial count is 0 */

.LstrLenLoop:
	cmpb $0, (%rdi)               /* found NUL terminator? */
	jz .LstrLenDone               /* if so, done */
	inc %r10                      /* increment count */
	inc %rdi                      /* advance to next character */
	jmp .LstrLenLoop              /* continue loop */

.LstrLenDone:
	movq %r10, %rax               /* return count */
	addq $8, %rsp                 /* restore stack pointer */
	ret
```

In C, the declaration of this function could look like this:

```c
long strLen(const char *s);
```

Unit testing this function might involve the following assertions:

```c
ASSERT(13L == strLen("Hello, world!"));
ASSERT(0L == strLen(""));
ASSERT(8L == strLen("00000010"));
```

# Submitting

Before you submit, prepare a `README.txt` file so that it contains your
names, and briefly summarizes each of your contributions to the submission
(i.e., who worked on what functionality.) This may be very brief if you
did not work with a partner.

To submit your work:

Run the following commands to create a `solution.zip` file:

```
rm -f solution.zip
zip -9r solution.zip Makefile *.h *.c *.S README.txt
```

Please do *not* submit input files (especially if they are large!)

Upload `solution.zip` to [Gradescope](https://www.gradescope.com/)
as **Assignment 2 MS1** or **Assignment 2 MS2**, depending on which
milestone you are submitting.

Please check the files you uploaded to make sure they are the ones you
intended to submit.

## Autograder

When you upload your submission to Gradescope, it will be tested by
the autograder, which executes unit tests for each required function.
Please note the following:

* If your code does not compile successfully, all of the tests will fail
* The autograder runs `valgrind` on your code, but it typically does *not* report
  any information about the result of running `valgrind`: points will be
  deducted if your code has memory errors or memory leaks!
