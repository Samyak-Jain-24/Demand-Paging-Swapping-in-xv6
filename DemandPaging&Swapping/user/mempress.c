#include "kernel/types.h"
#include "user/user.h"

// Force early replacement to exercise logs.
int
main(void)
{
  printf("mempress: start\n");
  mempressure(16); // cap resident at 16 pages
  int pages = 128;
  char *base = sbrklazy(pages * 4096);
  for(int i=0;i<pages;i++){
    base[i*4096] = (char)(i & 0xff); // write to mark dirty and allocate
  }
  // Touch earlier pages again to cause swapins
  for(int i=0;i<pages;i+=4){
    int v = base[i*4096];
    if(v == -1) printf("\n"); // prevent optimizing out
  }
  printf("mempress: done\n");
  exit(0);
}
