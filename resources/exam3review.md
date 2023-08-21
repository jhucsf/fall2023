---
layout: default
title: "Exam 3 practice questions"
---

# Exam 3 practice questions

## A. Unix I/O

**A1)** Consider the following server main loop:

```c
int server_fd = Open_listenfd(port);

while (1) {
  int client_fd = Accept(server_fd, NULL, NULL);
  int pid = Fork();
  if (pid == 0) {
    // in child
    chat_with_client(client_fd);
    exit(0);
  }
}
```

Assume that

* `Open_listenfd`, `Accept`, and `Fork` are functions from `csapp.h` and `csapp.c`
* the `chat_with_client` function correctly handles all details of communicating with the remote client, including closing the client socket file descriptor
* the main server process has a handler for `SIGCHLD` to wait for child processes to exit
* the server intentionally does not place any limit on how many client sub-processes can be running
* the server intentionally does not have any mechanism for handling shutdown requests

Describe a bug in this main loop, and how to fix it.

## B. Network communication

**B1)** Complete the following function, called `chat_with_client`.  It should implement the server side of a network protocol in which the client will repeatedly send lines of text, and for each line of text that is not `quit`, the server will send back the reversal of the line sent by the client.  When the client sends the line `quit`, then the client session has ended, and the connection should be closed by the server.

For example, if the client sends

```
Hello, world
Colorless green sheep sleep furiously
A smell of petroleum prevails throughout
quit
```

then the server should send back

```
dlrow ,olleH
ylsuoiruf peels peehs neerg sselroloC
tuohguorht sliaverp muelortep fo llems A
```

You may implement and call helper functions as necessary.  You may use the functions defined in `csapp.h` and `csapp.c`.

```c
void chat_with_client(int client_fd) {
  // TODO: complete this function
```

## C. Concurrency

**C1)** Consider the following `IntStack` data type.

The header file:

```c
// intstack.h

#ifndef INTSTACK_H
#define INTSTACK_H

#define MAX 256

struct IntStack {
  int contents[MAX];
  int top;
};

void intstack_init(struct IntStack *s);
void intstack_push(struct IntStack *s, int val);
int intstack_pop(struct IntStack *s);

#endif // INTSTACK_H
```

The implementation file:

```c
// intstack.c

void intstack_init(struct IntStack *s) {
  s->top = 0;
}

void intstack_push(struct IntStack *s, int val) {
  assert(s->top < MAX);
  s->contents[s->top] = val;
  s->top++;
}

int intstack_pop(struct IntStack *s) {
  assert(s->top > 0);
  s->top--;
  return s->contents[s->top];
}
```

Modify the `IntStack` data type so that it can be safely used by multiple threads.

When the `intstack_push` function is called, and the stack is full, the function
should wait until the stack is not full, and then push the specified value.

When the `intstack_pop` function is called, and the stack is empty, the function
should wait until the stack is not empty, and then pop the top value.
