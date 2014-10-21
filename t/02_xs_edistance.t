#!perl -T
use 5.008;
use strict;
use warnings FATAL => 'all', NONFATAL => 'deprecated';
use Test::More 0.88;
use Text::Levenshtein::Damerau::XS qw/lddistance xs_edistance/;

subtest 'with no max distance' => sub { 
    is( lddistance('four','for'),       1,  'insertion');
    is( lddistance('four','four'),      0,  'matching');
    is( lddistance('four','fourth'),    2,  'deletion');
    is( lddistance('four','fuor'),      1,  'transposition');
    is( lddistance('four','fxxr'),      2,  'substitution');
    is( lddistance('four','FOuR'),      3,  'case');
    is( lddistance('four',''),          4,  'target empty');
    is( lddistance('','four'),          4,  'source empty');
    is( lddistance('',''),              0,  'source and target empty');
    is( lddistance('111','11'),         1,  'numbers');
};

subtest 'distance using a max distance' => sub {
    is( lddistance('xxx','x',1),    undef,  '> max distance setting');
    is( lddistance('xxx','xx',1),       1,  '<= max distance setting');
    is( lddistance("xxx","xxxx",1),     1,  'misc 1');
    is( lddistance("xxx","xxxx",2),     1,  'misc 2');
    is( lddistance("xxx","xxxx",3),     1,  'misc 3');
    is( lddistance("xxxx","xxx",1),     1,  'misc 4');
    is( lddistance("xxxx","xxx",2),     1,  'misc 5');
    is( lddistance("xxxx","xxx",3),     1,  'misc 6');
    is( lddistance("xxxx","xx",1),  undef,  'misc 7');
    is( lddistance("eaxx","ae",2),  undef,  'misc 8');
    is( lddistance("eaxx","aex",2),     2,  'misc 8');
};

subtest 'distance using utf8' => sub {
    use utf8;
    binmode STDOUT, ":encoding(utf8)";
    is( lddistance('ⓕⓞⓤⓡ','ⓕⓞⓤⓡ'),      0,  'matching');
    is( lddistance('ⓕⓞⓤⓡ','ⓕⓞⓡ'),       1,  'insertion');
    is( lddistance('ⓕⓞⓤⓡ','ⓕⓞⓤⓡⓣⓗ') ,   2,  'deletion');
    is( lddistance('ⓕⓞⓤⓡ','ⓕⓤⓞⓡ'),      1,  'transposition');
    is( lddistance('ⓕⓞⓤⓡ','ⓕⓧⓧⓡ'),      2,  'substitution');
    is( lddistance('ⓕⓞⓤⓡ','ⓕⓧⓧⓡ',10),   2,  'substitution with maxDistance=10');
};

subtest 'backwards compatability' => sub {
    is  ( xs_edistance('fo','four',1),                        -1, '> max distance setting (deprecated xs_edistance)');
    is  ( lddistance('fo','four',1),                       undef, '> max distance setting (lddistance)');
    is  ( lddistance('fo','four'),     xs_edistance('fo','four'), 'lddistance == xs_edistance when $max_distance IS NOT exceeded');    
    isnt( lddistance('fo','four',1), xs_edistance('fo','four',1), 'lddistance != xs_edistance when $max_distance exceeded (undef and -1)');
};



done_testing();
1;



__END__