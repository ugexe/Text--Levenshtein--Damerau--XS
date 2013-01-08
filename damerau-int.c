/* ugexe@cpan.org (Nick Logan)    */

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

static __inline item* push(unsigned int key,item* curr){
  item* head;
  head = malloc(sizeof(item));   
  head->key = key;
  head->value = 0;
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

static __inline item* uniquePush(item* head,unsigned int key){
  item* iterator = head;
  int key_found = 0;

  while(iterator){
    if(iterator->key == key){
      return head;
    }
    iterator = iterator->next;
  }
 
  return push(key,head); 
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
  unsigned int xy_max = MAX(x,y);
  unsigned int db,i1,j1,i,j;
  unsigned int *scores = malloc( (x + 2) * (y + 2) * sizeof(unsigned int) );
  unsigned int score_ceil = x + y;

  /* intialize matrix start values */
  scores[0] = score_ceil;  
  scores[1 * (y + 2) + 0] = score_ceil;
  scores[0 * (y + 2) + 1] = score_ceil;
  scores[1 * (y + 2) + 1] = 0;
  head = uniquePush(uniquePush(head,src[0]),tgt[0]);

  /* work loop */
  for(i=1;i<=x;i++){ 
    head = uniquePush(head,src[i]);
    scores[(i+1) * (y + 2) + 1] = i;
    scores[(i+1) * (y + 2) + 0] = score_ceil;

    db = 0;
    for(j=1;j<=y;j++){
      if(i == 1) {
          head = uniquePush(head,tgt[j]);
          scores[1 * (y + 2) + (j + 1)] = j;
          scores[0 * (y + 2) + (j + 1)] = score_ceil;
      }

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
