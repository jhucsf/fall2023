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
