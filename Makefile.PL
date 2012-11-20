use 5.8.0;
use strict;
use warnings;
use ExtUtils::MakeMaker;

my $pm =   'lib/Text/Levenshtein/Damerau/XS.pm';
my $repo = 'https://github.com/ugexe/Text--Levenshtein--Damerau--XS';
my $bugs = 'https://rt.cpan.org/Public/Dist/Display.html?Name=Text-Levenshtein-Damerau-XS';

WriteMakefile (
    NAME => 'Text::Levenshtein::Damerau::XS',
    VERSION_FROM => $pm,
    ABSTRACT_FROM => $pm,
    AUTHOR => 'Nick Logan <ug@skunkds.org>',
    LICENSE => 'perl',
    MIN_PERL_VERSION => 5.8.0,
    PREREQ_PM => {
    },
    META_MERGE => {
        resources => {
            repository => $repo,
            bugtracker => "$bugs",
        },
    },
);



# Remove the Makefile dependency. Causes problems on a few systems.
sub MY::makefile { '' }
