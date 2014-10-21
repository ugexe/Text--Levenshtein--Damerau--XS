#!perl -T
use 5.008;
use strict;
use warnings FATAL => 'all';
use Test::More tests => 1;

BEGIN { use_ok 'Text::Levenshtein::Damerau::XS', qw/xs_edistance/ }



1;



__END__