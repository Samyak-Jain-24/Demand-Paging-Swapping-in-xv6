#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "spinlock.h"
#include "proc.h"
#include "defs.h"
#include "fs.h"
#include "stat.h"
#include "sleeplock.h"
#include "file.h"
#include "memstat.h"
#include "swap.h"

// Local create helper (clone of sysfile.c:create)
static struct inode*
kcreate(char *path, short type, short major, short minor)
{
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    return 0;

  ilock(dp);

  if((ip = dirlookup(dp, name, 0)) != 0){
    iunlockput(dp);
    ilock(ip);
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
      return ip;
    iunlockput(ip);
    return 0;
  }

  if((ip = ialloc(dp->dev, type)) == 0){
    iunlockput(dp);
    return 0;
  }

  ilock(ip);
  ip->major = major;
  ip->minor = minor;
  ip->nlink = 1;
  iupdate(ip);

  if(type == T_DIR){
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
      goto fail;
  }

  if(dirlink(dp, name, ip->inum) < 0)
    goto fail;

  if(type == T_DIR){
    dp->nlink++;
    iupdate(dp);
  }

  iunlockput(dp);

  return ip;

 fail:
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}

// Create per-process swap file at path /pgswpXXXXX (pid)
int swapfile_create(struct proc *p)
{
  if(p->swapfile){
    return 0; // already present
  }
  char name[20];
  // build "/pgswp" + 5-digit pid with leading zeros
  int pid = p->pid;
  name[0] = '/'; name[1] = 'p'; name[2] = 'g'; name[3] = 's'; name[4] = 'w'; name[5] = 'p';
  int x = pid;
  int d4 = (x/10000)%10, d3=(x/1000)%10, d2=(x/100)%10, d1=(x/10)%10, d0=x%10;
  name[6] = '0'+d4; name[7] = '0'+d3; name[8] = '0'+d2; name[9] = '0'+d1; name[10] = '0'+d0; name[11] = 0;
  begin_op();
  struct inode *ip = kcreate(name, T_FILE, 0, 0);
  if(ip == 0){
    end_op();
    return -1;
  }
  // open as a struct file
  struct file *f = filealloc();
  if(f == 0){
    iunlockput(ip);
    end_op();
    return -1;
  }
  // kcreate returns ip locked; unlock before assigning to file
  iunlock(ip);
  f->type = FD_INODE;
  f->ip = ip;
  f->off = 0;
  f->readable = 1;
  f->writable = 1;
  p->swapfile = f;
  end_op();
  return 0;
}

// Cleanup swap file; set freed_slots to number of used entries cleared.
void swapfile_cleanup(struct proc *p, int *freed_slots)
{
  int freed = 0;
  // Count used entries and clear the table
  for(int i=0;i<MAX_SWAP_PAGES;i++){
    if(p->swap_table[i].used){
      freed++;
    }
    p->swap_table[i].used = 0;
    p->swap_table[i].va = 0;
    p->swap_table[i].slot = -1;
  }
  p->num_swapped_pages = 0;
  if(freed_slots) *freed_slots = freed;

  if(p->swapfile){
    // unlink file path and close
    char name2[20];
    // rebuild name again
    int pid2 = p->pid;
    name2[0]='/'; name2[1]='p'; name2[2]='g'; name2[3]='s'; name2[4]='w'; name2[5]='p';
    int y=pid2; int e4=(y/10000)%10, e3=(y/1000)%10, e2=(y/100)%10, e1=(y/10)%10, e0=y%10;
    name2[6]='0'+e4; name2[7]='0'+e3; name2[8]='0'+e2; name2[9]='0'+e1; name2[10]='0'+e0; name2[11]=0;

    begin_op();
    // perform unlink(name2)
    char nm[DIRSIZ]; uint off; struct inode *dp, *ip;
    if((dp = nameiparent(name2, nm)) != 0){
      ilock(dp);
      if((ip = dirlookup(dp, nm, &off)) != 0){
        ilock(ip);
        // remove directory entry
        struct dirent de;
        memset(&de, 0, sizeof(de));
        writei(dp, 0, (uint64)&de, off, sizeof(de));
        ip->nlink--;
        iupdate(ip);
        iunlockput(ip);
      }
      iunlockput(dp);
    }
    end_op();

    // Close file structure
    fileclose(p->swapfile);
    p->swapfile = 0;
  }
}

// Swap out a physical page (pa) belonging to p at va into p's swap file
int proc_swapout_page(struct proc *p, uint64 va, uint64 pa)
{
  if(p->swapfile == 0){
    if(swapfile_create(p) < 0)
      return -1;
  }
  // find free slot
  int slot = -1;
  for (int i = 0; i < MAX_SWAP_PAGES; i++) {
    if (!p->swap_table[i].used) {
      slot = i;
      break;
    }
  }
  if (slot == -1)
    return -1; // SWAPFULL

  // write frame to swap file at offset slot*PGSIZE
  begin_op();
  ilock(p->swapfile->ip);
  // src is a kernel-mapped physical page; pass user_src=0
  int n = writei(p->swapfile->ip, 0, pa, slot * PGSIZE, PGSIZE);
  iunlock(p->swapfile->ip);
  end_op();
  if(n != PGSIZE)
    return -1;

  // update table
  p->swap_table[slot].used = 1;
  p->swap_table[slot].va = PGROUNDDOWN(va);
  p->swap_table[slot].slot = slot;
  p->num_swapped_pages++;

  // Update memstat
  // mark swapped with slot
  // Ensure entry exists and mark swapped
  for(int i=0;i<MAX_PAGES_INFO;i++){
    if(p->memstat.pages[i].va == PGROUNDDOWN(va)){
      p->memstat.pages[i].state = SWAPPED;
      p->memstat.pages[i].swap_slot = slot;
      p->memstat.pages[i].is_dirty = 0;
      break;
    }
  }
  return slot;
}

// Swap in contents for va into dst (a kernel-mapped page buffer)
int swapin_page(struct proc *p, uint64 va, char *dst)
{
  if(p->swapfile == 0)
    return -1;
  uint64 va0 = PGROUNDDOWN(va);
  int slot = -1;
  for (int i = 0; i < MAX_SWAP_PAGES; i++) {
    if (p->swap_table[i].used && p->swap_table[i].va == va0) {
      slot = i;
      break;
    }
  }
  if (slot == -1)
    return -1;

  begin_op();
  ilock(p->swapfile->ip);
  // dst is a kernel buffer; pass user_dst=0
  int n = readi(p->swapfile->ip, 0, (uint64)dst, slot * PGSIZE, PGSIZE);
  iunlock(p->swapfile->ip);
  end_op();
  if(n != PGSIZE)
    return -1;

  // free the slot
  p->swap_table[slot].used = 0;
  p->swap_table[slot].va = 0;
  p->swap_table[slot].slot = -1;
  if(p->num_swapped_pages > 0)
    p->num_swapped_pages--;
  printf("[pid %d] SWAPIN va=%p slot=%d\n", p->pid, (void*)va0, slot);
  if(p->swapped_pages>0) p->swapped_pages--;
  p->resident_pages++;
  p->swapin_count++;

  // memstat update
  for(int i=0;i<MAX_PAGES_INFO;i++){
    if(p->memstat.pages[i].va == va0){
      p->memstat.pages[i].state = RESIDENT;
      p->memstat.pages[i].swap_slot = -1;
      p->memstat.pages[i].is_dirty = 0;
      break;
    }
  }

  return slot;
}
