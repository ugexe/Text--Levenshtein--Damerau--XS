use strict;
use warnings;
use Test::More tests => 1;
use Text::Levenshtein::Damerau::XS qw/cxs_edistance/;

my @a;
$a[50] = 1;
my @b;
$b[50] = 1;
is( cxs_edistance(\@a,\@b,0),		0, 'test csx_edistance NULL bug');
