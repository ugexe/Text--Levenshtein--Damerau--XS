#!perl -T
use 5.008;
use strict;
use warnings FATAL => 'all';
use Test::More tests => 1;
use Text::Levenshtein::Damerau::XS;

my @a;
$a[48] = 1;
$a[49] = 2;
$a[50] = 1;

my @b;
$b[48] = 2;
$b[49] = 1;
$b[50] = 1;

{
    no warnings qw/uninitialized/;
    is( Text::Levenshtein::Damerau::XS::cxs_edistance(\@a,\@b,0), 1, 'csx_edistance NULL bug');
    use warnings qw/uninitialized/;
}