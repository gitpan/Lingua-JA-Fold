use 5.008;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
	'NAME'         => 'Lingua::JA::Fold',
	'VERSION_FROM' => 'Fold.pm',
	'PREREQ_PM'    => {
		'Encode'       => '1.92',
	},
	($] >= 5.005 ? (
		'ABSTRACT' => 'fold Japanese text',
		'AUTHOR'   => 'Masanori HATA <lovewing@geocities.co.jp>',
	) : ()),
);
