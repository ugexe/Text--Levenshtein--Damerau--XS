use Text::Levenshtein::Damerau::XS qw/xs_edistance cxs_edistance/;
use Benchmark;
use utf8;

my @a = (1,2,3,4);
my @b = (1,3,2,4,5);

my $x = "asdfg";
my $y = "dfas";

print "\n------------------------------------------------\n";

print "#xs small strings\n";
timethis(1000000, 'xs_edistance($x,$y);'); 
print "\n#cxs small strings\n";
timethis(1000000, 'cxs_edistance(\@a,\@b,0);'); 

print "------------------------------------------------\n";

print "#xs medium strings\n";
timethis(1000000, 'xs_edistance($x x 1000,$y x 1000);'); 
print "\n#cxs medium strings\n";
timethis(1000000, 'cxs_edistance(\@{(@a x 1000)},\@{(@b x 1000)},0);'); 

print "------------------------------------------------\n";

print "#xs large strings\n";
timethis(1000000, 'xs_edistance($x x 100000,$y x 100000);'); 
print "\n#cxs medium strings\n";
timethis(1000000, 'cxs_edistance(\@{(@a x 100000)},\@{(@b x 100000)},0);'); 

print "------------------------------------------------\n";

