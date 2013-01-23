#define PERL_NO_GET_CONTEXT
#define NO_XSLOCKS
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "damerau-int.c"
#include "damerau-char.c"

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
  unsigned int i;
  unsigned int lenSource = av_len(arraySource)+1;
  unsigned int lenTarget = av_len(arrayTarget)+1;
  int retval;
 
  if(lenSource > 0 && lenTarget > 0) {
    int matchBool;
    unsigned int srctgt_max = MAX(lenSource,lenTarget);
    if(lenSource != lenTarget)
      matchBool = 0;
    else matchBool = 1;

    {
    /* Convert Perl array to C array */
    unsigned int * arrTarget = malloc(sizeof(int) * lenTarget );
    unsigned int * arrSource = malloc(sizeof(int) * lenSource );

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

    free(arrSource);
    free(arrTarget);
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
cxs_edistance2 (stringSource, stringTarget, maxDistance)
  SV *    stringSource
  SV *    stringTarget
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

  U8 * strTargetbuf;
  U8 * strSourcebuf;
  UV * strTarget;
  UV * strSource;

  if(!SvUTF8(stringSource)) {
    stringSource = sv_mortalcopy(stringSource);
    sv_utf8_upgrade(stringSource);
  }
  if(!SvUTF8(stringTarget)) {
    stringTarget = sv_mortalcopy(stringTarget);
    sv_utf8_upgrade(stringTarget);
  }

  strTargetbuf = SvPVutf8(stringTarget,lenTarget);
  strSourcebuf = SvPVutf8(stringSource,lenSource );
  strTarget = alloca(sizeof(UV) * lenTarget );
  strSource = alloca(sizeof(UV) * lenSource );

  if(lenSource > 0 && lenTarget > 0) {
    int matchBool;
    unsigned int srctgt_max = MAX(lenSource,lenTarget);
    if(lenSource != lenTarget) 
      matchBool = 0;
    else matchBool = 1;

    for (i=0; i < srctgt_max; i++) {
      if(i < lenSource) {
          STRLEN s_len;
          UV s_ch = utf8n_to_uvuni(strSourcebuf, lenSource, &s_len, 0);
          strSourcebuf += s_len;
          lenSource -= s_len;

          strSource[ i ] = s_ch;
      }
      if(i < lenTarget) {
          STRLEN t_len;
          UV t_ch = utf8n_to_uvuni(strTargetbuf, lenTarget, &t_len, 0);
          strTargetbuf += t_len;
          lenTarget -= t_len;

          strTarget[ i ] = t_ch;
	
          /* checks for match */
          if(matchBool && i < lenSource)
            if(strSource[i] != strTarget[i])
              matchBool = 0;
      }
    }

    if(matchBool == 1)
      retval = 0;
    else 
      retval = lenTarget; //distance2(strSource,strTarget,lenSource,lenTarget,SvIV(maxDistance));
  }
  else {
    /* handle a blank string */
    retval = (lenSource>lenTarget)?lenSource:lenTarget;
  }
  sv_setiv_mg(TARG, retval);
  return; /*we did a PUTBACK earlier, do not let xsubpp's PUTBACK run */
  }
  }
