#include <stdio.h>

#include "bigld.c"

int main(){
  printf("Big1 vs Big2: %d\n", bigld(fopen("big1.txt","r"),fopen("big2.txt","r")));

  return 0;
}
