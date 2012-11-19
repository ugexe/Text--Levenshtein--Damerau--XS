use strict;
use warnings;
use ExtUtils::MakeMaker;

my $pm =   'lib/Text/Levenshtein/Damerau/XS.pm';
my $bugs = 'https://rt.cpan.org/Public/Dist/Display.html?Name=Text-Levenshtein-Damerau-XS';

WriteMakefile (
    NAME => 'Text::Levenshtein::Damerau::XS',
    VERSION_FROM => $pm,
    ABSTRACT_FROM => $pm,
    AUTHOR => 'Nick Logan <ug@skunkds.org>',
    LICENSE => 'perl',
    PREREQ_PM => {
    },
    META_MERGE => {
        resources => {
            bugtracker => "$bugs",
        },
    },
);



# Remove the Makefile dependency. Causes problems on a few systems.
sub MY::makefile { '' }
