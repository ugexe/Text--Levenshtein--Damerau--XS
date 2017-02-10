package Text::Levenshtein::Damerau::XS;
use strict;
use 5.008_008;

require Exporter;
 
$Text::Levenshtein::Damerau::XS::VERSION = '3.2';
@Text::Levenshtein::Damerau::XS::EXPORT_OK = qw/xs_edistance/;
@Text::Levenshtein::Damerau::XS::ISA = qw/Exporter/;

eval {
    require XSLoader;
    XSLoader::load(__PACKAGE__, $Text::Levenshtein::Damerau::XS::VERSION);
    1;
} or do {
    require DynaLoader;
    DynaLoader::bootstrap(__PACKAGE__, $Text::Levenshtein::Damerau::XS::VERSION);
    sub dl_load_flags {0} # Prevent DynaLoader from complaining and croaking
};




sub xs_edistance {
    # shift shift shift is faster than $_[0] $_[1] $_[2] 
    return Text::Levenshtein::Damerau::XS::cxs_edistance( [unpack('U*', shift)], [unpack('U*',shift)], shift || 0);
}

1;

=encoding utf8

=head1 NAME

Text::Levenshtein::Damerau::XS - XS Damerau Levenshtein edit distance.

=head1 SYNOPSIS

	use Text::Levenshtein::Damerau::XS qw/xs_edistance/;

	print xs_edistance('Neil','Niel');
	# prints 1

=head1 DESCRIPTION

Returns the true Damerau Levenshtein edit distance of strings with adjacent transpositions. XS implementation (requires a C compiler). Works correctly with utf8.

	use Text::Levenshtein::Damerau::XS qw/xs_edistance/;
	use utf8;

	xs_edistance('ⓕⓞⓤⓡ','ⓕⓤⓞⓡ'), 
	# prints 1

Speed improvements over L<Text::Levenshtein::Damerau::PP>:

	# Text::Levenshtein::Damerau::PP::pp_edistance("four","fuor")
	timethis 1000000: 381 wallclock secs (380.45 usr +  0.01 sys = 
		 380.46 CPU) @ 2628.40/s (n=1000000)

	# Text::Levenshtein::Damerau::XS::xs_edistance("four","fuor")
	timethis 1000000: 19 wallclock secs (19.43 usr +  0.00 sys = 
		 19.43 CPU) @ 51466.80/s (n=1000000)

=head1 METHODS

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

       # Max edit distance of 1
	print xs_edistance('Neil','Niely',1); # distance is 2
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

=head1 BUGS

Please report bugs to:

L<https://rt.cpan.org/Public/Dist/Display.html?Name=Text-Levenshtein-Damerau-XS>

=head1 AUTHOR

Nick Logan <F<ugexe@cpan.org>>

=head1 LICENSE AND COPYRIGHT

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut
