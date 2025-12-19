#include "kernel/types.h"
#include "user/user.h"

#define PGSIZE 4096

// Craft an invalid operation: attempt to execute from heap, and read an unmapped VA beyond sz
int main(void)
{
  printf("[test_invalid] start\n");

  int pid = fork();
  if (pid < 0) {
    printf("[test_invalid] fork failed\nTEST FAILED\n");
    exit(1);
  }
  if (pid == 0) {
    // child: perform invalid actions
  char *heap = sbrklazy(2*PGSIZE);
    if (heap == (char*)-1) exit(2);
    heap[0] = 0x13; // write ok
    // Try to execute from heap: jump via function pointer
    void (*fn)(void) = (void(*)(void))heap;
    printf("[test_invalid] child attempting exec from heap at %p\n", heap);
    fn(); // should cause KILL invalid-access access=exec
    // If we get here, failure
    printf("[test_invalid] unexpected: executed from heap\n");
    exit(3);
  }
  int st = 0;
  wait(&st);
  if (st != 0) {
    printf("[test_invalid] child killed as expected (status=%d)\n", st);
  } else {
    printf("[test_invalid] child exited cleanly (unexpected)\nTEST FAILED\n");
    exit(1);
  }

  // Second invalid: read far beyond current sz in a fresh child
  pid = fork();
  if (pid == 0) {
    volatile char x;
    char *bad = (char*)0x400000000000ULL; // beyond MAXVA region; will fault
    printf("[test_invalid] child reading invalid VA %p\n", bad);
    x = *bad;
    printf("[test_invalid] unexpected: read succeeded (%d)\n", x);
    exit(4);
  }
  wait(&st);
  if (st != 0) {
    printf("[test_invalid] child killed on invalid read as expected\n");
    printf("TEST PASSED\n");
    exit(0);
  }
  printf("[test_invalid] child exited cleanly (unexpected)\nTEST FAILED\n");
  exit(1);
}
