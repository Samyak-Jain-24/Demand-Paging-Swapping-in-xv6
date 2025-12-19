#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "spinlock.h"
#include "proc.h"
#include "defs.h"
#include "swap.h"
// local strcmp to avoid pulling in system headers that conflict with xv6's prototypes
static int kstrcmp(const char *a, const char *b) {
  while(*a && *b && *a == *b) { a++; b++; }
  return (unsigned char)*a - (unsigned char)*b;
}

struct spinlock tickslock;
uint ticks;

extern char trampoline[], uservec[];

// in kernelvec.S, calls kerneltrap().
void kernelvec();

extern int devintr();

void
trapinit(void)
{
  initlock(&tickslock, "time");
}

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
  w_stvec((uint64)kernelvec);
}

//
// handle an interrupt, exception, or system call from user space.
// called from, and returns to, trampoline.S
// return value is user satp for trampoline.S to switch to.
//
uint64
usertrap(void)
{
  int which_dev = 0;

  if((r_sstatus() & SSTATUS_SPP) != 0)
    panic("usertrap: not from user mode");

  // send interrupts and exceptions to kerneltrap(),
  // since we're now in the kernel.
  w_stvec((uint64)kernelvec);  //DOC: kernelvec

  struct proc *p = myproc();
  
  // save user program counter.
  p->trapframe->epc = r_sepc();
  
  if(r_scause() == 8){
    // system call

    if(killed(p))
      kexit(-1);

    // sepc points to the ecall instruction,
    // but we want to return to the next instruction.
    p->trapframe->epc += 4;

    // an interrupt will change sepc, scause, and sstatus,
    // so enable only now that we're done with those registers.
    intr_on();

    syscall();
  } else if((which_dev = devintr()) != 0){
    // ok
  } else if(r_scause() == 15 || r_scause() == 13 || r_scause() == 12) {
    // Page fault handling: store/AMO=15 (write), load=13 (read), instruction=12 (exec)
    uint64 va = r_stval();
    uint64 sc = r_scause();
    const char *acc = (sc == 15) ? "write" : (sc == 13) ? "read" : "exec";
    // Determine cause bucket
    const char *cause = 0;
    int valid = 0;
  int is_exec_access = (sc == 12);
  uint64 stack_end = PGROUNDUP(p->stack_top); // end of the top stack page (fixed at exec)
  uint64 stack_base = stack_end - (USERSTACK * PGSIZE);
  uint64 stack_guard = stack_end - ((USERSTACK + 1) * PGSIZE);
  int in_guard = (va >= stack_guard && va < stack_base);
  int under_brk = (va < p->sz);
  int in_text = under_brk && (va >= p->text_start && va < p->text_end);
  int in_data = under_brk && (va >= p->data_start && va < p->data_end);
  int in_stack = under_brk && (va >= stack_base && va < stack_end);
  int in_heap = under_brk && !in_text && !in_data && !in_stack && !in_guard;

    // Check if this page was swapped previously
    uint64 va0 = PGROUNDDOWN(va);
    int was_swapped = 0;
    for(int i=0;i<MAX_PAGES_INFO;i++){
      if(p->memstat.pages[i].state == SWAPPED && p->memstat.pages[i].va == (uint)va0){
        was_swapped = 1; break;
      }
    }

    if(in_guard){
      cause = "guard"; valid = 0; // references to guard page are invalid
    } else if(was_swapped){
      cause = "swap"; valid = 1;
    } else if(in_text || in_data){
      cause = "exec"; valid = 1;
    } else if(in_stack && !is_exec_access){
      cause = "stack"; valid = 1;
    } else if(in_heap && !is_exec_access){
      cause = "heap"; valid = 1;
    } else {
      // invalid
    }
    p->pagefault_count++;
    if(p->vmtrace)
      printf("[pid %d] PAGEFAULT va=%p access=%s cause=%s\n", p->pid, (void*)va, acc, cause ? cause : "invalid");
    if(!valid){
      printf("[pid %d] KILL invalid-access va=%p access=%s\n", p->pid, (void*)va, acc);
      setkilled(p);
    } else {
      // Handle valid faults
      // va0 defined above
      pte_t *pte = walk(p->pagetable, va0, 0);
      int mapped = (pte && (*pte & PTE_V));
      if(kstrcmp(cause, "heap") == 0 || kstrcmp(cause, "stack") == 0 || kstrcmp(cause, "swap") == 0) {
        if(is_exec_access){
          // executing from heap/stack is invalid
          printf("[pid %d] KILL invalid-access va=%p access=%s\n", p->pid, (void*)va, acc);
          setkilled(p);
        } else if(!mapped) {
          // ensure not allocating the guard page by mistake
          uint64 guard_lo = stack_guard;
          uint64 stack_lo = stack_base;
          if(va0 >= guard_lo && va0 < stack_lo){
            printf("[pid %d] KILL guard-page-access va=%p\n", p->pid, (void*)va0);
            setkilled(p);
            goto pf_done;
          }
          // If page was swapped, swap it back in; else allocate zero page
          int swapped = was_swapped;
          char *mem = try_kalloc_or_replace(va0);
          if(mem == 0){
            setkilled(p);
          } else {
            if(swapped){
              if(swapin_page(p, va0, mem) < 0){
                kfree(mem);
                setkilled(p);
                goto pf_done;
              }
            } else {
              memset(mem, 0, PGSIZE);
            }
            if(mappages(p->pagetable, va0, PGSIZE, (uint64)mem, PTE_U|PTE_R|PTE_W) < 0){
              kfree(mem);
              setkilled(p);
            } else {
              if(!swapped && p->vmtrace) printf("[pid %d] ALLOC va=%p\n", p->pid, (void*)va0);
              int seq = p->memstat.next_fifo_seq++;
              if(p->vmtrace) printf("[pid %d] RESIDENT va=%p seq=%d\n", p->pid, (void*)va0, seq);
              memstat_mark_resident(p, va0, seq);
              // if the fault was a write, mark dirty
              if(sc == 15){
                int idx = 0;
                for(idx=0; idx<MAX_PAGES_INFO; idx++){
                  if(p->memstat.pages[idx].va == (uint)va0) break;
                }
                if(idx < MAX_PAGES_INFO) p->memstat.pages[idx].is_dirty = 1;
              }
              p->resident_pages++;
            }
          }
        } else if(is_exec_access == 0 && mapped && sc == 15) {
          // write to an already-mapped heap/stack page: mark dirty
          for(int i=0;i<MAX_PAGES_INFO;i++){
            if(p->memstat.pages[i].va == (uint)va0 && p->memstat.pages[i].state == RESIDENT){
              p->memstat.pages[i].is_dirty = 1;
              break;
            }
          }
        }
      } else if(kstrcmp(cause, "exec") == 0) {
        // load from executable file into the page, allocating if needed
        uint64 pa = walkaddr(p->pagetable, va0);
        char *mem;
        int newly_alloc = 0;
        // If this is a write fault on a text (executable) page, it's invalid: kill the process
        // We detect text vs data below again, but we can cheaply check after we know the VA.
        if(sc == 15){
          int is_text_here = (va0 >= p->text_start && va0 < p->text_end);
          if(is_text_here){
            if(p->vmtrace) printf("[pid %d] KILL write-to-text va=%p\n", p->pid, (void*)va);
            setkilled(p);
            goto pf_done;
          }
        }
        if(pa == 0){
          mem = try_kalloc_or_replace(va0);
          if(mem == 0){
            setkilled(p);
            goto pf_done;
          }
          newly_alloc = 1;
        } else {
          // already mapped: handle write-protect for data on first write
          if(sc == 15){
            int is_text = (va0 >= p->text_start && va0 < p->text_end);
            if(!is_text){
              pte = walk(p->pagetable, va0, 0);
              if(pte){
                *pte |= PTE_W; // grant write
                sfence_vma();
                // mark dirty in memstat
                for(int i=0;i<MAX_PAGES_INFO;i++){
                  if(p->memstat.pages[i].va == (uint)va0){
                    p->memstat.pages[i].is_dirty = 1;
                    break;
                  }
                }
              }
              goto pf_done; // no reload/log; just permission upgrade
            }
          }
          mem = (char*)pa;
        }
        // choose which segment this VA is in
        uint off = 0, filesz = 0;
        int is_text = (va0 >= p->text_start && va0 < p->text_end);
        if(is_text){
          off = p->text_off + (va0 - p->text_start);
          filesz = (p->text_filesz > (va0 - p->text_start)) ? (p->text_filesz - (va0 - p->text_start)) : 0;
        } else {
          off = p->data_off + (va0 - p->data_start);
          filesz = (p->data_filesz > (va0 - p->data_start)) ? (p->data_filesz - (va0 - p->data_start)) : 0;
        }
        if(filesz > PGSIZE) filesz = PGSIZE;
        int n = 0;
        if(newly_alloc){
          // Always zero-fill the page so BSS (filesz < memsz) is zeroed.
          memset(mem, 0, PGSIZE);
          if(p->exec_ip && filesz > 0){
            ilock(p->exec_ip);
            n = readi(p->exec_ip, 0, (uint64)mem, off, filesz);
            iunlock(p->exec_ip);
            if(n != filesz){
              kfree(mem);
              setkilled(p);
              goto pf_done;
            }
          }
        }
        // Map text RX; map data R initially; make it writable on first write fault to mark dirty
        int perm = PTE_U | PTE_R | (is_text ? PTE_X : 0);
        if(newly_alloc){
          if(mappages(p->pagetable, va0, PGSIZE, (uint64)mem, perm) < 0){
            kfree(mem);
            setkilled(p);
            goto pf_done;
          }
        } else {
          // adjust permissions to match segment: text -> +X -W, data -> +W -X
          pte = walk(p->pagetable, va0, 0);
          if(pte){
            // Always ensure user and read
            *pte |= (PTE_U | PTE_R);
            if(is_text){
              *pte |= PTE_X;
              *pte &= ~PTE_W;
            } else {
              // keep data non-writable until first write fault sets dirty
              *pte &= ~PTE_W;
              *pte &= ~PTE_X;
            }
            sfence_vma();
          }
        }
        if(newly_alloc){
          if(p->vmtrace) printf("[pid %d] LOADEXEC va=%p\n", p->pid, (void*)va0);
          int seq = p->memstat.next_fifo_seq++;
          if(p->vmtrace) printf("[pid %d] RESIDENT va=%p seq=%d\n", p->pid, (void*)va0, seq);
          memstat_mark_resident(p, va0, seq);
          p->resident_pages++;
        }
      }
pf_done:;
    }
  } else {
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    setkilled(p);
  }

  if(killed(p))
    kexit(-1);

  // give up the CPU if this is a timer interrupt.
  if(which_dev == 2)
    yield();

  prepare_return();

  // the user page table to switch to, for trampoline.S
  uint64 satp = MAKE_SATP(p->pagetable);

  // return to trampoline.S; satp value in a0.
  return satp;
}

//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
  struct proc *p = myproc();

  // we're about to switch the destination of traps from
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
  p->trapframe->kernel_trap = (uint64)usertrap;
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()

  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
  x |= SSTATUS_SPIE; // enable interrupts in user mode
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
}

// interrupts and exceptions from kernel code go here via kernelvec,
// on whatever the current kernel stack is.
void 
kerneltrap()
{
  int which_dev = 0;
  uint64 sepc = r_sepc();
  uint64 sstatus = r_sstatus();
  uint64 scause = r_scause();
  
  if((sstatus & SSTATUS_SPP) == 0)
    panic("kerneltrap: not from supervisor mode");
  if(intr_get() != 0)
    panic("kerneltrap: interrupts enabled");

  if((which_dev = devintr()) == 0){
    // interrupt or trap from an unknown source
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    panic("kerneltrap");
  }

  // give up the CPU if this is a timer interrupt.
  if(which_dev == 2 && myproc() != 0)
    yield();

  // the yield() may have caused some traps to occur,
  // so restore trap registers for use by kernelvec.S's sepc instruction.
  w_sepc(sepc);
  w_sstatus(sstatus);
}

void
clockintr()
{
  if(cpuid() == 0){
    acquire(&tickslock);
    ticks++;
    wakeup(&ticks);
    release(&tickslock);
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
}

// check if it's an external interrupt or software interrupt,
// and handle it.
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    // this is a supervisor external interrupt, via PLIC.

    // irq indicates which device interrupted.
    int irq = plic_claim();

    if(irq == UART0_IRQ){
      uartintr();
    } else if(irq == VIRTIO0_IRQ){
      virtio_disk_intr();
    } else if(irq){
      printf("unexpected interrupt irq=%d\n", irq);
    }

    // the PLIC allows each device to raise at most one
    // interrupt at a time; tell the PLIC the device is
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
  }
}

