use 5.008;
use ExtUtils::MakeMaker;

WriteMakefile(
	'NAME'         => 'Lingua::JA::Fold',
	'VERSION_FROM' => 'Fold.pm',
	'PREREQ_PM'    => {
		'Exporter' => '5.567',
		'Encode'   => '1.98',
	},
	($] >= 5.005 ? (
		'ABSTRACT' => 'fold Japanese text, and more...',
		'AUTHOR'   => 'Masanori HATA <lovewing@dream.big.or.jp>',
	) : ()),
);
