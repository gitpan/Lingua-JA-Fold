package Lingua::JA::Fold;

our $VERSION = '0.00_02'; # 2003-03-28

use 5.008;
use strict;
use warnings;
use Carp;

use Encode;

sub new {
	my $class = shift;
	my $self = {};
	bless $self, $class;
	my $string = shift;
	@{ $$self{'line'} } = split(/\n/, $string);
	return $self;
}

sub output {
	my $self = shift;
	my $string = join( "\n", @{ $$self{'line'} } );
	return $string;
}

sub fold_full {
	my($self, $length) = @_;
	foreach my $line ( @{ $$self{'line'} } ) {
		my @folded;
		while ($line) {
			if (length_full($line) > $length) {
				my $newfold;
				($newfold, $line) = _cut_full($length, $line);
				push(@folded, $newfold);
			}
			else {
				last;
			}
		}
		my $folded = join("\n", @folded);
		$line = "$folded\n$line";
	}
	return $self;
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
	my($self, $length) = @_;
	foreach my $line ( @{ $$self{'line'} } ) {
		my @folded;
		while ($line) {
			if (length($line) > $length) {
				my $newfold;
				($newfold, $line) = _cut_mixed($length, $line);
				push(@folded, $newfold);
			}
			else {
				last;
			}
		}
		my $folded = join("\n", @folded);
		$line = "$folded\n$line";
	}
	return $self;
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
	my($self, $tab) = @_;
	my $spaces = ' ';
	$spaces x= $tab;
	foreach my $line ( @{ $$self{'line'} } ) {
		$line =~ s/\t/$spaces/eg;
	}
	return $self;
}
########################################################################
sub kana_half2full {
	my $self = shift;
	foreach my $line ( @{ $$self{'line'} } ) {
		$line = encode('iso-2022-jp', $line);
		$line = decode('iso-2022-jp', $line);
	}
	return $self;
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
 my $obj = Lingua::JA::Fold->new($text);
 
 # replace a [TAB] with 4 of [SPACE]s.
 $obj->tab2space(4);
 # convert half pitch 'Kana' letters to full pitch ones.
 $obj->kana_half2full;
 
 # fold the text under 2 full pitch letters par a line.
 $obj->fold_full(2);
 
 # result
 print encode('utf8', $obj->output);

=head1 DESCRIPTION

This module is used for Japanese text wrapping and so on.

Japanese (Chinese and Korean would be the same) text has traditionally unique manner in printing. Basically it is used to be printed in monospace. Its width and height are about the same size. It is different from the alphabet letters which have variable width. Roughly say, we call the pitch of alphabet letters and Arabic numbers as 'half', and do the pitch of other letters as 'full'. In a Japanese text which is mixed with alphabet and Arabic numbers, a letter's width is 'full' or 'half'.

Thus manner makes text wrapping rather complicate thing.

=head1 METHODS

=over

=item new($string)

This is the constructor method of the module.

=item output

Output the string.

=item fold_full($i)

Fold the string within the specified length of $i in full pitch.

=item tab2space($i)

Replace [TAB] with some [SPACE]s of $i in the string.

=item kana_half2full

Converts from half pitch 'Kana's to full pitch ones in the string.

=back

=head1 SEE ALSO

=over

=item Perl Module: L<Encode>

=back

=head1 NOTES

This module runs under Unicode/UTF-8 environment (hence Perl5.8 or later is required), you should input data in UTF-8 character encoding.

=head1 AUTHOR

Masanori HATA E<lt>lovewing@geocities.co.jpE<gt> (Saitama, JAPAN)

=head1 COPYRIGHT

Copyright (c) 2003 Masanori HATA. All rights reserved.

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut
