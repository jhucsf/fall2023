---
layout: default
title: "Assembly language exercise"
---

# Task

Your task in this exercise is to write an x86-64 assembly language program
which reads 10 integer values from the user, stores them in an array,
finds the maximum value, and then prints the maximum value.

Note that it's not sufficient to simply keep track of the maximum value
as values are read: the program should first store the 10 input values
in an array, then find the maximum from the values in the array.

Here is an example session showing assembling and running the program
(user input in **bold**):

<div class="highlighter-rouge"><pre>
$ <b>make arrayMax</b>
gcc -c -g -no-pie -o arrayMax.o arrayMax.S
gcc -no-pie -o arrayMax arrayMax.o
$ <b>./arrayMax</b>
Enter 10 integer values: <b>3 2 61 35 74 73 70 7 94 53</b>
Max is 94
</pre></div>

If you finish this task and are looking for a more challenging task,
you can try the [second assembly language exercise](assembly2.html).

# Solution

Here is a solution: [asmExerciseSoln.zip](asmExerciseSoln.zip)

# Getting started

Download the following zipfile and unzip it: [asmExercise.zip](asmExercise.zip)

Make your changes to `arrayMax.S`.  You can assemble the program using the
command `make arrayMax`.  Run it using the command `./arrayMax`.

An example assembly language program `hello.S` is provided.  You can assemble
it using the command `make hello` and run it using the command `./hello`.

# Tips and suggestions

*Allocating storage*. The easiest way to allocate storage for the array is to make it a global variable in the `.bss` segment.  For example:

```
	.section .bss

	.align 8
dataValues: .space (10 * 8)
```

would reserve space for 10 8-byte (64-bit) values.  Storage allocated in the `.bss` segment is guaranteed to be filled with zeroes.

If you want a challenge, allocate the arrays on the stack.  The frame pointer register (`%rbp`) can help you keep track of stack-allocated storage: see [Lecture 8](../lectures/lecture08-public.pdf).

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

Don't forget that the stack pointer (`%rsp`) must be an exact multiple of 16 at the point of any `call` instruction.  Each `push` of a 64 bit value will decrease `%rsp` by 8.  Depending on how many `pushq`/`popq` instructions you have, you may need to adjust the stack pointer using `subq $8, %rsp` and `addq $8, %rsp` to ensure correct stack alignment.

*Accessing array elements*. One challenge in this exercise is accessing array elements.  Assuming you use 64-bit integers, each array element will occupy 8 bytes of storage.  The indexed/scaled addressing mode is very convenient for directly accessing an array element based on its displacement from the array's base address.  Let's say that `%r12` contains the base address of the array (i.e., it points to the first element of the array), and that `%r13` contains the index of an element.  You can store the address of the chosen element in `%rsi` with the instruction

```
leaq (%r12,%r13,8), %rsi
```

You can load the value of the chosen element into `%rsi` with the instruction

```
movq (%r12,%r13,8), %rsi
```

Note that when specifying the address of a global variable or array, prefix it with `$` (because you're referring to the constant address of the variable, not referring to the data stored in the variable.)  For example, to load the base address of the array called `dataValues` into the `%r12` register, you would use the following instruction:

```
movq $dataValues, %r12
```

*Use gdb*. Use `gdb` to trace through the execution of your program.  The [Resources](../resources.html) page has links to some useful information about using `gdb` to debug assembly language.  [Lecture 8](../lectures/lecture08-public.pdf) also has some useful `gdb` tips on the last two pages.
