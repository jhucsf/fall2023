---
layout: default
title: "Assembly language exercise 2"
---

# Getting started

This is an optional assembly language exercise.  It's intended to provide you with and opportunity to practice writing x86-64 assembly language code.

# Task

Your task is to write an x86-64 assembly language program that does the following:

1. Read 20 integer values into an array (you can represent them as either 32 bit or 64 bit, and the program should allow both positive and negative values)
2. Iterate through the array and keep track of how many values are in each of the following ranges: 0-19, 20-39, 40-59, 60-79, 81-99
3. Print out the counts for each range

A good first milestone would be to write a program that reads the values into an array, and then just prints them out and exits.

Doing the full program (steps 1–3) is fairly challenging!

## Hello, world

Here is a simple assembly language program that you can use as a template:

```
/* hello.S */

	.section .rodata

sHelloMsg:  .string "Hello, world!\n"
sPromptMsg: .string "Enter an integer: "
sInputFmt:  .string "%ld"
sResultMsg: .string "You entered: %ld\n"

	.section .bss

	.align 8
num: .space 8

.section .text

	.globl main
main:
	subq $8, %rsp

	movq $sHelloMsg, %rdi
	call printf

	movq $sPromptMsg, %rdi
	call printf

	movq $sInputFmt, %rdi
	movq $num, %rsi
	call scanf

	movq $sResultMsg, %rdi
	movq num, %rsi
	call printf

	addq $8, %rsp
	ret

/*
vim:ft=gas:
*/
```

## Assembling the Hello, world program

You can assemble and run the Hello, world program as follows (user input shown in **bold**):

<div class="highlighter-rouge"><pre>
$ <b>gcc -c -no-pie -o hello.o hello.S</b>
$ <b>gcc -no-pie -o hello hello.o</b>
$ <b>./hello</b>
Hello, world!
Enter an integer: <b>42</b>
You entered: 42
</pre></div>

## Assembling and testing the real program

The following commands show assembling and testing the "real" program (user input shown in **bold**).  It assumes the code is in a file called `hist.S`.

<div class="highlighter-rouge"><pre>
$ <b>gcc -c -g -no-pie -o hist.o hist.S</b>
$ <b>gcc -no-pie -o hist hist.o</b>
$ <b>./hist</b>
Enter 20 integer values: <b>4 95 31 79 43 77 49 19 93 84 13 62 84 30 42 67 23 1 81 95</b>
Histogram:
4
3
3
4
6
</pre></div>

Note that the histogram output is showing the number of input values in each range (0-19, 20-39, etc.)

## Tips and suggestions

*Allocating storage*. The easiest way to allocate storage for the arrays is to make them global variables in the `.bss` segment.  For example:

```
	.section .bss

	.align 8
dataValues: .space (20 * 8)
```

would reserve space for 20 8-byte (64-bit) integer values.  Storage allocated in the `.bss` segment is guaranteed to be filled with zeroes.

If you want a challenge, allocate the arrays on the stack.  The frame pointer register (`%rbp`) can help you keep track of stack-allocated storage: see [Lecture 9](../lectures/lecture09-public.pdf).

*Use callee-saved registers for variables.* You can use callee-saved registers as variables in your computation.  Callee-saved registers have the significant advantage (over caller-saved registers) of being preserved accross procedure calls.  Make sure that you push their original values onto the stack before modifying them, and restore their original values from the stack when they are no longer needed.  For example, let's say that your entire computation is implemented in `main`, and you intend to use `%r12` and `%r13` as variables.  You could put the following code at the beginning of `main`:

```
pushq %r12
pushq %r13
```

Then, put the following code near the end of `main` (just before the `ret` instruction at the very end):

```
popq %r13
popq %r12
```

Note that values must be popped from the the stack in the reverse of the order in which they were pushed. (It's a stack!)

Don't forget that the stack pointer (`%rsp`) must be an exact multiple of 16 at the point of any `call` instruction.  Each `push` of a 64 bit value will decrease `%rsp` by 8.

*Accessing array elements*. One challenge in this exercise is accessing array elements.  Assuming you use 64-bit integers, each array element will occupy 8 bytes of storage.  The indexed/scaled addressing mode is very convenient for directly accessing an array element based on its displacement from the array's base address.  Let's say that `%r12` contains the base address of the array (i.e., it points to the first element of the array), and that `%r13` contains the index of an element.  You can store the address of the chosen element in `%rsi` with the instruction

```
leaq (%r12,%r13,8), %rsi
```

You can load the value of the chosen element into `%rsi` with the instruction

```
movq (%r12,%r13,8), %rsi
```

Note that when specifying the address of a global variable or array, prefix it with `$` (because you're referring to the constant address of the variable, not referring to the contents of the variable.)  For example, to load the base address of the array called `dataValues` into the `%r12` register, you would use the following instruction:

```
movq $dataValues, %r12
```

*Use gdb*. Use `gdb` to trace through the execution of your program.  The [Resources](../resources.html) page has links to some useful information about using `gdb` to debug assembly language.
