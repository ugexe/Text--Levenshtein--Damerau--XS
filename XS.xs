#define PERL_NO_GET_CONTEXT
#define NO_XSLOCKS
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "src/damerau-int.c"

#define MIN(a,b) (((a)<(b))?(a):(b))
#define MAX(a,b) (((a)>(b))?(a):(b))

MODULE = Text::Levenshtein::Damerau::XS    PACKAGE = Text::Levenshtein::Damerau::XS

PROTOTYPES: ENABLE

void *
cxs_edistance (arraySource, arrayTarget, maxDistance)
  AV *    arraySource
  AV *    arrayTarget
  SV *    maxDistance
INIT:
    unsigned int i, *arrSource, *arrTarget;
    unsigned int lenSource = av_len(arraySource)+1;
    unsigned int lenTarget = av_len(arrayTarget)+1;
    /* hold the user supplied argument for max distance */
    unsigned int md = SvUV(maxDistance);
    /* mdx contains a calculated max different (md) to use in the algorithm itself */
    unsigned int mdx = (md == 0) ? MAX(lenSource,lenTarget) : md;
    unsigned int diff = MAX(lenSource , lenTarget) - MIN(lenSource, lenTarget);
    unsigned int undef = 0;
    SV* elem;
PPCODE:
{
    /* bail out before memory allocation and calculations if possible */
    if(lenSource == 0 || lenTarget == 0) {
        if( md != 0 && MAX(lenSource, lenTarget) > md ) {
            // XPUSHs(sv_2mortal(&PL_sv_undef));
            XPUSHs(sv_2mortal(&PL_sv_undef));
            XSRETURN(1);
        }
        else {
            XPUSHs(sv_2mortal(newSVuv( MAX(lenSource, lenTarget) )));
            XSRETURN(1);
        }
    }

    if (md != 0 && diff > mdx) {
        // XPUSHs(sv_2mortal(&PL_sv_undef));
        XPUSHs(sv_2mortal(&PL_sv_undef));
        XSRETURN(1);
    }


    /* Convert Perl array to C array */
    Newx(arrTarget, lenTarget, unsigned int);
    Newx(arrSource, lenSource, unsigned int);

    for (i=0; i < MAX(lenSource,lenTarget); i++) {
        if(i < lenSource) {
            elem = sv_2mortal(av_shift(arraySource));
            arrSource[ i ] = (unsigned int)SvUV((SV *)elem);
        }

        if(i < lenTarget) {
            elem = sv_2mortal(av_shift(arrayTarget));
            arrTarget[ i ] = (unsigned int)SvUV((SV *)elem);
        }
    }

    /* distance() can't return undef, so has to be 'int' instead of 'unsigned int' 
    /* which limits its possible return value. I will be changing distance() from 
    /* C89 to XS so I can more easily return undef without limiting any values.
    */
    int edistance = distance(arrSource,arrTarget,lenSource,lenTarget,mdx);
    XPUSHs(sv_2mortal( (edistance >= 0) ? newSVuv(edistance) : &PL_sv_undef ));

    Safefree(arrSource);
    Safefree(arrTarget);
}