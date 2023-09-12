---
layout: default
title: "Assignment 2: Word count"
---

*Note: this is a preliminary assignment description, not official yet*

Milestone 1: Due Friday, Sep 25th by 11 pm

Milestone 2: Due Thursday, Oct 5th by 11 pm

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
  (in `asm_wcfuncs.S`): `wc_isspace`, `wc_isalpha`, and `wc_string_eq`

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

In general, running the `asm_wordcount` program (or `casm_wordcount` program) should
result in behavior identical to `c_wordcount`.

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

## Hash table implementation

The primary data structure for keeping track of word occurrence counts
will be a [hash table](https://en.wikipedia.org/wiki/Hash_table) using
chained hashing (a.k.a. separate chaining) to handle collisions.

Here is a brief summary of how this should work.

When the word count program reads a word from the input, it
converts it to lower case and strips off any trailing non-alphabetic
characters. It then uses the hash function (`wc_hash`) to compute
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
