package Text::Levenshtein::Damerau::XS;
use 5.8.0;

require Exporter;
*import = \&Exporter::import;
require DynaLoader;

$Text::Levenshtein::Damerau::XS::VERSION = '1.2';

DynaLoader::bootstrap Text::Levenshtein::Damerau::XS $Text::Levenshtein::Damerau::XS::VERSION;

@Text::Levenshtein::Damerau::XS::EXPORT = ();
@Text::Levenshtein::Damerau::XS::EXPORT_OK = qw(
	cxs_edistance 
	xs_edistance
    );

sub dl_load_flags {0} # Prevent DynaLoader from complaining and croaking

sub xs_edistance {
    # Wrapper for XS cxs_edistance function
    my $str1 = shift;
    my $str2 = shift;
    my $maxd = shift;
    $maxd ||= 0;
    $maxd = 0 unless($maxd =~ m/^\d+$/);

    my @arr1 = unpack 'U*', $str1;
    my @arr2 = unpack 'U*', $str2;
     
    return cxs_edistance( \@arr1, \@arr2, $maxd );
}


1;

=encoding utf8

=head1 NAME

Text::Levenshtein::Damerau::XS - XS Damerau Levenshtein edit distance.

=head1 SYNOPSIS

	use Text::Levenshtein::Damerau::XS qw/xs_edistance/;
	use warnings;
	use strict;

	print xs_edistance('Neil','Niel');
	# prints 1

=head1 DESCRIPTION

Returns the true Damerau Levenshtein edit distance of strings with adjacent transpositions. XS implementation (requires a C compiler). Works correctly with utf8.

	use utf8;
	xs_edistance('ⓕⓞⓤⓡ','ⓕⓤⓞⓡ'), 
	# prints 1

Speed improvements over L<Text::Levenshtein::Damerau::PP>:

	# Text::Levenshtein::Damerau::PP
	timethis 1000000: 699 wallclock secs (697.60 usr +  0.00 sys =
               697.60 CPU) @ 1433.49/s (n=1000000)

	# Text::Levenshtein::Damerau::XS
	timethis 1000000: 21 wallclock secs (20.63 usr +  0.00 sys =
               20.63 CPU) @ 48473.10/s (n=1000000)

=head1 METHODS

=head1 EXPORTABLE METHODS

=head2 xs_edistance

Arguments: source string and target string.

=over

=item * I<OPTIONAL 3rd argument> int (max distance; only return results with $int distance or less). 0 = unlimited. Default = 0.

=back

Returns: int that represents the edit distance between the two argument. Stops calculations and returns -1 if max distance is set and reached.

Wrapper function to take the edit distance between a source and target string using XS algorithm implementation.

	use Text::Levenshtein::Damerau::XS qw/xs_edistance/;
	print xs_edistance('Neil','Niel');
	# prints 1

	print xs_edistance('Neil','Nielx',1);
	# prints -1

=head1 SEE ALSO

=over 4

=item * L<Text::Levenshtein::Damerau>

=item * L<Text::Levenshtein::Damerau::PP>

=back

=head1 BUGS

Please report bugs to:

L<https://rt.cpan.org/Public/Dist/Display.html?Name=Text-Levenshtein-Damerau-XS>

=head1 AUTHOR

Nick Logan <F<ug@skunkds.com>>

=head1 LICENSE AND COPYRIGHT

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut
