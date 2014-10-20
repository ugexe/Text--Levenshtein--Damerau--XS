use strict;
use warnings;

# this test was generated with Dist::Zilla::Plugin::Test::NoTabs 0.09

use Test::More 0.88;
use Test::NoTabs;

my @files = (
    'lib/Text/Levenshtein/Damerau/XS.pm',
    't/00-compile.t',
    't/00-report-prereqs.dd',
    't/00-report-prereqs.t',
    't/00_compile.t',
    't/01_imports.t',
    't/02_xs_edistance.t'
);

notabs_ok($_) foreach @files;
done_testing;
