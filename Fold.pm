package Lingua::JA::Fold;

use 5.008;
use strict;
use warnings;
# use Carp;

our $VERSION = '0.03'; # 2003-04-13 (since 2003-03-26)

use utf8;

use Encode;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(
	length_full length_half
);

=head1 NAME

Lingua::JA::Fold - fold Japanese text, and more...

=head1 SYNOPSIS

 use utf8;
 use Lingua::JA::Fold;
 
 my $text = 'ｱｲｳｴｵ	漢字';
 my $obj = Lingua::JA::Fold->new($text);
 
 # replace a [TAB] with 4 of [SPACE]s.
 $obj->tab2space(4);
 # convert half-width 'Kana' characters to full-width ones.
 $obj->kana_half2full;
 
 # fold the text under 2 full-width characters par a line.
 $obj->fold(2);
 
 # output the result
 print $obj->output;

=head1 DESCRIPTION

This module is used for Japanese text wrapping and so on.

The Japanese (the Chinese and the Korean would be the same) text has traditionally unique manner in representing. Basically those characters are used to be printed in two size of 'full-width' or 'half-width'. The width of full-width characters and the height of those are about the same size (regular square). At this point, it is different from the alphabet characters which have normally variable (slim) width in representing. Roughly say, we call the width of alphabet characters and Arabic numbers as half, and do the width of other characters as full. In a Japanese text which is mixed with alphabet and Arabic numbers, a character has a width, it would be full or half.

Thus manner seems to make text wrapping rather complicate thing.

=head1 METHODS and FUNCTIONS

=over

=item new($string)

This is the constructor class method of the module.

=cut

sub new {
	my $class = shift;
	my $self = {};
	bless $self, $class;
	my $string = shift;
	@{ $$self{'line'} } = split(/(\n)/, $string);
	return $self;
}

=item output

This class method outputs the string.

=cut

sub output {
	my $self = shift;
	my $string = join( '', @{ $$self{'line'} } );
	return $string;
}

=item fold($i)

This object method folds up the string within the specified length of $i calculated as full-width characters.

=cut

sub fold {
	my($self, $length) = @_;
	foreach my $line ( @{ $$self{'line'} } ) {
		my @folded;
		while ($line) {
			if (length_full($line) > $length) {
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
	}
	return $self;
}

sub _cut {
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

=item fold_ex($i)

This object method folds the string within the specified length of $i calculated as full-width characters. In addition to that, this method estimates the forbidden rule for the specific marks. It is said that this method is rather formal than the fold() as the Japanese text.

The forbidden rule is: 1) the termination marks like Ten "," and Maru ".", 2) closing marks -- brace or parenthesis or bracket -- like ")", "}", "]", ">" and etc., 3) repeat marks, those should not be at the top of a line. If it would be occured, these marks should be moved to the place at the end of the previous line.

Actually by this module what is detect as a forbidden mark are listed next:

 、，。．」’』”〟）】〉》］〕｝々ゝゞヽヾ〃

Note that these marks are all full-width Japanese characters.

=cut

my $Forbidden = '、，。．」’』”〟）】〉》］〕｝々ゝゞヽヾ〃';

sub fold_ex {
	my($self, $length) = @_;
	
	foreach my $line ( @{ $$self{'line'} } ) {
		my @folded;
		while ($line) {
			if (length_full($line) > $length) {
				my $newfold;
				($newfold, $line) = _cut_ex($length, $line);
				push(@folded, $newfold);
			}
			else {
				last;
			}
		}
		my $folded = join("\n", @folded);
		if ($folded) {
			if ($line) {
				$line = "$folded\n$line";
			}
			else {
				$line = $folded;
			}
		}
	}
	
	return $self;
}

sub _cut_ex {
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
	
	while ($unfold) {
		my $char_top = substr($unfold, 0, 1);
		if ($char_top =~ /[$Forbidden]/) {
			$folded .= $char_top;
			$unfold = substr($unfold, 1);
			next;
		}
		else {
			last;
		}
	}
	
	return $folded, $unfold;
}

=item fold_easy($i)

This object method folds the string just as is within the specified length of $i. The difference between full-width and half-width will be ignored. Easy to implementing :)

=cut

sub fold_easy {
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
		if ($folded) {
			$line = "$folded\n$line";
		}
	}
	return $self;
}

sub _cut_mixed {
	my($length, $string) = @_;
	my $folded = substr($string, 0, $length);
	my $unfold = substr($string, $length);
	return $folded, $unfold;
}

=item length_half($text)

This exportable function is for counting length of the $text as half-width characters. 

=cut

sub length_half {
	my $string = shift;
	
	# remove all ASCII controls except for [SPACE]
	$string =~ tr/\x00-\x1F\x7F//d;
	
	# ascii: arabic numbers, alphabets, marks
	my $ascii     = $string =~ tr/\x20-\x7E//d;
	# half-width characters in the Unicode compatibility area
	my $halfwidth = $string =~ tr/\x{FF61}-\x{FF9F}\x{FFE0}-\x{FFE5}//d;
	# the rest: full-width characters
	my $rest = length($string);
	
	return $ascii + $halfwidth + $rest * 2;
}

=item length_full($text)

This exportable function is for counting length of the $text as full-width characters. 

=cut

sub length_full {
	my $string = shift;
	
	# remove all ASCII controls except for [SPACE]
	$string =~ tr/\x00-\x1F\x7F//d;
	
	# ascii: arabic numbers, alphabets, marks
	my $ascii     = $string =~ tr/\x20-\x7E//d;
	# half-width characters in the Unicode compatibility area
	my $halfwidth = $string =~ tr/\x{FF61}-\x{FF9F}\x{FFE0}-\x{FFE5}//d;
	# the rest: full-width characters
	my $rest = length($string);
	
	return ($ascii + $halfwidth) * 0.5 + $rest;
}

# sub _length_full_fixed {}

=item tab2space($i)

This object method replaces a [TAB] character with $i of [SPACE]s of the string.

=cut

sub tab2space { # replace all [TAB]s with some [SPACE]s.
	my($self, $tab) = @_;
	my $spaces = ' ';
	$spaces x= $tab;
	foreach my $line ( @{ $$self{'line'} } ) {
		$line =~ s/\t/$spaces/eg;
	}
	return $self;
}

=item kana_half2full

This object method converts from half-width 'Kana's to full-width ones of the string.

=cut

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

=back

=head1 SEE ALSO

=over

=item module: L<utf8>

=item module: L<Encode>

=back

=head1 NOTES

This module runs under Unicode/UTF-8 environment (hence Perl5.8 or later is required), you should input octets with UTF-8 charset. Please C<use utf8;> pragma to enable to detect strings as UTF-8 in your source code.

=head1 AUTHOR

Masanori HATA E<lt>lovewing@geocities.co.jpE<gt> (Saitama, JAPAN)

=head1 COPYRIGHT

Copyright (c) 2003 Masanori HATA. All rights reserved.

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut

