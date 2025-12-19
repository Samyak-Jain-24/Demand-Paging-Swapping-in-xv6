#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "spinlock.h"
#include "proc.h"
#include "defs.h"
#include "elf.h"

//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
  char *s, *last;
  int i, off;
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();

  begin_op();

  // Open the executable file.
  if((ip = namei(path)) == 0){
    end_op();
    return -1;
  }
  ilock(ip);

  // Read the ELF header.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    goto bad;

  // Is this really an ELF file?
  if(elf.magic != ELF_MAGIC)
    goto bad;

  if((pagetable = proc_pagetable(p)) == 0)
    goto bad;

  // Record text/data ranges and offsets for lazy loading; don't allocate physical pages for them now.
  uint64 text_start = 0, text_end = 0;
  uint64 data_start = 0, data_end = 0;
  uint text_off = 0, text_filesz = 0, text_memsz = 0, text_flags = 0;
  uint data_off = 0, data_filesz = 0, data_memsz = 0, data_flags = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
      continue;
    if(ph.memsz < ph.filesz)
      goto bad;
    if(ph.vaddr + ph.memsz < ph.vaddr)
      goto bad;
    if(ph.vaddr % PGSIZE != 0)
      goto bad;
    // Track text vs data by flags: execute implies text; else data.
    if(ph.flags & 0x1){
      if(text_start == 0) text_start = ph.vaddr;
      text_end = ph.vaddr + ph.memsz;
    } else {
      if(data_start == 0) data_start = ph.vaddr;
      data_end = ph.vaddr + ph.memsz;
    }
    // Reserve VA range without allocating physical memory yet; just bump sz
    if(ph.vaddr + ph.memsz > sz)
      sz = ph.vaddr + ph.memsz;
    if(ph.flags & 0x1){
      text_off = ph.off;
      text_filesz = ph.filesz;
      text_memsz = ph.memsz;
      text_flags = ph.flags;
    } else {
      data_off = ph.off;
      data_filesz = ph.filesz;
      data_memsz = ph.memsz;
      data_flags = ph.flags;
    }
  }
  // We've finished reading metadata; keep the transaction open until
  // we either commit to the new image or abort, so any iput() happens
  // within a valid FS transaction.
  iunlock(ip);

  p = myproc();
  uint64 oldsz = p->sz;

  // Allocate some pages at the next page boundary for the stack only.
  // Make the first inaccessible as a stack guard.
  // Use the rest as the user stack.
  sz = PGROUNDUP(sz);
  uint64 sz1;
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    goto bad;
  sz = sz1;
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
  sp = sz;
  stackbase = sp - USERSTACK*PGSIZE;

  // Copy argument strings into new stack, remember their
  // addresses in ustack[].
  for(argc = 0; argv[argc]; argc++) {
    if(argc >= MAXARG)
      goto bad;
    sp -= strlen(argv[argc]) + 1;
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    if(sp < stackbase)
      goto bad;
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[argc] = sp;
  }
  ustack[argc] = 0;

  // push a copy of ustack[], the array of argv[] pointers.
  sp -= (argc+1) * sizeof(uint64);
  sp -= sp % 16;
  if(sp < stackbase)
    goto bad;
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    goto bad;

  // a0 and a1 contain arguments to user main(argc, argv)
  // argc is returned via the system call return
  // value, which goes in a0.
  p->trapframe->a1 = sp;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
    if(*s == '/')
      last = s+1;
  safestrcpy(p->name, last, sizeof(p->name));
  
  // Commit to the user image.
  oldpagetable = p->pagetable;
  p->pagetable = pagetable;
  p->sz = sz;
  p->trapframe->epc = elf.entry;  // initial program counter = ulib.c:start()
  p->trapframe->sp = sp; // initial stack pointer
  proc_freepagetable(oldpagetable, oldsz);

  // Now that commit succeeded, persist the lazy-mapping metadata on p
  // and hold a reference to the executable inode for on-demand paging.
  p->text_start = text_start;
  p->text_end = text_end;
  p->data_start = data_start;
  p->data_end = data_end;
  // Heap starts after the larger of data/text, page-aligned up
  uint64 seg_end = data_end ? data_end : text_end;
  p->heap_start = PGROUNDUP(seg_end);
  p->stack_top = sp; // top of user stack (within the top stack page)
  p->text_off = text_off;
  p->text_filesz = text_filesz;
  p->text_memsz = text_memsz;
  p->text_flags = text_flags;
  p->data_off = data_off;
  p->data_filesz = data_filesz;
  p->data_memsz = data_memsz;
  p->data_flags = data_flags;

  // Attach a reference to the executable inode for lazy loads and
  // drop our original reference, all within the original transaction.
  ilock(ip);
  p->exec_ip = idup(ip);
  iunlockput(ip);
  end_op();

  // Log initialization of lazy mapping.
  printf("[pid %d] INIT-LAZYMAP text=[%p,%p) data=[%p,%p) heap_start=%p stack_top=%p\n",
         p->pid,
         (void*)p->text_start, (void*)p->text_end,
         (void*)p->data_start, (void*)p->data_end,
         (void*)p->heap_start, (void*)p->stack_top);

  // Create per-process swap file now that exec has succeeded
  if(swapfile_create(p) == 0){
    printf("[pid %d] SWAPFILE created\n", p->pid);
  } else {
    printf("[pid %d] SWAPFILE create failed\n", p->pid);
  }

  return argc; // this ends up in a0, the first argument to main(argc, argv)

 bad:
    if(pagetable) {
      proc_freepagetable(pagetable, sz);
    }
    if(ip){
      // Ensure the iput happens within the transaction we began above.
      ilock(ip);
      iunlockput(ip);
      end_op();
    }
  return -1;
}

// Note: loadseg helper removed in this stage; inline loading above.
