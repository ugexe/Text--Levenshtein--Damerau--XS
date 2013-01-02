#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
 
/* Remember: doesn't work for MIN(1,i++) */
#define MIN(a,b) (((a)<(b))?(a):(b))
#define MAX(a,b) (((a)>(b))?(a):(b))


/* Our unsorted dictionary/hash tracker. */
/* Note we use character ints, not chars */

struct dictionary{
  int key;
  unsigned int value;
  struct dictionary* next;
};
typedef struct dictionary item;
 
static __inline item* push(int key,unsigned int value,item* curr){
  item* head;
  Newx(head, sizeof(item), item);   
  head->key = key;
  head->value = value;
  head->next = curr;
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

static void dict_free(item* head){
  item* iterator = head;
  while(iterator){
    item* temp = iterator;
    iterator = iterator->next;
    Safefree(temp);
  }

  head = NULL;
}

/* End of Dictionary Stuff */



 
/* All calculations/work are done here */

static int scores(unsigned int src[],unsigned int tgt[],unsigned int ax,unsigned int ay,unsigned int maxDistance){
  unsigned int i,j;
  item *head = NULL;
  unsigned int INF = ax + ay;
  unsigned int *scores = malloc( (ax + 2) * (ay + 2) * sizeof(unsigned int *) );
  scores[0] = INF;  
  unsigned int axaymax = MAX(ax,ay);

  /* setup scoring matrix */
  for(i=0;i<=axaymax;i++){
    if(i <= ax) {
        scores[(i+1) * (ay + 2) + 1] = i;
        scores[(i+1) * (ay + 2) + 0] = INF;

        if(find(head,src[i]) == NULL){
            head = push(src[i],0,head);
        }
    }
    if(i <= ay) {
        scores[1 * (ay + 2) + (i + 1)] = i;
        scores[0 * (ay + 2) + (i + 1)] = INF;

        if(find(head,tgt[i]) == NULL){
            head = push(tgt[i],0,head);
        }
    }
  }
 
 
  /* work loop */
  unsigned int db,i1,j1;
  for(i=1;i<=ax;i++){
    db = 0;
    for(j=1;j<=ay;j++){
      i1 = find(head,tgt[j-1])->value;
      j1 = db;
 
      if(src[i-1] == tgt[j-1]){
        scores[(i+1) * (ay + 2) + (j + 1)] = scores[i * (ay + 2) + j];
        db = j;
      }else{ 
        scores[(i+1) * (ay + 2) + (j + 1)] = MIN(scores[i * (ay + 2) + j], MIN(scores[(i+1) * (ay + 2) + j], scores[i * (ay + 2) + (j + 1)])) + 1;
      } 

      scores[(i+1) * (ay + 2) + (j + 1)] = MIN(scores[(i+1) * (ay + 2) + (j + 1)], (scores[i1 * (ay + 2) + j1] + i - i1 - 1 + j - j1));
    }

    /* We will return -1 here if the */
    /* current score > maxDistance   */
    if(maxDistance != 0 && maxDistance < scores[(i+1) * (ay + 2) + (ay+1)]) {
      dict_free(head);
      return -1;
    }

    
    find(head,src[i-1])->value = i;
  }

  unsigned int score = scores[(ax+1) * (ay + 2) + (ay + 1)];
  dict_free(head);
  free(scores);
  return score;
}


MODULE = Text::Levenshtein::Damerau::XS    PACKAGE = Text::Levenshtein::Damerau::XS

PROTOTYPES: ENABLE

int
cxs_edistance (arraySource, arrayTarget, maxDistance)
  AV *    arraySource
  AV *    arrayTarget
  SV *    maxDistance
CODE:
  unsigned int i,j;
  unsigned int lenSource = av_len(arraySource)+1;
  unsigned int lenTarget = av_len(arrayTarget)+1;
  int arrSource [ lenSource ];
  int arrTarget [ lenTarget ];
  unsigned int lenSource2 = 0;
  unsigned int lenTarget2 = 0;
  int matchBool = 1;

  if(lenSource > 0 && lenTarget > 0) {
    if(lenSource != lenTarget)
      matchBool = 0;

    /* Convert Perl array to C array */
    unsigned int srctgt_max = MAX(lenSource,lenTarget);
    for (i=0; i < srctgt_max; i++) {
      if(i < lenSource) {
          SV* elem = av_shift(arraySource);
          arrSource[ i ] = (int)SvIV((SV *)elem);
          lenSource2++;
      }
      if(i < lenTarget) {
          SV* elem2 = av_shift(arrayTarget);
          arrTarget[ i ] = (int)SvIV((SV *)elem2);
          lenTarget2++;
	
          /* checks for match */
          if(arrSource[i] != arrTarget[i])
            matchBool = 0;
      }
    }
    av_undef(arraySource);
    av_undef(arrayTarget);

    if(matchBool == 1)
      RETVAL = 0;
    else {
      RETVAL = scores(arrSource,arrTarget,lenSource2,lenTarget2,(int)SvIV(maxDistance));
    }
  }
  else {
    /* handle a blank string */
    RETVAL = (lenSource>lenTarget)?lenSource:lenTarget;
  }
 OUTPUT:
  RETVAL