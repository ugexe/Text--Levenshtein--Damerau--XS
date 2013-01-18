/* ugexe@cpan.org (Nick Logan)    */

#define MIN(a,b) (((a)<(b))?(a):(b))

/* Our unsorted dictionary linked list.   */
/* Note we use character ints, not chars. */

struct UVdictionary{
  UV key;
  unsigned int value;
  struct UVdictionary* next;
};
typedef struct dictionary UVitem;


static __inline UVitem* UVpush(UV key,UVitem* curr){
  UVitem* head;
  head = malloc(sizeof(UVitem));   
  head->key = key;
  head->value = 0;
  head->next = curr;
  return head;
}


static __inline UVitem* UVfind(UVitem* head,UV key){
  UVitem* iterator = head;
  while(iterator){
    if(iterator->key == key){
      return iterator;
    }
    iterator = iterator->next;
  }
 
  return NULL;
}

static __inline UVitem* UVuniquePush(UVitem* head,UV key){
  UVitem* iterator = head;

  while(iterator){
    if(iterator->key == key){
      return head;
    }
    iterator = iterator->next;
  }
 
  return UVpush(key,head); 
}

static void UVdict_free(UVitem* head){
  UVitem* iterator = head;
  while(iterator){
    UVitem* temp = iterator;
    iterator = iterator->next;
    free(temp);
  }

  head = NULL;
}

/* End of Dictionary Stuff */



 
/* All calculations/work are done here */

static int distance2(UV src[],UV tgt[],unsigned int x,unsigned int y,unsigned int maxDistance){
  UVitem *head = NULL;
  unsigned int swapCount,swapScore,targetCharCount,i,j;
  unsigned int *scores = malloc( (x + 2) * (y + 2) * sizeof(unsigned int) );
  unsigned int score_ceil = x + y;
 
  /* intialize matrix start values */
  scores[0] = score_ceil;  
  scores[1 * (y + 2) + 0] = score_ceil;
  scores[0 * (y + 2) + 1] = score_ceil;
  scores[1 * (y + 2) + 1] = 0;
  head = UVuniquePush(UVuniquePush(head,src[0]),tgt[0]);

  /* work loops    */
  /* i = src index */
  /* j = tgt index */
  for(i=1;i<=x;i++){ 
    head = UVuniquePush(head,src[i]);
    scores[(i+1) * (y + 2) + 1] = i;
    scores[(i+1) * (y + 2) + 0] = score_ceil;

    swapCount = 0;
    for(j=1;j<=y;j++){
      if(i == 1) {
          head = UVuniquePush(head,tgt[j]);
          scores[1 * (y + 2) + (j + 1)] = j;
          scores[0 * (y + 2) + (j + 1)] = score_ceil;
      }

      targetCharCount = UVfind(head,tgt[j-1])->value;
      swapScore = scores[targetCharCount * (y + 2) + swapCount] + i - targetCharCount - 1 + j - swapCount;

      if(src[i-1] != tgt[j-1]){      
        scores[(i+1) * (y + 2) + (j + 1)] = MIN(swapScore,(MIN(scores[i * (y + 2) + j], MIN(scores[(i+1) * (y + 2) + j], scores[i * (y + 2) + (j + 1)])) + 1));
      }else{ 
        swapCount = j;
        scores[(i+1) * (y + 2) + (j + 1)] = MIN(scores[i * (y + 2) + j], swapScore);
      } 
    }

    /* We will return -1 here if the */
    /* current score > maxDistance   */
    if(maxDistance != 0 && maxDistance < scores[(i+1) * (y + 2) + (y+1)]) {
      UVdict_free(head);
      free(scores);
      return -1;
    }

    
    UVfind(head,src[i-1])->value = i;
  }

  {
  unsigned int score = scores[(x+1) * (y + 2) + (y + 1)];
  UVdict_free(head);
  free(scores);
  return score;
  }
}