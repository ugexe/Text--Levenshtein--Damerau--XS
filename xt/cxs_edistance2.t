use strict;
use warnings;
use Test::More tests => 15;
use Text::Levenshtein::Damerau::XS;
use Encode qw/encode_utf8/;
print Text::Levenshtein::Damerau::XS::cxs_edistance2(encode_utf8("x"),encode_utf8("fuor"),0) . "\n"; #should = 4
print Text::Levenshtein::Damerau::XS::cxs_edistance2("x","fuor",0) . "\n"; #should = 4
die;

is( Text::Levenshtein::Damerau::XS::cxs_edistance2('four','for',0), 		1, 'test xs_edistance insertion');
is( Text::Levenshtein::Damerau::XS::cxs_edistance2('four','four',0), 		0, 'test xs_edistance matching');
is( Text::Levenshtein::Damerau::XS::cxs_edistance2('four','fourth',0), 	2, 'test xs_edistance deletion');
is( Text::Levenshtein::Damerau::XS::cxs_edistance2('four','fuor',0), 		1, 'test xs_edistance transposition');
is( Text::Levenshtein::Damerau::XS::cxs_edistance2('four','fxxr',0), 		2, 'test xs_edistance substitution');
is( Text::Levenshtein::Damerau::XS::cxs_edistance2('four','FOuR',0), 		3, 'test xs_edistance case');
is( Text::Levenshtein::Damerau::XS::cxs_edistance2('four','',0), 		4, 'test xs_edistance target empty');
is( Text::Levenshtein::Damerau::XS::cxs_edistance2('','four',0), 		4, 'test xs_edistance source empty');
is( Text::Levenshtein::Damerau::XS::cxs_edistance2('','',0), 			0, 'test xs_edistance source and target empty');
is( Text::Levenshtein::Damerau::XS::cxs_edistance2('111','11',0), 		1, 'test xs_edistance numbers');
#is( Text::Levenshtein::Damerau::XS::cxs_edistance2('xxx','x',1),   	      -1, 'test xs_edistance > max distance setting');
#is( Text::Levenshtein::Damerau::XS::cxs_edistance2('xxx','xx',1),	   	1, 'test xs_edistance <= max distance setting');

# Test some utf8
use utf8;
binmode STDOUT, ":encoding(utf8)";
is( Text::Levenshtein::Damerau::XS::cxs_edistance2('ⓕⓞⓤⓡ','ⓕⓞⓤⓡ',0), 		0, 'test xs_edistance matching (utf8)');
is( Text::Levenshtein::Damerau::XS::cxs_edistance2('ⓕⓞⓤⓡ','ⓕⓞⓡ',0), 		1, 'test xs_edistance insertion (utf8)');
is( Text::Levenshtein::Damerau::XS::cxs_edistance2('ⓕⓞⓤⓡ','ⓕⓞⓤⓡⓣⓗ',0),	2, 'test xs_edistance deletion (utf8)');
is( Text::Levenshtein::Damerau::XS::cxs_edistance2('ⓕⓞⓤⓡ','ⓕⓤⓞⓡ',0), 		1, 'test xs_edistance transposition (utf8)');
is( Text::Levenshtein::Damerau::XS::cxs_edistance2('ⓕⓞⓤⓡ','ⓕⓧⓧⓡ',0), 		2, 'test xs_edistance substitution (utf8)');
	