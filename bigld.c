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
  unsigned int ax, ay;
  /* GET MAX */
  fseek(in1, 0, SEEK_END);
  fseek(in2, 0, SEEK_END);
  max += ftell(in1);
  max += ftell(in2);
  ax = ftell(in1);
  ay = ftell(in2);
  fseek(in1, 0, SEEK_SET);
  fseek(in2, 0, SEEK_SET);

  printf("%d , %d\n", ax, ay);


  fclose(scores);
  fclose(dictionary);
  return 0;
}

