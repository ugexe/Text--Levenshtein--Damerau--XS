#define PERL_NO_GET_CONTEXT
#define NO_XSLOCKS
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "damerau-int.c"

#define MAX(a,b) (((a)>(b))?(a):(b))

/* use the system malloc and free */
#undef malloc
#undef free

MODULE = Text::Levenshtein::Damerau::XS    PACKAGE = Text::Levenshtein::Damerau::XS

PROTOTYPES: ENABLE

void
cxs_edistance (arraySource, arrayTarget, maxDistance)
  AV *    arraySource
  AV *    arrayTarget
  SV *    maxDistance
PPCODE:
  {
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
  //packedSource = SvPVX(arraySource);
  //PUTBACK;
  //unpackstring(type, type+1, packedSource, packedSource + SvCUR(arraySource), 0);
  //SPAGAIN;
 

  if(lenSource > 0 && lenTarget > 0) {
    int matchBool;
    unsigned int srctgt_max = MAX(lenSource,lenTarget);
    if(lenSource != lenTarget)
      matchBool = 0;
    else matchBool = 1;

    {
    /* Convert Perl array to C array */
    int * arrTarget = alloca(sizeof(int) * lenTarget );
    int * arrSource = alloca(sizeof(int) * lenSource );

    for (i=0; i < srctgt_max; i++) {
      if(i < lenSource) {
          SV* elem = sv_2mortal(av_shift(arraySource));
          arrSource[ i ] = (int)SvIV((SV *)elem);
      }
      if(i < lenTarget) {
          SV* elem2 = sv_2mortal(av_shift(arrayTarget));
          arrTarget[ i ] = (int)SvIV((SV *)elem2);
	
          /* checks for match */
	   if(matchBool && i < lenSource)
            if(arrSource[i] != arrTarget[i])
              matchBool = 0;
      }
    }

    if(matchBool == 1)
      retval = 0;
    else 
      retval = distance(arrSource,arrTarget,lenSource,lenTarget,SvIV(maxDistance));
    }
  }
  else {
    /* handle a blank string */
    retval = (lenSource>lenTarget)?lenSource:lenTarget;
  }
    sv_setiv_mg(TARG, retval);
    return; /*we did a PUTBACK earlier, do not let xsubpp's PUTBACK run */
  }
  }



void
cxs_edistance2 (arraySource, arrayTarget, maxDistance)
  SV *    arraySource
  SV *    arrayTarget
  SV *    maxDistance
PPCODE:
  {
  dXSTARG;
  PUSHs(TARG);
  PUTBACK;
  {
  unsigned int i,j;
  STRLEN lenSource;
  STRLEN lenTarget;
  int retval;
  int * arrTarget = alloca(sizeof(unsigned int) * lenTarget );
  int * arrSource = alloca(sizeof(unsigned int) * lenSource );

  U8 * arrTargetbuf = SvPVutf8(arrayTarget,lenTarget);
  U8 * arrSourcebuf = SvPVutf8(arraySource, lenSource );

    if(lenSource > 0 && lenTarget > 0) {
      int matchBool;
      unsigned int srctgt_max = MAX(lenSource,lenTarget);
      if(lenSource != lenTarget) 
        matchBool = 0;
      else matchBool = 1;

    {

    for (i=0; i < srctgt_max; i++) {
      if(i < lenSource) {
          STRLEN s_len;
          UV s_ch = utf8n_to_uvchr(arrSourcebuf, lenSource, &s_len, 0);
          arrSourcebuf += s_len;
          lenSource -= s_len;

          arrSource[ i ] = (unsigned int)s_ch;
      }
      if(i < lenTarget) {
          STRLEN t_len;
          UV t_ch = utf8n_to_uvchr(arrTargetbuf, lenTarget, &t_len, 0);
          arrTargetbuf += t_len;
          lenTarget -= t_len;

          arrTarget[ i ] = (unsigned int)t_ch;
	
          /* checks for match */
	   if(matchBool && i < lenSource)
            if(arrSource[i] != arrTarget[i])
              matchBool = 0;
      }
    }

    if(matchBool == 1)
      retval = 0;
    else 
      retval = distance(arrSource,arrTarget,lenSource,lenTarget,SvIV(maxDistance));
    }
  }
  else {
    /* handle a blank string */
    retval = (lenSource>lenTarget)?lenSource:lenTarget;
  }
    sv_setiv_mg(TARG, retval);
    return; /*we did a PUTBACK earlier, do not let xsubpp's PUTBACK run */
  }
  }
