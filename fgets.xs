#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

MODULE = PerlIO::fgets    PACKAGE = PerlIO::fgets

PROTOTYPES: ENABLE

SV *
fgets(fp, count)
    PerlIO *fp
    ssize_t count

  CODE:
    if (count < 0)
        XSRETURN_UNDEF;

    RETVAL = newSVpvn("", 0);

    if (PerlIO_fast_gets(fp)) {

        while (count > 0) {
            SSize_t avail = PerlIO_get_cnt(fp);
            SSize_t take = 0;

            if (avail > 0)
                take = (count < avail) ? count : avail;

            if (take > 0) {
                STDCHAR *ptr = (STDCHAR *)PerlIO_get_ptr(fp);
                STDCHAR *found = memchr(ptr, '\n', take);

                if (found != NULL)
                    count = take = ++found - ptr;

                sv_catpvn(RETVAL, ptr, take);
                count -= take;
                avail -= take;
                PerlIO_set_ptrcnt(fp, (void *)ptr + take, avail);
            }

            if (count > 0 && avail <= 0) {
#if ((PERL_REVISION == 5) && (PERL_VERSION >= 7))
                if (PerlIO_fill(fp) != 0)
                    break;
#else
                const int ch = PerlIO_getc(fp);
                if (ch == EOF)
                    break;

                PerlIO_ungetc(fp, ch);
#endif
            }
        }
    }
    else {
        STDCHAR buf[8192];
        SSize_t copy;
        int ch = EOF;

        while (count > 0) {
            STDCHAR *bp = buf;
            STDCHAR *bpe = buf + sizeof(buf);

            while (bp < bpe && count-- > 0 && (ch = PerlIO_getc(fp)) != EOF)
                if ((*bp++ = ch) == '\n')
                    break;

            if ((copy = bp - buf) > 0)
                sv_catpvn(RETVAL, buf, copy);

            if (ch == EOF || ch == '\n')
                break;
        }
    }

    if (PerlIO_error(fp)) {
        SvREFCNT_dec(RETVAL);
        XSRETURN_UNDEF;
    }

  OUTPUT:
    RETVAL

