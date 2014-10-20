#!perl -T
use 5.008;
use strict;
use warnings FATAL => 'all';
use Test::More;
use Text::Levenshtein::Damerau::XS qw/xs_edistance/;

subtest 'with no max distance' => sub { 
    is( xs_edistance('four','for'),     1,  'insertion');
    is( xs_edistance('four','four'),    0,  'matching');
    is( xs_edistance('four','fourth'),  2,  'deletion');
    is( xs_edistance('four','fuor'),    1,  'transposition');
    is( xs_edistance('four','fxxr'),    2,  'substitution');
    is( xs_edistance('four','FOuR'),    3,  'case');
    is( xs_edistance('four',''),        4,  'target empty');
    is( xs_edistance('','four'),        4,  'source empty');
    is( xs_edistance('',''),            0,  'source and target empty');
    is( xs_edistance('111','11'),       1,  'numbers');
};

subtest 'distance using a max distance' => sub {
    is( xs_edistance('xxx','x',1),     -1,  '> max distance setting');
    is( xs_edistance('xxx','xx',1),    -1,  '> max distance setting');
    is( xs_edistance('xxx','xx',1),     1,  '<= max distance setting');
    is( xs_edistance("xxx","xxxx",1),   1,  'misc 1');
    is( xs_edistance("xxx","xxxx",2),   1,  'misc 2');
    is( xs_edistance("xxx","xxxx",3),   1,  'misc 3');
    is( xs_edistance("xxxx","xxx",1),   1,  'misc 4');
    is( xs_edistance("xxxx","xxx",2),   1,  'misc 5');
    is( xs_edistance("xxxx","xxx",3),   1,  'misc 6');
};

subtest 'distance using utf8' => sub {
    use utf8;
    binmode STDOUT, ":encoding(utf8)";
    is( xs_edistance('ⓕⓞⓤⓡ','ⓕⓞⓤⓡ'),    0,  'matching');
    is( xs_edistance('ⓕⓞⓤⓡ','ⓕⓞⓡ'),     1,  'insertion');
    is( xs_edistance('ⓕⓞⓤⓡ','ⓕⓞⓤⓡⓣⓗ') , 2,  'deletion');
    is( xs_edistance('ⓕⓞⓤⓡ','ⓕⓤⓞⓡ'),    1,  'transposition');
    is( xs_edistance('ⓕⓞⓤⓡ','ⓕⓧⓧⓡ'),    2,  'substitution');
    is( xs_edistance('ⓕⓞⓤⓡ','ⓕⓧⓧⓡ',10), 2,  'substitution with maxDistance=10');
};



done_testing();
1;



__END__