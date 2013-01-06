#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

/* use the system malloc and free */
#undef malloc
#undef free

#define MIN(a,b) (((a)<(b))?(a):(b))
#define MAX(a,b) (((a)>(b))?(a):(b))


/* Our unsorted dictionary linked list.   */
/* Note we use character ints, not chars. */

struct dictionary{
  unsigned int key;
  unsigned int value;
  struct dictionary* next;
};
typedef struct dictionary item;

static __inline item* push1(unsigned int key,item* curr){
  item* head;
  head = malloc(sizeof(item));   
  head->key = key;
  head->value = 0;
  head->next = curr;
  return head;
}

static __inline item* push2(unsigned int key1,unsigned int key2,item* curr){
  /* Trying to create 2 nodes at once. Not working */
  item* head;
  head = malloc(sizeof(item) * 2);   
  head->key = key1;
  head->value = 0;
  head->next->key = key2;
  head->next->value = 0;
  head->next->next = curr;
  return head;
}

static __inline item* find(item* head,unsigned int key){
  item* iterator = head;
  while(iterator){
    if(iterator->key == key){
      return iterator;
    }
    iterator = iterator->next;
  }
 
  return NULL;
}

static __inline item* uniquePush2(item* head,unsigned int key1,unsigned int key2){
  unsigned int key1_found = 0;
  unsigned int key2_found = 0;
  item* iterator = head;

  while(iterator){
    if(key1_found == 0 && iterator->key == key1)
      key1_found = 1;
    if(key2_found == 0 && iterator->key == key2)
      key2_found = 1;

    if(key1_found && key2_found)
       return head;

    iterator = iterator->next;
  }

  if(key1_found == 0 && key2_found == 0 && key1 != key2) 
     return push1(key1,push1(key2,head));
  else if(key1_found == 0)
     return push1(key1,head);
  else if(key2_found == 0) 
     return push1(key2,head);
}

static __inline item* uniquePush1(item* head,unsigned int key){
  item* iterator = head;
  int key_found = 0;

  while(iterator){
    if(iterator->key == key){
      return head;
    }
    iterator = iterator->next;
  }
 
  return push1(key,head); 
}

static void dict_free(item* head){
  item* iterator = head;
  while(iterator){
    item* temp = iterator;
    iterator = iterator->next;
    free(temp);
  }

  head = NULL;
}

/* End of Dictionary Stuff */



 
/* All calculations/work are done here */

static int distance(unsigned int src[],unsigned int tgt[],unsigned int x,unsigned int y,unsigned int maxDistance){
  item *head = NULL;
  unsigned int i,j;
  unsigned int *scores = malloc( (x + 2) * (y + 2) * sizeof(unsigned int) );
  unsigned int inf = x + y;
  scores[0] = inf;  
  unsigned int xy_max = MAX(x,y);

  /* setup scoring matrix */
  for(i=0;i<=xy_max;i++){
    if(i <= x && i <= y) {
         head = uniquePush2(head,src[i],tgt[i]); 
         scores[(i+1) * (y + 2) + 1] = i;
         scores[(i+1) * (y + 2) + 0] = inf;
         scores[1 * (y + 2) + (i + 1)] = i;
         scores[0 * (y + 2) + (i + 1)] = inf;

    }
    else if(i <= x) {
         head = uniquePush1(head,src[i]);
         scores[(i+1) * (y + 2) + 1] = i;
         scores[(i+1) * (y + 2) + 0] = inf;
    }
    else if(i <= y) {
         head = uniquePush1(head,tgt[i]);
         scores[1 * (y + 2) + (i + 1)] = i;
         scores[0 * (y + 2) + (i + 1)] = inf;
    }
  }
 
 
  /* work loop */
  unsigned int db,i1,j1;
  for(i=1;i<=x;i++){ 
    db = 0;
    for(j=1;j<=y;j++){
      i1 = find(head,tgt[j-1])->value;
      j1 = db;

      if(src[i-1] == tgt[j-1]){
        scores[(i+1) * (y + 2) + (j + 1)] = scores[i * (y + 2) + j];
        db = j;
      }else{ 
        scores[(i+1) * (y + 2) + (j + 1)] = MIN(scores[i * (y + 2) + j], MIN(scores[(i+1) * (y + 2) + j], scores[i * (y + 2) + (j + 1)])) + 1;
      } 

      scores[(i+1) * (y + 2) + (j + 1)] = MIN(scores[(i+1) * (y + 2) + (j + 1)], (scores[i1 * (y + 2) + j1] + i - i1 - 1 + j - j1));
    }

    /* We will return -1 here if the */
    /* current score > maxDistance   */
    if(maxDistance != 0 && maxDistance < scores[(i+1) * (y + 2) + (y+1)]) {
      dict_free(head);
      free(scores);
      return -1;
    }

    
    find(head,src[i-1])->value = i;
  }

  unsigned int score = scores[(x+1) * (y + 2) + (y + 1)];
  dict_free(head);
  free(scores);
  return score;
}

MODULE = Text::Levenshtein::Damerau::XS    PACKAGE = Text::Levenshtein::Damerau::XS

PROTOTYPES: ENABLE

void
cxs_edistance (arraySource, arrayTarget, maxDistance)
  AV *    arraySource
  AV *    arrayTarget
  SV *    maxDistance
PPCODE:
  dXSTARG;
  PUSHs(TARG);
  PUTBACK;
  {
  unsigned int i,j;
  unsigned int lenSource = av_len(arraySource)+1;
  unsigned int lenTarget = av_len(arrayTarget)+1;
  int retval;


  //char *packedSource;
  //char type = 'U';
  //packedSource = SvPVX(ST(0));
  //PUTBACK;
  //unpackstring(&type, &type+1, packedSource, packedSource + SvCUR(ST(0)), 0);
  //SPAGAIN;
 

  if(lenSource > 0 && lenTarget > 0) {
    int matchBool;
    unsigned int srctgt_max = MAX(lenSource,lenTarget);
    if(lenSource != lenTarget)
      matchBool = 0;
    else matchBool = 1;

    /* Convert Perl array to C array */
    int arrTarget [ lenTarget ];
    int arrSource [ lenSource ];
    int maxDistance_int = SvIV(maxDistance);

    for (i=0; i < srctgt_max; i++) {
      if(i < lenSource) {
          SV* elem = sv_2mortal(av_shift(arraySource));
          arrSource[ i ] = (int)SvIV((SV *)elem);
      }
      if(i < lenTarget) {
          SV* elem2 = sv_2mortal(av_shift(arrayTarget));
          arrTarget[ i ] = (int)SvIV((SV *)elem2);
	
          /* checks for match */
	   if(i < lenSource)
            if(arrSource[i] != arrTarget[i])
              matchBool = 0;
      }
    }

    if(matchBool == 1)
      retval = 0;
    else {
      retval = distance(arrSource,arrTarget,lenSource,lenTarget, maxDistance_int);
    }
  }
  else {
    /* handle a blank string */
    retval = (lenSource>lenTarget)?lenSource:lenTarget;
  }
    sv_setiv_mg(TARG, retval);
    return; /*we did a PUTBACK earlier, do not let xsubpp's PUTBACK run */
  }