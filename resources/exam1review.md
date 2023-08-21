---
layout: default
title: "Exam 1 Practice Questions"
category: "resources"
---

# Exam 1 Practice Questions

These questions are designed to aid your review of the material covered by the first exam. They are not representative of the difficulty, type, or length of the questions on the exam.

In all questions, assume signed integers use two's complement representation.

## Q1. Number Representation
<ol type="a">
  <li>

  Write the representation of the number 43 in base 16, base 10, base 8, base 6, and base 2.

  </li>
  <li>

  On an 8-bit computer, what is the sum of unsigned <code>208 + 53</code>?, and what is the difference of signed <code>103 - 24</code>?

  </li>
  <li>

  Write what <code>-5</code> would be on a 4-bit and an 8-bit system.

  </li>
  <li>

  Show how to calculate <code>1.250 + 3.375</code> and <code>1.250 * 3.375</code> using floating point.

  </li>
  <li>

  How are 32 bits broken down in IEEE-754?

  </li>
</ol>

## Q2. Bitwise Operators
<ol type="a">
  <li>

  Write the results of arithmetic and logical executions of <code>-113 >> 1</code>, where <code>-113</code> is an 8 bit value.

  </li>
  <li>

  What is the fastest way to compute <code>16 * 13</code>? (Hint: don't use multiplication.)

  </li>
  <li>

  Determine <code>43 | 13</code>, <code>43 & 13</code>, <code>43 ^ 13</code>, and <code>~43</code> (assume operands are unsigned 8 bit.)

  </li>
</ol>

## Q3. Basic Assembly Questions
<ol type="a">
  <li>

  What are the steps that happen after you run gcc on a .c program? What does the output after each step look like, and what are their file extensions?

  </li>

  <li>

  How, why, and when do you align the stack pointer?

  </li>
  <li>

  What are caller and callee saved registers?

  </li>
  <li>

  Write a local loop, and the line which calls it in <code>main</code>, that sums all the values from 0-9, given

  <code>#define N 9</code>

  </li>
  <li>

  In AT&T syntax, what is the order of arguments for these instructions, and where are the results stored?

  <ul>
  <li><code>addq %r9, %r10</code></li>

  <li><code>movl $FFFF0000, %esi</code></li>

  <li><code>cmpl %eax, %eax</code>
  </li>
  </ul>
  </li>
</ol>

## Q4. x86-64 Assembly Programming

Write an x86-64 assembly language function called <code>swapInts</code> which swaps the values of two <code>int</code> variables. The C function declaration for this function would be

<code>void swapInts(int *a, int *b);</code>

Hints:
* Think about which registers the parameters will be passed in
* Think about what register(s) would be appropriate to use for temporary value(s)
* Consider that <code>int</code> variables are 4 bytes (32 bits), and use an appropriate operand size suffix.

**Important:** Your function should follow proper x86-64 Linux register use conventions. Be sure to include the label defining the name of the function.

## Q5. x86-64 Assembly Programming

Consider the following C function prototype:

```c
void str_tolower(char *s);
```

The `str_tolower` function modifies a C character string so that each
upper case letter is converted to lower case.

Show an x86-64 assembly language implementation of this function.
Note that the ASCII codes for upper case letters are in the range
65–90, and the ASCII codes for lower case letters are the range
97–122.  Characters that aren't letters should not be modified.

