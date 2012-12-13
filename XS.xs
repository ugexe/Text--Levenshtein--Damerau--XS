#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
 
#define MIN(a,b) (((a)<(b))?(a):(b))
 

/* Our unsorted dictionary/hash tracker. */
/* Note we use character ints, not chars */

struct dictionary{
  int key;
  unsigned int value;
  struct dictionary* next;
};
typedef struct dictionary item;
 
static item* push(int key,unsigned int value,item* curr){
  item* head;
  Newx(head, sizeof(item), item);   
  head->key = key;
  head->value = value;
  head->next = curr;
  return head;
}

static item* dict_free(item* head){
  item* iterator = head;
  while(iterator){
	item* temp = iterator;
	iterator = iterator->next;
	Safefree(temp);
  }

  head = NULL;
}
 
static item* find(item* head,unsigned int key){
  item* iterator = head;
  while(iterator){
    if(iterator->key == key){
      return iterator;
    }
    iterator = iterator->next;
  }
 
  return NULL;
}

/* End of Dictionary Stuff */



 
/* All calculations/work are done here */

static int scores(int src[],int tgt[],unsigned int ax,unsigned int ay,unsigned int maxDistance){
  unsigned int i,j;
  unsigned int scores[ax+2][ay+2];
  item *head = NULL;
  unsigned int INF = ax + ay;
  scores[0][0] = INF; 
 
  /* setup scoring matrix */
  for(i=0;i<=ax;i++){
    scores[i+1][1] = i;
    scores[i+1][0] = INF;
 
    if(find(head,src[i]) == NULL){
      head = push(src[i],0,head);
    }
  }
  for(j=0;j<=ay;j++){
    scores[1][j+1] = j;
    scores[0][j+1] = INF;
 
    if(find(head,tgt[j]) == NULL){
      head = push(tgt[j],0,head);
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
        scores[i+1][j+1] = scores[i][j];
        db = j;
      }else{
        scores[i+1][j+1] = MIN(scores[i][j], MIN(scores[i+1][j], scores[i][j+1])) + 1;
      }
	 
      scores[i+1][j+1] = MIN(scores[i+1][j+1], scores[i1][j1] + i - i1 - 1 + j - j1);
    }


    /* We will give up here if the */
    /* current score > maxDistance */
    if(maxDistance != 0 && maxDistance < scores[i+1][ay+1]) {
       dict_free(head); 
	return -1;
    }

    find(head,src[i-1])->value = i;
  }

  dict_free(head);
  return scores[ax+1][ay+1];
}


MODULE = Text::Levenshtein::Damerau::XS	PACKAGE = Text::Levenshtein::Damerau::XS	

PROTOTYPES: ENABLE

int
cxs_edistance (arraySource, arrayTarget, maxDistance)
	AV *	arraySource
	AV *	arrayTarget
	SV *	maxDistance
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
	
		for (i=0; i < lenSource; i++) {
	       	SV** elem = av_fetch(arraySource, i, 0);
	        	int retval = (int)SvIV(*elem);
	 
	        	if (elem != NULL) {
	            		arrSource[ i ] = retval;
	             		lenSource2++;

				/* checks for match */
				if(i <= lenTarget)
					if(arrSource[i] != arrTarget[i])
						matchBool = 0;
	        	}
	    	}
	    	for (j=0; j < lenTarget; j++) {
	       	SV** elem = av_fetch(arrayTarget, j, 0);
	        	int retval = (int)SvIV(*elem);
	
	        	if (elem != NULL) {
	            		arrTarget[ j ] = retval;
	             		lenTarget2++;
	
				/* checks for match */
				if(j <= lenSource)
					if(arrSource[j] != arrTarget[j])
						matchBool = 0;
	        	}
	    	}
	
		if(matchBool == 1)
			RETVAL = 0;
		else
		    	RETVAL = scores(arrSource,arrTarget,lenSource2,lenTarget2,(int)SvIV(maxDistance));
	}
	else {
		/* handle a blank string */
		RETVAL = (lenSource>lenTarget)?lenSource:lenTarget;
	}
OUTPUT:
	RETVAL
