package PerlIO::fgets;

use strict;
use vars qw[@EXPORT @ISA $VERSION];

BEGIN {
    $VERSION = 0.1;
    @EXPORT  = qw[fgets];

    if ($] >= 5.006) {
        require XSLoader; XSLoader::load(__PACKAGE__, $VERSION);
    }
    else {
        push(@ISA, 'DynaLoader');
        require DynaLoader; __PACKAGE__->bootstrap($VERSION);
    }

    require Exporter;
    *import = \&Exporter::import;
}

1;

