#ifndef SWAP_H
#define SWAP_H

#include "types.h"
struct proc;

#define MAX_SWAP_PAGES 1024

// Per-process swap file helpers
int  swapfile_create(struct proc *p);
void swapfile_cleanup(struct proc *p, int *freed_slots);

// Swap I/O
int  proc_swapout_page(struct proc *p, uint64 va, uint64 pa);
int  swapin_page(struct proc *p, uint64 va, char *dst);

#endif
