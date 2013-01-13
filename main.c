#include <stdio.h>

#include "bigld.c"

int main(){
  int *f1 = {50,51,52,53};
  int *f2 = {50,52,51,53};
  FILE* t = fopen("big1.txt", "w");
  fwrite(&f1, sizeof(int), 4, t);
  fclose(t);
  t = fopen("big2.txt", "w");
  fwrite(&f2, sizeof(int), 4, t);
  fclose(t);


  printf("Big1 vs Big2: %d\n", bigld(fopen("big1.txt","r"),fopen("big2.txt","r")));

  return 0;
}
