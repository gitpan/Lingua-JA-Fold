package Lingua::JA::Fold;

our $VERSION = '0.01'; # 2003-04-02

use 5.008;
use strict;
use warnings;
# use Carp;

use Encode;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(
	length_full length_half
);

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

sub fold {
	my($self, $length) = @_;
	foreach my $line ( @{ $$self{'line'} } ) {
		$line = decode('utf8', $line);
		my @folded;
		while ($line) {
			if (length_full( encode('utf8', $line) ) > $length) {
				my $newfold;
				($newfold, $line) = _cut($length, $line);
				push(@folded, $newfold);
			}
			else {
				last;
			}
		}
		my $folded = join("\n", @folded);
		if ($folded) {
			$line = "$folded\n$line";
		}
		$line = encode('utf8', $line);
	}
	return $self;
}
sub _cut {
	my($length, $string) = @_;
	my $chars = $length;
	my $folded = substr($string, 0, $chars);
	my $shortage = $length - length_full( encode('utf8', $folded) );
	while ($shortage != 0) {
		if ($shortage < 0) {
			$chars -= 1;
			$folded = substr($string, 0, $chars);
			last;
		}
		else {
			$chars += int($shortage + 0.5);
			$folded = substr($string, 0, $chars);
			$shortage = $length - length_full( encode('utf8', $folded) );
			next;
		}
	}
	my $unfold = substr($string, $chars);
	return $folded, $unfold;
}

sub fold_mixed {
	my($self, $length) = @_;
	foreach my $line ( @{ $$self{'line'} } ) {
		$line = decode('utf8', $line);
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
		if ($folded) {
			$line = "$folded\n$line";
		}
		$line = encode('utf8', $line);
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
	my  $string = shift;
	$string =~ tr/\x00-\x1F\x7F//d; # remove all ASCII controls except for [SPACE]
	my $ascii  = $string =~ tr/\x20-\x7E//d;
	$string = decode('utf8', $string);
	my $halfwidth = $string =~ tr/\x{FF61}-\x{FF9F}\x{FFE0}-\x{FFE5}//d;
	my $letters = length($string);
	return 2 * $letters + $ascii + $halfwidth;
}

sub length_full {
	my $string = shift;
	# remove all ASCII controls except for [SPACE]
	$string =~ tr/\x00-\x1F\x7F//d;
	# ascii: arabic numbers, alphabets, marks
	my $ascii  = $string =~ tr/\x20-\x7E//d;
	$string = decode('utf8', $string);
	# half-width characters in the Unicode compatibility area
	my $halfwidth = $string =~ tr/\x{FF61}-\x{FF9F}\x{FFE0}-\x{FFE5}//d;
	# full-width characters
	my $letters = length($string);
	return $letters + 0.5 * ($ascii + $halfwidth);
}

# sub _length_full_fixed {}

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
		$line = encode( 'iso-2022-jp', decode('utf8', $line) );
		$line = encode( 'utf8', decode('iso-2022-jp', $line) );
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
 
 my $text = 'ｱｲｳｴｵ	漢字';
 my $obj = Lingua::JA::Fold->new($text);
 
 # replace a [TAB] with 4 of [SPACE]s.
 $obj->tab2space(4);
 # convert half-width 'Kana' characters to full-width ones.
 $obj->kana_half2full;
 
 # fold the text under 2 full-width characters par a line.
 $obj->fold(2);
 
 # result
 print $obj->output;

=head1 DESCRIPTION

This module is used for Japanese text wrapping and so on.

Japanese (Chinese and Korean would be the same) text has traditionally unique manner in printing. Basically those characters are used to be printed in the two size of 'full-width' or 'half-width'. The full-width characters' width and height are about the same size (regular square). At this point, it is different from the alphabet characters which have normally variable width in printing. Roughly say, we call the width of alphabet letters and Arabic numbers as half, and do the width of other characters as full. In a Japanese text which is mixed with alphabet and Arabic numbers, a character's width is full or half.

Thus manner seems to make text wrapping rather complicate thing.

=head1 METHODS

=over

=item new($string)

This is the class constructor method of the module.

=item output

This method outputs the string.

=item fold($i)

This method folds the string within the specified length of $i in full-width.

=item tab2space($i)

This method replaces [TAB] with some [SPACE]s of $i in the string.

=item kana_half2full

This method converts from half-width 'Kana's to full-width ones in the string.

=item length_full($text)

This method is for counting length of the $text in full-width. 

=item length_half($text)

This method is for counting length of the $text in half-width. 

=back

=head1 SEE ALSO

=over

=item Perl Module: L<Encode>

=back

=head1 NOTES

This module runs under Unicode/UTF-8 environment (hence Perl5.8 or later is required), you should input octets with UTF-8 charset (still do not turn utf8 flag on).

=head1 TO DO

=over

=item Support to reflect rule of the forbidden marks.

=back

=head1 AUTHOR

Masanori HATA E<lt>lovewing@geocities.co.jpE<gt> (Saitama, JAPAN)

=head1 COPYRIGHT

Copyright (c) 2003 Masanori HATA. All rights reserved.

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut
