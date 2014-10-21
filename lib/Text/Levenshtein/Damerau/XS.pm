package Text::Levenshtein::Damerau::XS;

# generated by Dist::Zilla::Plugin::OurPkgVersion
our $VERSION = '3.01'; # VERSION
our $AUTHORITY = 'cpan:UGEXE'; # AUTHORITY

use 5.008;
use strict;
use warnings FATAL => 'all';
require Exporter;
require XSLoader;
XSLoader::load('Text::Levenshtein::Damerau::XS', $Text::Levenshtein::Damerau::XS::VERSION);

@Text::Levenshtein::Damerau::XS::EXPORT_OK  = qw/xs_edistance lddistance/;
@Text::Levenshtein::Damerau::XS::ISA        = qw/Exporter/;



sub xs_edistance {
    my $distance = lddistance(@_);
    warnings::warnif("deprecated","xs_edistance is depreciated. Please use lddistance which returns undef instead of -1 for distances that exceed the optional \$max_distance");
    return (defined $distance && $distance >= 0) ? $distance : -1;
}



sub lddistance {
    # shift shift shift is faster than $_[0] $_[1] $_[2] 
    return Text::Levenshtein::Damerau::XS::cxs_edistance( [unpack('U*', shift)], [unpack('U*',shift)], shift || 0);
}



1;

=pod

=encoding UTF-8

=head1 NAME

Text::Levenshtein::Damerau::XS - Calculate edit distance based on insertion, deletion, substitution, and transposition

=head1 VERSION

version 3.01

=head1 SYNOPSIS

    use Text::Levenshtein::Damerau::XS qw/lddistance/;

    print lddistance('Neil','Niel');
    # prints 1

=head1 DESCRIPTION

Returns the true Damerau Levenshtein edit distance of strings with adjacent transpositions. XS implementation (requires a C compiler). Works correctly with utf8.

    use Text::Levenshtein::Damerau::XS qw/lddistance/;
    use utf8;

    lddistance('ⓕⓞⓤⓡ','ⓕⓤⓞⓡ'), 
    # prints 1

Speed improvements over L<Text::Levenshtein::Damerau::PP>:

    # Text::Levenshtein::Damerau::PP::pp_edistance("four","fuor")
    timethis 1000000: 381 wallclock secs (380.45 usr +  0.01 sys = 
         380.46 CPU) @ 2628.40/s (n=1000000)

    # Text::Levenshtein::Damerau::XS::lddistance("four","fuor")
    timethis 1000000: 19 wallclock secs (19.43 usr +  0.00 sys = 
         19.43 CPU) @ 51466.80/s (n=1000000)

=for Pod::Coverage dl_load_flags cxs_edistance xs_edistance

=head1 METHODS

=head2 lddistance

=over 4

=item Arguments: $source_text, $target_text, (optional) $max_distance

=item Return value: Int $edit_distance || undef (if max_distance is exceeded)

=back

Returns: int that represents the edit distance between the two argument, or undef if $max_distance threshold is exceeded.

Wrapper function to take the edit distance between a source and target string using XS algorithm implementation.

    use Text::Levenshtein::Damerau::XS qw/lddistance/;
    print lddistance('Neil','Niel');
    # prints 1

    # Set a max edit distance of 1
    print lddistance('Neil','Niely',1); # distance is 2
    # prints -1

=head1 TODO

=over 4

=item * Handle very large strings of text. Can be accomplished by reworking the scoring matrix or writing to disk.

=item * Add from_file methods.

=item * Add binary/byte string support.

=back

=head1 SEE ALSO

=over 4

=item * L<Text::Levenshtein::Damerau>

=item * L<Text::Levenshtein::Damerau::PP>

=back

=head1 REPOSITORY

L<https://github.com/ugexe/Text--Levenshtein--Damerau--XS>

=head1 BUGS

Please report bugs to:

L<https://github.com/ugexe/Text--Levenshtein--Damerau--XS/issues>

=head1 AUTHOR

ugexe <ugexe@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Nick Logan.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

__END__




# ABSTRACT: Calculate edit distance based on insertion, deletion, substitution, and transposition

