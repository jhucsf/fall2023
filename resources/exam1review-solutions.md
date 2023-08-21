---
layout: default
title: "Exam 1 Practice Solutions"
category: "resources"
---

# Exam 1 Practice Solutions

These questions are designed to aid your review of the material covered by the first exam. They are not representative of the difficulty, type, or length of the questions on the exam.

In all questions, assume signed integers use two's complement representation.

## Q1. Number Representation
<ol type="a">
  <li>

    <i>Write the representation of the number 43 in base 16, base 10, base 8, base 6, and base 2.</i>
      <br>
      <br>
    From grouping 4 binary bits into one hexadecimal digit:
      <br>
    <code>43<sub>10</sub> = 2B<sub>16</sub></code>
    <br><br>
    We normally use base 10:
      <br>
    <code>43<sub>10</sub> = 43<sub>10</sub></code>
    <br><br>
    From grouping 3 binary bits into one octal digit:
      <br>
    <code>43<sub>10</sub> = 53<sub>8</sub></code>
      <br><br>
    From <code>1 * 6^2 + 1 * 6^1 + 1 * 6^0</code>:
      <br>
    <code>43<sub>10</sub> = 111<sub>6</sub></code>
      <br><br>
    From <code>1 * 2^5 + 1 * 2^3 + 1 * 2^1 + 1 * 2^0</code>:
      <br>
    <code>43<sub>10</sub> = 101011<sub>2</sub></code>

    <br><br>
  </li>
  <li>

    <i>On an 8-bit computer, what is the sum of unsigned <code>208 + 53</code>?, and what is the difference of signed <code>103 - 24</code>?</i>
      <br><br>

    <code>208 + 53 = 5</code>: Due to the 8th bit overflowing, <code>00000101</code> remains
      <br>
    <code> 103 + (-24) = 79</code>: From <code>01100111 + 11101000</code>
      <br><br>
  </li>
  <li>

    <i>Write what <code>-5</code> would be on a 4-bit and an 8-bit system.</i>
      <br><br>
    4-bit system: <code>-5<sub>10</sub> = 1011<sub>2</sub></code>
      <br>
    <code>-5<sub>10</sub> = -8<sub>10</sub> + 3<sub>10</sub> = 1000<sub>2</sub> + 0011<sub>2</sub></code>
      <br>
    8-bit system: <code>-5<sub>10</sub> = 11111011<sub>2</sub></code>
      <br>
    <code>-5<sub>10</sub> = -128<sub>10</sub> + 123<sub>10</sub> = 10000000<sub>2</sub> + 01111011<sub>2</sub></code>
      <br><br>
  </li>
  <li>

    <i>Show how to calculate <code>1.250 + 3.375</code> and <code>1.250 * 3.375</code> using floating point.</i>
      <br>

    <p>Assume 32-bit single precision IEEE 754 floating point values</p>

    <p>1.250<sub>10</sub> = 1.01<sub>2</sub> = 1.01<sub>2</sub> × 2<sup>0</sup></p>
    <p>3.375<sub>10</sub> = 11.011<sub>2</sub> = 11.011<sub>2</sub> × 2<sup>0</sup> = 1.1011<sub>2</sub> × 2<sup>1</sup></p>

    <p><b>Addition:</b></p>

    <p>Convert the smaller operand to the exponent of the larger operand</p>

    <p>1.250<sub>10</sub> = 1.01<sub>2</sub> = 1.01<sub>2</sub> × 2<sup>0</sup> = 0.101<sub>2</sub> × 2<sup>1</sup></p>

    <p>Add:</p>

    <p>0.101<sub>2</sub> × 2<sup>1</sup> + 1.1011<sub>2</sub> × 2<sup>1</sup> = 10.0101<sub>2</sub> × 2<sup>1</sup></p>

    <p>Normalize:</p>

    <p>10.0101<sub>2</sub> × 2<sup>1</sup> = 1.00101<sub>2</sub> × 2<sup>2</sup></p>

    <p>Encoded as IEEE 754 single precision (recall bias is 127, so exponent of 2 is
       encoded as 2 + 127 = 129):</p>

    <table>
      <tr><th>Sign</th><th>Exponent</th><th>Fraction</th></tr>
      <tr>
        <td>0</td>
        <td>10000001</td>
        <td>00101000000000000000000</td>
      </tr>
    </table>

    <p><b>Multiplication:</b></p>

    <p>Product is:</p>

    <p>(1.01<sub>2</sub> × 2<sup>0</sup>) × (1.1011<sub>2</sub> × 2<sup>1</sup>)</p>

    <p>Rewritten:</p>

    <p>(1.01<sub>2</sub> × 1.1011<sub>2</sub>) × (2<sup>0</sup> × 2<sup>1</sup>)</p>

    <p>Multiply mantissas:</p>

    <p>1.01<sub>2</sub> × 1.1011<sub>2</sub> = 10.000111<sub>2</sub></p>

    <p>Multiply bases/exponents:</p>

    <p>2<sup>0</sup> × 2<sup>1</sup> = 2<sup>1</sup></p>

    <p>Product is:</p>

    <p>10.000111<sub>2</sub> × 2<sup>1</sup></p>

    <p>Normalize:</p>

    <p>10.000111<sub>2</sub> × 2<sup>1</sup> = 1.0000111<sub>2</sub> × 2<sup>2</sup></p>

    <p>Encoded as IEEE 754 single precision (bias is 127, so exponent of 2 is
       encoded as 2 + 127 = 129):</p>

    <table>
      <tr><th>Sign</th><th>Exponent</th><th>Fraction</th></tr>
      <tr>
        <td>0</td>
        <td>10000001</td>
        <td>00001110000000000000000</td>
      </tr>
    </table>
  </li>
  <li>

    <i>How are 32 bits broken down in IEEE-754?</i>

    <table>
      <tr>
        <th>Sign Bit</th>
        <th>Exponent</th>
        <th>Fraction/Mantissa</th>
      </tr>
      <tr>
        <th>1</th>
        <th>8</th>
        <th>23</th>
      </tr>
    </table>
      <br><br>
  </li>
</ol>

## Q2. Bitwise Operators
<ol type="a">
  <li>

    <i>Write the results of arithmetic and logical executions of <code>-113 >> 1</code>, where <code>-113</code> is an 8 bit value.</i>
      <br><br>
    <code>-113</code> in 8 bits is <code>10001111</code>.
      <br>
    An arithmetic shift results in <code>11000111<sub>2</sub> = -57<sub>10</sub></code>, preserving the sign bit.
      <br>
    A logical shift results in <code>01000111</code>, treating the sign bit as any other bit.
      <br><br>
  </li>
  <li>

    <i>What is the fastest way to compute <code>16 * 13</code>? (Hint: don't use multiplication.)</i>
      <br><br>
    <code>16 * 13</code> can be found by <code>13 << 4</code>

    <br><br>
  </li>
  <li>

    <i>Determine <code>43 | 13</code>, <code>43 & 13</code>, <code>43 ^ 13</code>, and <code>~43</code> (assume operands are unsigned 8 bit.)</i>
      <br><br>
    <code>43<sub>10</sub> = 00101011<sub>2</sub></code>
      <br>
    <code>13<sub>10</sub> = 00001101<sub>2</sub></code>
      <br>
    <code>43<sub>10</sub> | 13<sub>10</sub> = 00101111<sub>2</sub></code>
      <br>
    <code>43<sub>10</sub> & 13<sub>10</sub> = 00001001<sub>2</sub></code>
      <br>
    <code>43<sub>10</sub> ^ 13<sub>10</sub> = 00100110<sub>2</sub></code>
      <br>
    <code>~43<sub>10</sub> = 11010100<sub>2</sub></code>

      <br><br>
  </li>
</ol>

## Q3. Basic Assembly Questions
<ol type="a">
  <li>

    <i>What are the steps that happen after you run gcc on a .c program? What does the output after each step look like, and what are their file extensions?</i>
    <br><br>
    Compilation, Assembly, Linking
    <br>
    The compile step converts .c source to .s assembly language code (<code>movl $0, %eax</code>)
    <br>
    The assembler step converts .s assembly to .o machine code (machine instructions, binary numbers representing the instruction the CPU should execute)
    <br>
    The linking step combines all .o files into an executable
      <br><br>
  </li>

  <li>

    <i>How, why, and when do you align the stack pointer?</i>

      <br>
   <p><b>How:</b> To align the stack pointer, <i>N</i> bytes must be subtracted
   from %rsp, using some combination of the subq and pushq instructions.</p>
   <p><b>Why:</b> %rsp must contain an address that is a multiple of 16 at the site
    of any call instruction. Some functions, such as <code>printf</code>, use
    special instructions to transfer data from the stack which require alignment on
    a multiple of 16.</p>
   <p><b>When:</b> On entry to a subroutine (a.k.a. function). Because the call instruction
   pushes an 8 byte return address before transferring control to the called subroutine,
   %rsp will contain an address which is a multiple of 8 but not a multiple of 16.</p>
      <br>
  </li>
  <li>

    <i>What are caller and callee saved registers?</i>

    <p><b>Caller-saved:</b> 
     These are registers which may be freely modified by any function.
     However, this means that when calling a function, the caller must assume
     that the contents of any caller-saved register could have been modified.
     If any caller-saved register needs to have its contents preserved across a
     function call, it will need to be saved by the caller (perhaps by using pushq/popq.)
     Hence, "caller-saved".
     </p>

    <p><b>Callee-saved:</b> 
     These are registers which may be assumed <em>not</em> to change as a result
     of calling a function.  This feature makes them especially useful as loop counters,
     accumulators, etc.  This also means that any function which will modify a callee-saved
     register will need to save its original value, and restore that value before returning.
     This is usually done using a pushq instruction on entry to the procedure, and
     popq just before returning from the procedure.
     </p>

      <br>
  </li>
  <li>

  <i>Write a local loop, and the line which calls it in <code>main</code>, that sums all the values from 0-9, given
  <code>#define N 9</code></i>

  <p><b>Answer:</b></p>

<pre>
&#35;define N 9

        .section .rodata
sResultMsg: .string "Sum is %ld\n"

        .section .text

        .globl main
main:
        subq $8, %rsp       /* align stack */

        movq $0, %r10       /* counter */
        movq $0, %r11       /* sum */
.Ltop:
        addq %r10, %r11     /* add current counter value to sum */
        incq %r10           /* increment counter */
        cmpq $N, %r10       /* is %r10 <= N? */
        jle .Ltop           /* if so, continue */

        movq $sResultMsg, %rdi /* printf format arg */
        movq %r11, %rsi     /* value to be printed */
        call printf         /* print result message */

        movl $0, %eax       /* return 0 from main */
        addq $8, %rsp       /* restore stack pointer */
        ret                 /* return from main */
</pre>
   <br><br>
  </li>
  <li>

   <i>In AT&T syntax, what is the order of arguments for these instructions, and where are the results stored?</i>

   <ul>
   <li><i><code>addq %r9, %r10</code></i><br>
   The sum of %r9 and %r10 is stored in %r10
   </li>

   <li><i><code>movl $0xFFFF0000, %esi</code></i><br>
   The value 00000000FFFF0000 (hexadecimal) is stored in %rdi (%esi is the 32 bit sub register
   of %rdi, and a 32-bit move into a 64-bit register clears the upper 32 bits)
  </li>

   <li><i><code>cmpl %eax, %eax</code></i><br>
   %eax (the low 32 bits of %rax) is compared to itself, but is not modified. Condition codes will be set
   based on the result of the comparison.
   </li>
   </ul>

   <br><br>
  </li>
</ol>

## Q4. x86-64 Assembly Programming

<div style="font-style: italic;">
Write an x86-64 assembly language function called <code>swapInts</code> which swaps the values of two <code>int</code> variables. The C function declaration for this function would be

<code>void swapInts(int *a, int *b);</code>

<p>Hints:</p>
<ul>
<li> Think about which registers the parameters will be passed in</li>
<li> Think about what register(s) would be appropriate to use for temporary value(s)</li>
<li> Consider that <code>int</code> variables are 4 bytes (32 bits), and use an appropriate operand size suffix.</li>
</ul>

<b>Important:</b> Your function should follow proper x86-64 Linux register use conventions. Be sure to include the label defining the name of the function.
</div>

<b>Answer</b>:
<pre>
        .globl swapInts
swapInts:
        subq $8, %rsp       /* not strictly necessary, but good style nonetheless */

        movl (%rdi), %r10d  /* get original value of *a */
        movl (%rsi), %r11d  /* get original value of *b */
        movl %r10d, (%rsi)  /* put original value of *a in *b */
        movl %r11d, (%rdi)  /* put original value of *b in *a */

        addq $8, %rsp       /* restore stack pointer */
        ret
</pre>

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

*Possible answer*:

```
	.globl str_tolower
str_tolower:
	subq $8, %rsp

.Lstr_tolower_loop:
	movb (%rdi), %al
	cmpb $0, %al
	je .Lstr_tolower_done

	cmpb $65, %al
	jb .Lstr_tolower_loop_continue
	cmpb $90, %al
	ja .Lstr_tolower_loop_continue

	addb $(97 - 65), %al
	movb %al, (%rdi)

.Lstr_tolower_loop_continue:
	incq %rdi
	jmp .Lstr_tolower_loop

.Lstr_tolower_done:
	addq $8, %rsp
	ret
```

