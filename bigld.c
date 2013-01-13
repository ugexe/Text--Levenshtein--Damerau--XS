#define MIN(a,b) (((a)<(b))?(a):(b))

#include <stdio.h>

void setscore(FILE* arr, unsigned int x, unsigned int y, int dimy, int val){
  int pos = ftell(arr);
  getscore(arr, x, y, dimy, 0);
  fwrite(&val, sizeof(int), 1, arr);
  fseek(arr, pos, SEEK_SET);
}

int score(FILE* arr, unsigned int x, unsigned int y, int dimy){ return getscore(arr,x,y,dimy,1); }
int getscore(FILE* arr, unsigned int x, unsigned int y, int dimy, int reset){
  int pos = ftell(arr);
  int spos = 0;
  fseek(arr, (x * dimy * sizeof(int)) + (y * sizeof(int)), SEEK_SET);
  while((x * dimy * sizeof(int)) + (y * sizeof(int)) > ftell(arr)){
    fwrite(&spos, sizeof(int), 1, arr);
  }
  fseek(arr, -1*sizeof(int), SEEK_CUR);
  fread(&spos, sizeof(int), 1, arr);
  if(reset){
    fseek(arr, pos, SEEK_SET);
  }
  return spos;
}

void setval(FILE* dict, unsigned int key, unsigned int newval){
  int pos = ftell(dict);
  int n = getval(dict,key,0);
  if(n == -1){ //PTR @ END
    fwrite(&key, sizeof(int), 1, dict);
    fwrite(&newval, sizeof(int), 1, dict);
  }else{ //PTR @ KEY EXISTS
    fseek(dict, -1*sizeof(int), SEEK_CUR);
    fwrite(&newval, sizeof(int), 1, dict);
  }
  fseek(dict, pos, SEEK_SET);
}

int val(FILE* dict, int key){ return getval(dict,key,1); }
int getval(FILE* dict, int key, int reset){
  int seeker = 0;
  int pos = ftell(dict);
  unsigned int v = 0;
  unsigned int k = 0;
  int r = NULL;
  fseek(dict, 0, SEEK_SET);
  r = fread(&k, sizeof(int), 1, dict);
  while(r && k != key){
    fseek(dict, sizeof(int), SEEK_CUR);
    r = fread(&k, sizeof(int), 1, dict);
  }

  if(r == 0){
    fseek(dict, 0, SEEK_END);
    return -1;
  }
  fread(&v, sizeof(int), 1, dict);
  if(reset){
    fseek(dict, pos, SEEK_SET);
  }
  return v;
}


int bigld(FILE* in1, FILE* in2){
  FILE* scores = tmpfile();
  FILE* dictionary = tmpfile();
  unsigned int max = 0;
  unsigned int ax, ay, r1[2], r2[2], db, i, j, i1, j1;
  /* GET MAX */
  fseek(in1, 0, SEEK_END);
  fseek(in2, 0, SEEK_END);
  max += (ftell(in1) + ftell(in2)) / sizeof(int);
  ax = (ftell(in1) / sizeof(int)) + 2;
  ay = (ftell(in2) / sizeof(int)) + 2;

  setscore(scores, 0, 0, ay, max);
  
  i = 1;
  fseek(in1, 0, SEEK_SET);
  while(fread(r1, sizeof(int), 1, in1) > 0){
    setscore(scores, i+1, 1, ay, i);
    setscore(scores, i+1, 0, ay, max);
    db = 0;

    j = 1;
    fseek(in2, 0, SEEK_SET);
    while(fread(r2, sizeof(int), 1, in2) > 0){
      if(i == 1){
        setscore(scores, 1, j+1, ay, j);
        setscore(scores, 0, j+1, ay, max);
      }
      printf("(r1:%d,r2:%d)\n",r1[0],r2[0]);
      printf("val\n");
      i1 = val(dictionary, r2[0]);
      j1 = db;

      if(r1[0] == r2[0]){
        printf("equal, setscore : %d,%d,%d,%d\n",i+1,j+1,ay, score(scores,i,j,ay));
        setscore(scores, i + 1, j + 1, ay, score(scores, i, j, ay));
        printf("done");
        db = j;
      }else{
        printf("unequal, setscore\n");
        setscore(scores, i + 1, j + 1, ay, MIN(score(scores, i, j, ay), MIN(score(scores, i+1, j, ay), score(scores, i, j+1, ay))));
      }
      setscore(scores, i + 1, j + 1, ay, MIN(score(scores, i+1, j+1, ay) , score(scores, i1, j1, ay) + (i - i1 - 1) + (j - j1 - 1) + 1));
      j++;
    }
    setval(dictionary, r1[0], i);
    i++;
  }
  printf("D: %d\n", score(scores, ax - 1, ay - 1, ay));

  fclose(scores);
  fclose(dictionary);
  return 0;
}

