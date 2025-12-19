// Bonus alternative page replacement: Clean-First FIFO
// This file is a full copy of vm.c used only by the bonus build.
// The only functional difference is the victim selection policy and logging:
// we prefer evicting a clean page with the smallest FIFO sequence number.

#include "param.h"
#include "types.h"
#include "memlayout.h"
#include "elf.h"
#include "riscv.h"
#include "defs.h"
#include "spinlock.h"
#include "proc.h"
#include "fs.h"
#include "memstat.h"
#include "swap.h"

/*
 * the kernel's page table.
 */
pagetable_t kernel_pagetable;

extern char etext[];  // kernel.ld sets this to end of kernel code.

extern char trampoline[]; // trampoline.S

// Make a direct-map page table for the kernel.
pagetable_t
kvmmake(void)
{
  pagetable_t kpgtbl;

  kpgtbl = (pagetable_t) kalloc();
  memset(kpgtbl, 0, PGSIZE);

  // uart registers
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);

  // virtio mmio disk interface
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);

  // PLIC
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);

  // map kernel text executable and read-only.
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);

  // map kernel data and the physical RAM we'll make use of.
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);

  // map the trampoline for trap entry/exit to
  // the highest virtual address in the kernel.
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);

  // allocate and map a kernel stack for each process.
  proc_mapstacks(kpgtbl);
  
  return kpgtbl;
}

// add a mapping to the kernel page table.
// only used when booting.
// does not flush TLB or enable paging.
void
kvmmap(pagetable_t kpgtbl, uint64 va, uint64 pa, uint64 sz, int perm)
{
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    panic("kvmmap");
}

// Initialize the kernel_pagetable, shared by all CPUs.
void
kvminit(void)
{
  kernel_pagetable = kvmmake();
}

// Switch the current CPU's h/w page table register to
// the kernel's page table, and enable paging.
void
kvminithart()
{
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));

  // flush stale entries from the TLB.
  sfence_vma();
}

// Return the address of the PTE in page table pagetable
// that corresponds to virtual address va.  If alloc!=0,
// create any required page-table pages.
//
// The risc-v Sv39 scheme has three levels of page-table
// pages. A page-table page contains 512 64-bit PTEs.
// A 64-bit virtual address is split into five fields:
//   39..63 -- must be zero.
//   30..38 -- 9 bits of level-2 index.
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
  if(va >= MAXVA)
    panic("walk");

  for(int level = 2; level > 0; level--) {
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
        return 0;
      memset(pagetable, 0, PGSIZE);
      *pte = PA2PTE(pagetable) | PTE_V;
    }
  }
  return &pagetable[PX(0, va)];
}

// Look up a virtual address, return the physical address,
// or 0 if not mapped.
// Can only be used to look up user pages.
uint64
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    return 0;

  pte = walk(pagetable, va, 0);
  if(pte == 0)
    return 0;
  if((*pte & PTE_V) == 0)
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}

// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa.
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
  uint64 a, last;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    panic("mappages: va not aligned");

  if((size % PGSIZE) != 0)
    panic("mappages: size not aligned");

  if(size == 0)
    panic("mappages: size");
  
  a = va;
  last = va + size - PGSIZE;
  for(;;){
    if((pte = walk(pagetable, a, 1)) == 0)
      return -1;
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
}

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
  if(pagetable == 0)
    return 0;
  memset(pagetable, 0, PGSIZE);
  return pagetable;
}

// Remove npages of mappings starting from va. va must be
// page-aligned. It's OK if the mappings don't exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    if((pte = walk(pagetable, a, 0)) == 0) // leaf page table entry allocated?
      continue;   
    if((*pte & PTE_V) == 0)  // has physical page been allocated?
      continue;
    if(do_free){
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}

// Allocate PTEs and physical memory to grow a process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
uint64
uvmalloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz, int xperm)
{
  char *mem;
  uint64 a;

  if(newsz < oldsz)
    return oldsz;

  oldsz = PGROUNDUP(oldsz);
  for(a = oldsz; a < newsz; a += PGSIZE){
    mem = kalloc();
    if(mem == 0){
      uvmdealloc(pagetable, a, oldsz);
      return 0;
    }
    memset(mem, 0, PGSIZE);
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
      kfree(mem);
      uvmdealloc(pagetable, a, oldsz);
      return 0;
    }
  }
  return newsz;
}

// Deallocate user pages to bring the process size from oldsz to
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
  if(newsz >= oldsz)
    return oldsz;

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
      freewalk((pagetable_t)child);
      pagetable[i] = 0;
    } else if(pte & PTE_V){
      panic("freewalk: leaf");
    }
  }
  kfree((void*)pagetable);
}

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
  if(sz > 0)
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
}

// Given a parent process's page table, copy
// its memory into a child's page table.
// Copies both the page table and the
// physical memory.
// returns 0 on success, -1 on failure.
// frees any allocated pages on failure.
int
uvmcopy(pagetable_t old, pagetable_t new, uint64 sz)
{
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    if((pte = walk(old, i, 0)) == 0)
      continue;   // page table entry hasn't been allocated
    if((*pte & PTE_V) == 0)
      continue;   // physical page hasn't been allocated
    pa = PTE2PA(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
      kfree(mem);
      goto err;
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
  return -1;
}

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
  if(pte == 0)
    panic("uvmclear");
  *pte &= ~PTE_U;
}

// Copy from kernel to user.
// Copy len bytes from src to virtual address dstva in a given page table.
// Return 0 on success, -1 on error.
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;
  pte_t *pte;

  while(len > 0){
    va0 = PGROUNDDOWN(dstva);
    if(va0 >= MAXVA)
      return -1;
  
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0) {
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
        return -1;
      }
    }

    pte = walk(pagetable, va0, 0);
    // forbid copyout over read-only user text pages.
    if((*pte & PTE_W) == 0)
      return -1;
      
    n = PGSIZE - (dstva - va0);
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);

    len -= n;
    src += n;
    dstva = va0 + PGSIZE;
  }
  return 0;
}

// Copy from user to kernel.
// Copy len bytes to dst from virtual address srcva in a given page table.
// Return 0 on success, -1 on error.
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    va0 = PGROUNDDOWN(srcva);
    if(va0 >= MAXVA)
      return -1;
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0) {
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
        return -1;
      }
    }
    n = PGSIZE - (srcva - va0);
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);

    len -= n;
    dst += n;
    srcva = va0 + PGSIZE;
  }
  return 0;
}

// Copy a null-terminated string from user to kernel.
// Copy bytes to dst from virtual address srcva in a given page table,
// until a '\0', or max.
// Return 0 on success, -1 on error.
int
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    va0 = PGROUNDDOWN(srcva);
    if(va0 >= MAXVA)
      return -1;
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0){
      // allow lazy fault-in for strings too
      if((pa0 = vmfault(pagetable, va0, 0)) == 0)
        return -1;
    }
    n = PGSIZE - (srcva - va0);
    if(n > max)
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
        got_null = 1;
        break;
      } else {
        *dst = *p;
      }
      --n;
      --max;
      p++;
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    return 0;
  } else {
    return -1;
  }
}

// allocate and map user memory if process is referencing a page
// that was lazily allocated in sys_sbrk().
// returns 0 if va is invalid or already mapped, or if
// out of physical memory, and physical address if successful.
uint64
vmfault(pagetable_t pagetable, uint64 va, int read)
{
  uint64 mem;
  struct proc *p = myproc();

  va = PGROUNDDOWN(va);
  // Never fault-in the stack guard page (just below stack base) or beyond stack top
  uint64 stack_end = PGROUNDUP(p->stack_top);
  uint64 stack_base = stack_end - (USERSTACK * PGSIZE);
  uint64 stack_guard = stack_end - ((USERSTACK + 1) * PGSIZE);
  if(va >= stack_guard && va < stack_base)
    return 0; // guard page access is invalid
  // allow stack pages even if va >= p->sz? No: respect current break, so only under_brk is valid.
  int under_brk = (va < p->sz);
  if(ismapped(pagetable, va)) {
    return 0;
  }
  // Decide how to back this VA: text/data from executable or heap (zero page)
  int in_text = under_brk && (va >= p->text_start && va < p->text_end);
  int in_data = under_brk && (va >= p->data_start && va < p->data_end);
  int in_stack = under_brk && (va >= stack_base && va < stack_end);
  int in_heap = under_brk && !(va >= stack_guard && va < stack_base) && !in_stack && !in_text && !in_data;
  if(in_text || in_data){
    char *buf = try_kalloc_or_replace(va);
    if(buf == 0)
      return 0;
    memset(buf, 0, PGSIZE);
    if(p->exec_ip){
      uint off = 0, filesz = 0;
      if(in_text){
        off = p->text_off + (va - p->text_start);
        filesz = (p->text_filesz > (va - p->text_start)) ? (p->text_filesz - (va - p->text_start)) : 0;
      } else {
        off = p->data_off + (va - p->data_start);
        filesz = (p->data_filesz > (va - p->data_start)) ? (p->data_filesz - (va - p->data_start)) : 0;
      }
      if(filesz > PGSIZE) filesz = PGSIZE;
      if(filesz > 0){
        ilock(p->exec_ip);
        int n = readi(p->exec_ip, 0, (uint64)buf, off, filesz);
        iunlock(p->exec_ip);
        if(n != filesz){
          kfree(buf);
          return 0;
        }
      }
    }
    int perm = PTE_U | PTE_R | (in_text ? PTE_X : PTE_W);
    if (mappages(p->pagetable, va, PGSIZE, (uint64)buf, perm) != 0) {
      kfree(buf);
      return 0;
    }
    return (uint64)buf;
  } else if(in_stack || in_heap) {
    // heap or other anonymous region below p->sz
    mem = (uint64) try_kalloc_or_replace(va);
    if(mem == 0)
      return 0;
    memset((void *) mem, 0, PGSIZE);
    if (mappages(p->pagetable, va, PGSIZE, mem, PTE_W|PTE_U|PTE_R) != 0) {
      kfree((void *)mem);
      return 0;
    }
    return mem;
  } else {
    return 0; // outside any valid region
  }
}

int
ismapped(pagetable_t pagetable, uint64 va)
{
  pte_t *pte = walk(pagetable, va, 0);
  if (pte == 0) {
    return 0;
  }
  if (*pte & PTE_V){
    return 1;
  }
  return 0;
}

// swapin handled in swap.c

// Helper: locate or create page_stat entry for va in p->memstat
static int memstat_find_index(struct proc *p, uint64 va) {
  for(int i=0;i<MAX_PAGES_INFO;i++){
    if(p->memstat.pages[i].state != UNMAPPED && p->memstat.pages[i].va == (uint)va)
      return i;
  }
  for(int i=0;i<MAX_PAGES_INFO;i++){
    if(p->memstat.pages[i].state == UNMAPPED){
      p->memstat.pages[i].va = (uint)va;
      return i;
    }
  }
  return -1;
}

void memstat_mark_resident(struct proc* p, uint64 va, int seq){
  int idx = memstat_find_index(p, va);
  if(idx >= 0){
    if(p->memstat.pages[idx].state != RESIDENT) p->memstat.num_resident_pages++;
    p->memstat.pages[idx].state = RESIDENT;
    p->memstat.pages[idx].seq = seq;
    p->memstat.pages[idx].is_dirty = 0; // default clean on load/alloc
    p->memstat.pages[idx].swap_slot = -1;
  }
}

static void memstat_mark_unmapped(struct proc* p, uint64 va){
  int idx = memstat_find_index(p, va);
  if(idx >= 0){
    if(p->memstat.pages[idx].state == RESIDENT && p->memstat.num_resident_pages>0)
      p->memstat.num_resident_pages--;
    p->memstat.pages[idx].state = UNMAPPED;
    p->memstat.pages[idx].swap_slot = -1;
  }
}

static void memstat_mark_swapped(struct proc* p, uint64 va, int slot){
  int idx = memstat_find_index(p, va);
  if(idx >= 0){
    if(p->memstat.pages[idx].state == RESIDENT && p->memstat.num_resident_pages>0)
      p->memstat.num_resident_pages--;
    p->memstat.pages[idx].state = SWAPPED;
    p->memstat.pages[idx].swap_slot = slot;
  }
}

// Clean-First FIFO victim selection
static int select_victim_cleanfifo_index(struct proc* p, int *chose_clean){
  int victim_clean = -1;
  int victim_clean_seq = 0;
  uint victim_clean_va = 0;
  int victim_fifo = -1;
  int victim_fifo_seq = 0;
  uint victim_fifo_va = 0;
  for(int i=0;i<MAX_PAGES_INFO;i++){
    if(p->memstat.pages[i].state == RESIDENT){
      int seq = p->memstat.pages[i].seq;
      uint va = p->memstat.pages[i].va;
      if(p->memstat.pages[i].is_dirty == 0){
        if(victim_clean == -1 || (uint)seq < (uint)victim_clean_seq ||
           ((uint)seq == (uint)victim_clean_seq && va < victim_clean_va)){
          victim_clean = i; victim_clean_seq = seq; victim_clean_va = va;
        }
      }
      if(victim_fifo == -1 || (uint)seq < (uint)victim_fifo_seq ||
         ((uint)seq == (uint)victim_fifo_seq && va < victim_fifo_va)){
        victim_fifo = i; victim_fifo_seq = seq; victim_fifo_va = va;
      }
    }
  }
  if(chose_clean) *chose_clean = (victim_clean >= 0);
  return (victim_clean >= 0) ? victim_clean : victim_fifo;
}

// Try to kalloc; if fails, evict using Clean-First FIFO and retry.
char* try_kalloc_or_replace(uint64 faulting_va){
  struct proc *p = myproc();
  char *mem = 0;
  mem = kalloc();
  if(mem)
    return mem;
  printf("[pid %d] MEMFULL\n", p->pid);
  int chose_clean = 0;
  int idx = select_victim_cleanfifo_index(p, &chose_clean);
  if(idx < 0){
    // no resident pages; kill
    printf("[pid %d] KILL swap-exhausted\n", p->pid);
    setkilled(p);
    return 0;
  }
  uint64 va0 = PGROUNDDOWN((uint64)p->memstat.pages[idx].va);
  int seq = p->memstat.pages[idx].seq;
  printf("[pid %d] VICTIM va=%p seq=%d algo=%s\n", p->pid, (void*)va0, seq, chose_clean ? "CLEANFIFO" : "FIFO");

  // inspect dirty state
  int dirty = p->memstat.pages[idx].is_dirty;
  printf("[pid %d] EVICT  va=%p state=%s\n", p->pid, (void*)va0, dirty ? "dirty" : "clean");

  // get physical address and unmap
  pte_t *pte = walk(p->pagetable, va0, 0);
  if(pte == 0 || (*pte & PTE_V) == 0){
    // inconsistent; mark unmapped and try again after kalloc
    memstat_mark_unmapped(p, va0);
  } else {
    uint64 pa = PTE2PA(*pte);
    // If dirty, swapout
    if(dirty){
      int slot = proc_swapout_page(p, va0, pa);
      if(slot < 0){
        printf("[pid %d] SWAPFULL\n", p->pid);
        printf("[pid %d] KILL swap-exhausted\n", p->pid);
        setkilled(p);
        return 0;
      }
      printf("[pid %d] SWAPOUT va=%p slot=%d\n", p->pid, (void*)va0, slot);
      if(p->resident_pages>0) p->resident_pages--;
      p->swapped_pages++;
      p->swapout_count++;
      memstat_mark_swapped(p, va0, slot);
    } else {
      // clean page, discard
      printf("[pid %d] DISCARD va=%p\n", p->pid, (void*)va0);
      memstat_mark_unmapped(p, va0);
      if(p->resident_pages>0) p->resident_pages--;
    }
    // unmap and free frame
    *pte = 0;
    kfree((void*)pa);
    sfence_vma();
  }
  // Try allocation again
  mem = kalloc();
  return mem;
}
