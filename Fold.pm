package Lingua::JA::Fold;

our $VERSION = '0.00_01'; # 2003-03-27

use 5.008;
use strict;
use warnings;
use Carp;

use Encode;

sub fold_full {
	my($length, $string) = @_;
	my @folded;
	while ($string) {
		if (length_full($string) > $length) {
			my $newfold;
			($newfold, $string) = _cut_full($length, $string);
			push(@folded, $newfold);
		}
		else {
			last;
		}
	}
	my $folded = join("\n", @folded);
	return "$folded\n$string";
}
sub _cut_full {
	my($length, $string) = @_;
	my $chars = $length;
	my $folded = substr($string, 0, $chars);
	my $shortage = $length - length_full($folded);
	while ($shortage != 0) {
		if ($shortage < 0) {
			$chars -= 1;
			$folded = substr($string, 0, $chars);
			last;
		}
		else {
			$chars += int($shortage + 0.5);
			$folded = substr($string, 0, $chars);
			$shortage = $length - length_full($folded);
			next;
		}
	}
	my $unfold = substr($string, $chars);
	return $folded, $unfold;
}

sub fold_mixed {
	my($length, $string) = @_;
	my @folded;
	while ($string) {
		if (length($string) > $length) {
			my $newfold;
			($newfold, $string) = _cut_mixed($length, $string);
			push(@folded, $newfold);
		}
		else {
			last;
		}
	}
	my $folded = join("\n", @folded);
	return "$folded\n$string";
}
sub _cut_mixed {
	my($length, $string) = @_;
	my $folded = substr($string, 0, $length);
	my $unfold = substr($string, $length);
	return $folded, $unfold;
}

########################################################################
sub length_half {
my ($string) = shift;
	$string =~ s/[\x00-\x1F\x7F]//g; # remove all ASCII controls except for [SPACE]
	my $letters = length($string);
	my $half_kana = '｡｢｣､･ｦｧｨｩｪｫｬｭｮｯｰｱｲｳｴｵｶｷｸｹｺｻｼｽｾｿﾀﾁﾂﾃﾄﾅﾆﾇﾈﾉﾊﾋﾌﾍﾎﾏﾐﾑﾒﾓﾔﾕﾖﾗﾘﾙﾚﾛﾜﾝﾞﾟ';
	$half_kana = decode('utf8', $half_kana);
	my $kana = $string =~ s/[$half_kana]//g;
	my $ascii = $string =~ tr/\x20-\x7E//;
	return $letters * 2 - ($ascii + $kana);
}

sub length_full {
my ($string) = shift;
	$string =~ s/[\x00-\x1F\x7F]//g; # remove all ASCII controls except for [SPACE]
	my $letters = length($string);
	my $half_kana = '｡｢｣､･ｦｧｨｩｪｫｬｭｮｯｰｱｲｳｴｵｶｷｸｹｺｻｼｽｾｿﾀﾁﾂﾃﾄﾅﾆﾇﾈﾉﾊﾋﾌﾍﾎﾏﾐﾑﾒﾓﾔﾕﾖﾗﾘﾙﾚﾛﾜﾝﾞﾟ';
	$half_kana = decode('utf8', $half_kana);
	my $kana = $string =~ s/[$half_kana]//g;
	my $ascii = $string =~ tr/\x20-\x7E//;
	return $letters - 0.5 * ($ascii + $kana);
}

# sub length_full_fixed {}

########################################################################
sub tab2space { # replace all [TAB]s with some [SPACE]s.
	my($tab, $string) = @_;
	my $spaces = ' ';
	$spaces x= $tab;
	$string =~ s/\t/$spaces/eg;
	return $string;
}
########################################################################
sub kana_half2full {
	my $string = shift;
	$string = encode('iso-2022-jp', $string);
	$string = decode('iso-2022-jp', $string);
	return $string;
}
########################################################################
1;
__END__

=head1 NAME

Lingua::JA::Fold - fold Japanese text

=head1 SYNOPSIS

 use Lingua::JA::Fold;
 use Encode;
 
 my $text = decode('utf8', 'ｱｲｳｴｵ	漢字');
 
 # replace a [TAB] with 4 of [SPACE]s.
 $text = Lingua::JA::Fold::tab2space(4, $text);
 # convert half pitch 'Kana' letters to full pitch ones.
 $text = Lingua::JA::Fold::kana_half2full($text);
 
 # fold the text under 2 full pitch letters par a line.
 $text = Lingua::JA::Fold::fold_full(2, $text);
 
 # result
 print encode('utf8', $text);

=head1 DESCRIPTION

This module is used for Japanese text wrapping and so on.

Japanese (Chinese and Korean would be the same) text has traditionally unique manner in printing. Basically it is used to be printed in monospace. Its width and height are about the same size. It is different from the alphabet letters which have variable width. Roughly say, we call the pitch of alphabet letters and Arabic numbers as 'half', and do the pitch of other letters as 'full'. In a Japanese text which is mixed with alphabet and Arabic numbers, a letter's width is 'full' or 'half'.

Thus manner makes text wrapping rather complicate thing.

=head1 METHODS

=over

=item fold_full($length, $string)

This method returns folded string within the specified length in full pitch.

=item tab2space($space, $string)

This method converts [TAB] with some [SPACE]s of $space in the $string. Then returns $string.

=item kana_half2full($string)

This method converts half pitch 'Kana's to full pitch ones in the $string. Then returns $string.

=back

=head1 SEE ALSO

=over

=item Perl Module: L<Encode>

=back

=head1 NOTES

This module runs under Unicode/UTF-8 environment (then Perl5.8 or later is required), you should input data in UTF-8 character encoding.

=head1 AUTHOR

Masanori HATA E<lt>lovewing@geocities.co.jpE<gt> (Saitama, JAPAN)

=head1 COPYRIGHT

Copyright (c) 2003 Masanori HATA. All rights reserved.

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut
