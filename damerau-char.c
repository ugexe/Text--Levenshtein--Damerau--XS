/* ugexe@cpan.org (Nick Logan)    */

#define MIN(a,b) (((a)<(b))?(a):(b))

/* Our unsorted dictionary linked list.   */
/* Note we use character ints, not chars. */

struct u8dictionary{
  U8 key;
  unsigned int value;
  struct u8dictionary* next;
};
typedef struct dictionary u8item;


static __inline u8item* u8push(U8 key,u8item* curr){
  u8item* head;
  head = malloc(sizeof(u8item));   
  head->key = key;
  head->value = 0;
  head->next = curr;
  return head;
}


static __inline u8item* u8find(u8item* head,U8 key){
  u8item* iterator = head;
  while(iterator){
    if(iterator->key == key){
      return iterator;
    }
    iterator = iterator->next;
  }
 
  return NULL;
}

static __inline u8item* u8uniquePush(u8item* head,U8 key){
  u8item* iterator = head;

  while(iterator){
    if(iterator->key == key){
      return head;
    }
    iterator = iterator->next;
  }
 
  return u8push(key,head); 
}

static void u8dict_free(u8item* head){
  u8item* iterator = head;
  while(iterator){
    u8item* temp = iterator;
    iterator = iterator->next;
    free(temp);
  }

  head = NULL;
}

/* End of Dictionary Stuff */



 
/* All calculations/work are done here */

static int distance2(U8 src[],U8 tgt[],unsigned int x,unsigned int y,unsigned int maxDistance){
  u8item *head = NULL;
  unsigned int swapCount,swapScore,targetCharCount,i,j;
  unsigned int *scores = malloc( (x + 2) * (y + 2) * sizeof(unsigned int) );
  unsigned int score_ceil = x + y;
 
  /* intialize matrix start values */
  scores[0] = score_ceil;  
  scores[1 * (y + 2) + 0] = score_ceil;
  scores[0 * (y + 2) + 1] = score_ceil;
  scores[1 * (y + 2) + 1] = 0;
  head = u8uniquePush(u8uniquePush(head,src[0]),tgt[0]);

  /* work loops    */
  /* i = src index */
  /* j = tgt index */
  for(i=1;i<=x;i++){ 
    head = u8uniquePush(head,src[i]);
    scores[(i+1) * (y + 2) + 1] = i;
    scores[(i+1) * (y + 2) + 0] = score_ceil;

    swapCount = 0;
    for(j=1;j<=y;j++){
      if(i == 1) {
          head = u8uniquePush(head,tgt[j]);
          scores[1 * (y + 2) + (j + 1)] = j;
          scores[0 * (y + 2) + (j + 1)] = score_ceil;
      }

      targetCharCount = u8find(head,tgt[j-1])->value;
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
      u8dict_free(head);
      free(scores);
      return -1;
    }

    
    u8find(head,src[i-1])->value = i;
  }

  {
  unsigned int score = scores[(x+1) * (y + 2) + (y + 1)];
  u8dict_free(head);
  free(scores);
  return score;
  }
}