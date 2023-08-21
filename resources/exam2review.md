---
layout: default
title: "Exam 2 practice questions"
---

# Exam 2 practice questions

## A: Code optimization, performance

**A1)**

Consider the following function:

```c
// combine a collection of strings into a single string
char *combine(const char *strings[], unsigned num_strings) {
  // determine amount of space needed
  size_t total_size = 0;
  for (unsigned i = 0; i < num_strings; i++) {
    total_size += strlen(strings[i]);
  }

  // allocate buffer large enough for all strings
  char *result = malloc(total_size + 1);

  // copy the data into the buffer
  result[0] = '\0';
  for (unsigned i = 0; i < num_strings; i++) {
    strcat(result, strings[i]);
  }

  return result;
}
```

Explain the performance problem with this function and how to fix it.

**A2)**

Consider the following C code (assume that all variables have the type
`uint64_t`):

```c
a = b * c;
d = e * f;
g = h * i;
j = a * d * g;
```

Assume that

* the CPU is superscalar
* all of the variables refer to CPU registers
* the CPU has two integer multipliers, each of which is fully pipelined
* a single multiplication requires 3 cycles

What is the mininum number of cycles required for the computation to complete?
Justify your answer.

## B: Caches

**B1)**

Assume a system with 32 bit addresses has a direct mapped cache with 256 KB 
total capacity (2<sup>18</sup> bytes) and a 32 byte block size.
Show the format of an address, indicating which bits are offset, index, and tag.

**B2)**

Assume a system with 32 bit addresses has a 4-way set associative cache
with 512 KB total capacity (2<sup>19</sup> bytes) and a 64 byte block size.
Show the format of an address, indicating which bits are offset, index, and tag.

**B3)**

Assume a system with 32 bit addresses and a fully associative cache with 512 KB
total capacity (2<sup>19</sup> bytes) and a 64 byte block size.
Show the format of an address, indicating which bits are offset, index, and tag.

**B4)**

Consider use of a 2-way associative cache that addresses blocks of 4 bytes,
with 4 sets in a 8-bit address space.

(a) How are the 8 bits of the address used as tag, index, and offset for the cache?

(b) Consider a following sequence of requests to the cache.
Enter the tag for each cache slot after each request in the table below. Assume FIFO as
caching strategy (do not worry about internal bookkeeping of timestamps). Note: use &#34;
to indicate that the value in the slot is identical to the previous value.

<table>
  <tr>
   <td>Request</td>
   <td colspan="2" style="text-align: center;">Set 0</td>
   <td colspan="2" style="text-align: center;">Set 1</td>
   <td colspan="2" style="text-align: center;">Set 2</td>
   <td colspan="2" style="text-align: center;">Set 3</td>
  </tr>

  <tr style="border-bottom: 1px solid;">
   <td></td>
   <td>Slot 0</td>
   <td>Slot 1</td>
   <td>Slot 0</td>
   <td>Slot 1</td>
   <td>Slot 0</td>
   <td>Slot 1</td>
   <td>Slot 0</td>
   <td>Slot 1</td>
  </tr>

  <tr><td>00110101</td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td></tr>
  <tr><td>01101000</td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td></tr>
  <tr><td>01101001</td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td></tr>
  <tr><td>10010111</td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td></tr>
  <tr><td>10010110</td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td></tr>
  <tr><td>10110001</td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td></tr>
  <tr><td>10110101</td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td></tr>
</table>

## C: Linking, shared libraries

**C1)** Here is the disassembly of a function called `hex_write_string`, as observed in a non-position-independent executable (`asm_hextests`):

```
0000000000400904 <hex_write_string>:
  400904:       41 54                   push   %r12
  400906:       49 89 fc                mov    %rdi,%r12
  400909:       e8 b9 ff ff ff          callq  4008c7 <str_len>
  40090e:       48 89 c2                mov    %rax,%rdx
  400911:       bf 01 00 00 00          mov    $0x1,%edi
  400916:       4c 89 e6                mov    %r12,%rsi
  400919:       b8 01 00 00 00          mov    $0x1,%eax
  40091e:       0f 05                   syscall 
  400920:       41 5c                   pop    %r12
  400922:       c3                      retq   
```

This function uses the `write` system call to print a NUL-terminated string value to standard output.

Note that in the encoding of the `callq` instruction, the address of the function being called is specified by a signed 32 bit offset, which is relative to the address of the instruction following the `callq` instruction.  Observe that the bytes B9 FF FF FF, when interpreted as a little endian signed two's complement integer, encode the value -71, and subtracting 71 from the address of the successor of the `callq` instruction, 0x40090E, yields 0x4008C7, the exact address of the called function.

What are some advantages of encoding the address of a called function as a relative displacement rather than an absolute address?  What are some disadvantages?

**C2)** Let's say that you have a Linux executable that you don't have the source code for, and you want to change its behavior so that whenever it tries to open a file, it will be forced to look in a particular directory.  For example, if the process wants to open the file `foobar.txt`, it will actually open `/tmp/look_here/foobar.txt`.  What would be an easy way to accomplish this that doesn't require any modifications to the executable or any system libraries?  You may assume that all files will be opened via calls to the `open` function in the shared C library, which is a wrapper for the `open` system call.

## D. Exceptions and processes

**D1)** Consider the following function:

```c
uint64_t sum_array(uint32_t arr[], unsigned len) {
  uint64_t sum = 0;
  for (unsigned i = 0; i < len; i++) {
    sum += arr[i];
  }
  return sum;
}
```

Assume that this function is called to find the sum of the elements in a very large (hundreds of millions of elements.)  State some possible reasons why the process executing this function might be suspended and resumed during the execution of the function.

**D2)** Most operating systems use a periodic timer interrupt to ensure that the OS kernel is able to make scheduling decisions on a regular basis.  I.e., the timer interrupt handler can ensure that no process is able to have exclusive use of a CPU core for an indefinite period of time.

Assume a uniprocessor (single core) system in which the timer interrupt occurs at fixed intervals.  State some advantages and disadvantages of making the timer interval longer rather than shorter.

## E. Signals

**E1)** On Linux, the `printf` function is not "async signal safe", which means that it can't be called safely from a signal handler function.  Describe a scenario where calling `printf` from a signal handler function might result in undesirable program behavior.

## F. Virtual memory

**F1)** Consider the following function:

```c
uint32_t sum_up_to(unsigned n) {
  uint32_t sum = 0;
  for (unsigned i = 1; i <= n; i++) {
    sum += i;
  }
  return sum;
}
```

Assume that all of the variables in this function (`n`, `sum`, and `i`) are allocated by the compiler as CPU registers, so that there are no memory references in the assembly code generated for this function.  Is it possible for any page faults to occur as a result of executing this function? Briefly explain why or why not.

**F2)** Say that you have a CPU with 64 bit virtual addresses and a 16K (2<sup>14</sup> bytes) page size.  Assume that page table entries (at all levels of the page table hierarchy) are the same size as addresses, i.e., 8 bytes.

(a) If the full 64 bit address space is usable, how many levels of page tables are necessary?

(b) Show a proposed format for a virtual address, assuming that the entire 64 bit virtual address space is usable, showing the ranges of address bits used for the page offset and the index at each level of the hierarchy.

(c) Explain why, from a practical standpoint, it might be a good idea to support an effective virtual address space of less than 2<sup>64</sup> bytes.

**F3)** On x86-64 systems, there are four levels of page tables, with each page table having 512 (2<sup>9</sup>) entries.  The page size is 4096 (2<sup>12</sup>) bytes.  This scheme provides an effective virtual address size of 2<sup>48</sup> bytes, since

<blockquote>
2<sup>9</sup> × 2<sup>9</sup> × 2<sup>9</sup> × 2<sup>9</sup> × 2<sup>12</sup> = 2<sup>48</sup>
</blockquote>

(a) In the *page directory*, which is the page table at the root of the tree, how much virtual address space (in bytes) does each entry represent?

(b) What is the total number of second level, third level, and fourth level page tables that could be reached from a single entry in the page directory?  How many bytes of physical memory are required if all of these page tables are present?
