use strict;
use warnings;
use Text::Levenshtein::Damerau::XS qw/xs_edistance cxs_edistance/;
use Benchmark qw/:hireswallclock timethese cmpthese/;
use utf8;

# csx benchmarks all have the same results, not sure why
print "\n\n"!!csx benchmark speed not accurate!!\n\n"; 

my $test_count = 1000000;

print "\n------------------------------------------------\n";
print "SMALL STRINGS (4*4 chars per string)\n";

my $s1 = 1;
my $x1 = "asdf" x $s1;
my $y1 = "adsfg" x $s1;
my @a1 = (1,2,3,4) x $s1;
my @b1 = (1,3,2,4,5) x $s1;

my $small_results = timethese($test_count, { xs => 'xs_edistance(\$x1,\$y1);', csx => 'cxs_edistance(\@a1,\@b1,0);' }); 
cmpthese($small_results);

print "------------------------------------------------\n";
print "MEDIUM STRINGS (4*1000 chars per string)\n";

my $s2 = 1000;
my $x2 = "asdf" x $s2; 
my $y2 = "adsfg" x $s2;
my @a2 = ((1,2,3,4) x $s2);
my @b2 = ((1,3,2,4,5) x $s2);

my $medium_results = timethese($test_count, { xs => 'xs_edistance(\$x2,\$y2);', csx => 'cxs_edistance(\@a2,\@b2,0);' }); 
cmpthese($medium_results);

print "------------------------------------------------\n";
print "LARGE STRINGS (4*100,000 chars per string)\n";

my $s3 = 100000;
my $x3 = "asdf" x $s3;
my $y3 = "adsfg" x $s3;
my @a3 = ((1,2,3,4) x $s3);
my @b3 = ((1,3,2,4,5) x $s3);

my $large_results = timethese($test_count, { xs => 'xs_edistance(\$x3,$\y3)', csx => 'cxs_edistance(\@a3,\@b3,0)' }); 
cmpthese($large_results);

print "------------------------------------------------\n";

print "HUGE STRINGS (4*10,000,000 chars pre string)\n";

my $s4 = 10000000;
my $x4 = "asdf" x $s4;
my $y4 = "adsfg" x $s4;
my @a4 = ((1,2,3,4) x $s4);
my @b4 = ((1,3,2,4,5) x $s4);

my $huge_results = timethese($test_count, { xs => 'xs_edistance(\$x4,\$y4)', csx => 'cxs_edistance(\@a4,\@b4,0)' }); 
cmpthese($huge_results);

print "------------------------------------------------\n";

