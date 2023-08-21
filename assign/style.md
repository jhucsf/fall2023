---
layout: default
title: "CSF coding style guidelines"
---

This document is intended to help you meet the design and coding style
expectations for programs you submit for CSF.

These guidelines are somewhat specific to C programs.  If the assignment
specifications allow you to use other languages (such as Python), then
we expect you to follow standard good coding style practices for the
language you're using.

## Identifier naming

Choose good identifier names for your variables, functions, data types, etc.

Variable names should indicate the meaning/purpose of the information
stored in the variable.

Function names should concisely describe the purpose of the function.

Data type names should name the problem domain entity that an instance
of the data type refers to.

Identifiers consisting of multiple words can be "traditional style"
(lower-case, words separated by underscores) or "camel case" (words
except first are capitalized.)  Traditional:

```c
int cache_size;
float velocity_meters_per_sec;
```

Camel case:

```c
int cacheSize;
float velocityMetersPerSec;
```

## Indentation

Your program should use indentation levels to indicate the nesting
level of nested blocks.  Each increase in nesting should increase the
indentation by one level.  One indentation level should be between 2
and 8 spaces (inclusive).  Four spaces per indent is recommended, but
not required.

You should either use exclusively spaces or exclusively tabs for
indentation.  **Do not mix spaces and tabs.**

## Brace placement

"Java style" is fine:

```c
#include <stdio.h>

int main(void) {
    for (int i = 0; i < 10; i++) {
        printf("%d\n", i);
    }
    return 0;
}
```

"Microsoft style" is also fine:

```c
#include <stdio.h>

int main(void)
{
    for (int i = 0; i < 10; i++)
    {
        printf("%d\n", i);
    }
    return 0;
}
```

## Comments

Each source file (header and implementation) should have a header comment
describing the purpose of the file, the assignment name, your name,
and your email.  Example:

```c
/*
 * String functions for multithreaded client/server calculator program
 * CSF Assignment 7
 * A. Student
 * astude99@jhu.edu
 */
```

Each function should have a comment describing the purpose and operation
of the function, its parameters, and its return value (if any).  Example:

```c
/*
 * Skip leading whitespace in a C character string, returning
 * a string (using the same storage as the original string)
 * with leading whitespace removed.  If there is no leading
 * whitespace, returns the original string.
 *
 * Parameters:
 *   s - pointer to a C character string
 *
 * Returns:
 *   a pointer to the first non-whitespace character in s
 */
const char *skip_whitespace(const char *s) {
    ...
}
```

Use appropriate comments to document the *intent* behind your code,
especially the more complex parts of your code.  Note that comments are
not a substitute for writing clear and understandable code.

## Consistency

Be consistent in your coding style.  For example:

* Don't mix identifier naming conventions
* Use consistent indentation
* Use consistent brace placement
* Use consistent function comments

If you are working in a team, make sure that all of the team members
are following the same coding style conventions.

## Design

Use good modular design practices in your program.  Use functions to
manage the complexity of your code: once the body of a function reaches
about 20 (non-comment) lines of code, you should consider refactoring your code to
use helper functions.  There is no absolute rule about function length,
but the following guidelines about function length are worth considering:

* 1-20 non-comment lines of code: most functions should be in this range
* 20-30 non-comment lines of code: you should consider refactoring
  code into one or more helper functions to reduce complexity
* 30-50 non-comment lines of code: it *might* be reasonable for one or two
  functions in your program to be this long (perhaps your `main` function),
  but deductions for over-complexity are a possibility
* More than 50 non-comment lines of code: expect a style deduction

Use problem-domain-specific data types as appropriate.  For example, in a
file server application, you might have a data type called `FileResource`
representing a file resource managed by the server.  Each problem-domain
data type should be supported by functions to implement important
operations.  For example, the `FileResource` data type might support
the following function to get the file size of a file resource:

```c
ssize_t file_resource_get_size(struct FileResource *res);
```

## Memory correctness

We expect that all code written in memory-unsafe languages such as C
and C++ to execute without any memory errors or memory leaks.  Make sure
that you use tools such as [valgrind](https://valgrind.org/) when testing
your programs.  In general, we will deduct points for code that does not
execute cleanly in valgrind, or exhibits other types of memory errors
at runtime.
