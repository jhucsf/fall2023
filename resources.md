---
layout: default
title: "Resources"
category: "resources"
---

This page has links to useful resources.

# Information

This section has links to some information resources you might find useful.

## Practice problems and exams

<!--
Exam 1 review materials (not sure why this isn't updated
on the course website)
-->

Review materials for Exam 1:

* [Exam 1 practice questions](resources/exam1review.html), [Solutions](resources/exam1review-solutions.html)
* [Midterm, Spring 2020](resources/midterm-spring2020.pdf) (Questions 1–3), [Solution](resources/midterm-spring2020-soln.pdf)
* [Exam 1, Fall 2021](resources/exam01-fall2021.pdf), [Solution](resources/exam01-fall2021-soln.pdf)

<!--
Review materials for Exam 2:

* [Exam 2 practice questions](resources/exam2review.html), [Solutions](resources/exam2review-solutions.html)
* [Midterm, Spring 2020](resources/midterm-spring2020.pdf) (Question 4), [Solution](resources/midterm-spring2020-soln.pdf)
* [Final exam, Spring 2020](resources/final-spring2020.pdf) (Questions 1–3), [Solution](resources/final-spring2020-soln.pdf)
* [Exam 2, Fall 2021](resources/exam02-fall2021.pdf), [Solution](resources/exam02-fall2021-soln.pdf)

Review materials for Exam 3:

* [Exam 3 practice questions](resources/exam3review.html), [Solutions](resources/exam3review-solutions.html)
* [Final exam, Fall 2019](resources/final-fall2019.pdf) (Questions 4–5), [Solution](resources/final-fall2019-soln.pdf)
* [Final exam, Spring 2020](resources/final-spring2020.pdf) (Questions 4–5), [Solution](resources/final-spring2020-soln.pdf)
* [Exam 3, Fall 2021](resources/exam03-fall2021.pdf), [Solution](resources/exam03-fall2021-soln.pdf)
-->

## x86-64 assembly language exercises

* [Assembly language mini-exercises](resources/assemblyMini.html)
* [Assembly language exercise](resources/assembly.html), [solution](resources/asmExerciseSoln.zip)
* [Assembly language exercise 2 (more challenging)](resources/assembly2.html)

## x86-64 assembly programming resources

* [CSF Assembly Language Tips & Tricks](https://jhucsf.github.io/csfdocs/assembly-tips-v0.1.2.pdf)
  * This is a very comprehensive guide to x86-64 assembly language written by
    Max Hahn, focusing on issues that are important for CSF
* [Brown x64 cheat sheet](https://cs.brown.edu/courses/cs033/docs/guides/x64_cheatsheet.pdf)
* [Brown gdb cheat sheet](https://cs.brown.edu/courses/cs033/docs/guides/gdb.pdf)
* [CMU summary of gdb commands for x86-64](http://csapp.cs.cmu.edu/3e/docs/gdbnotes-x86-64.pdf)

## Style Guidelines
* The [style guidelines](resources/style.html) state our coding style expectations.

# Software

This section covers the software you'll be using in working on programming assignments.

## Linux

For the programming assignments, you will need to use a recent x86-64 (64 bit) version of Linux.

**Important**: the code you submit is required to run correctly on Ubuntu 22.04, since
that is the version of Linux that we use in [Gradescope](https://www.gradescope.com/) autograders.
We have found that recent versions of mainstream Linux distributions, such as
[Fedora](https://getfedora.org/) (which is the OS used on the ugrad machines),
have few if any behavioral differences compared to Ubuntu 22.04, so any
recent version of Linux (on an x86-64 system) should be fine.

Here are some options for getting your development environment set up.

You can install [Ubuntu 22.04](https://releases.ubuntu.com/22.04/) directly on your
computer.  This is a good option if you are comfortable installing operating systems
from installation media.

On Windows 10, you can use the [Windows Subsystem for Linux](https://docs.microsoft.com/en-us/windows/wsl/install-win10)
(WSL).  Once WSL is enabled, you can install Ubuntu 22.04 from the Microsoft Store.  Make sure that
you install the [tools](#tools) listed below.  Using WSL is an excellent option if you are
comfortable doing your development work inside a terminal session.

On MacOS and Windows, you can use virtual machine software such as [VirtualBox](https://www.virtualbox.org/)
to run Ubuntu 22.04 as a guest OS.  If you do a web search for "ubuntu 22.04 image for virtualbox"
you will find pre-made OS images that you can download.  (I can't directly vouch for any of these,
so be careful.)  You will likely need to enable hardware virtualization support in your computer's
BIOS to allow VirtualBox to run correctly.  We recommend dedicating a significant amount of RAM
(at least 4GB) to the virtual machine (this should be fine as long as your computer has at least
8 GB of RAM.)

Note that if you are using an M1-based (ARM) Mac computer, there aren't any good
options for setting up a local development environment.  Virtualization won't work
in the case because the computer doesn't use an x86-64 CPU. However, using
[Visual Studio Code](https://code.visualstudio.com/) connected to an SSH
workspace which accesses your ugrad account is a good option.

You can use the CS ugrad machines to do your development work. Although
they run Fedora rather than Ubuntu 22.04, we have not observed any
important behavioral differences in recent years. Just be sure that you
using valgrind diligently to ensure that your code is free from memory
errors such as use of uninitialized variables.

## Tools

Some of the tools you'll want to have are:

* gcc
* g++
* make
* ruby
* valgrind
* git

All of these are available by default on the Ugrad computers.

To install on an Ubuntu-based system:

```
sudo apt-get install gcc g++ make ruby valgrind git
```

You'll also want to install a text editor.  [Emacs](https://www.gnu.org/software/emacs/) and [Vim](https://www.vim.org/) are good options:

```
sudo apt-get install emacs vim
```

## Using Git

* [Github ssh authentication](resources/github-ssh.html): How to use ssh to access
  your private repositories on Github
