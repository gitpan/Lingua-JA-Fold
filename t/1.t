# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl 1.t'

# this code is written in Unicode/UTF-8 character-set
# including Japanese letters.

use strict;
use warnings;

use Test::More tests => 5;

use Encode;

BEGIN { use_ok('Lingua::JA::Fold') };

my $text = decode('utf8', 'ｱｲｳｴｵ	漢字');

# replace a [TAB] with 4 of [SPACE]s.
$text = Lingua::JA::Fold::tab2space(4, $text);
my $got = encode('utf8', $text);
my $expected = 'ｱｲｳｴｵ    漢字';
is ( $got, $expected,
	'[TAB] -> [SPACE] convert');

# convert half pitch 'Kana' letters to full pitch ones.
$got = Lingua::JA::Fold::kana_half2full($text);
$got = encode('utf8', $got);
$expected = 'アイウエオ    漢字';
is ( $got, $expected,
	'from half-pitch to full-pitch \'Kana\' convert');

# fold the text under 2 full pitch letters par a line.
$text = Lingua::JA::Fold::fold_full(2, $text);
$got = encode('utf8', $text);
$expected = 'ｱｲｳｴ
ｵ   
 漢
字';
is ( $got, $expected,
	'folding');

# final long text trial
$text = decode('utf8', 'ｱｲｳｴｵapougaobuaEmailアドレスも必須です（こちらから返事をする際に必要となりますので、アドレスの記入ミスをなさらぬようご注意下さい）。改行は、原則として段落を変えたい時のみ使用するgaoubaようにしてください。aaaa手a動で行を折り返して長さを揃える必要はありません。 作成中に誤って消してしまった場合はショックが大きいものです。特に長文の場合などは、一旦、テキストエディタやワープロ等で原稿を作成してから、それをメールの書き込み欄にコピー＆ペーストして送信するやり方にすれば安aaa全です。 Emailアドレスも必須です（こちらから返事をoubabaする際に必要となりますので、アドレスの記入ミスをなさらぬようご注意下さい）。改行は、原則として段落を変えたい時のみ使用するようにしてください。aaaa手a動で行を折り返して長さを揃える必要はありません。作成中に誤って消してしまった場合はショックが大きいもagaのです。特にagabb長文の場合などは、一旦、テキストエディタやワープロ等で原稿を作成してから、それをメールの書き込み欄にコピー＆ペーストして送信するやり方にすれば安全です。Emailアドレスも必須です（こちらから返事をする際に必要となりますので、アドレスの記入ミスをなさらぬようご注意下さい）。 改行は、原則として段落を変えたい時のみ使用するようにしてください。aaaa手a動で行を折り返して長さを揃える必要はありません。 作成中に誤って消してしまった場合はショックが大きいものです。特に長文の場合などは、一旦、テキストエディタやワープロ等で原稿を作成してから、それをメールの書き込み欄にコピー＆ペーストして送信するやり方にすれば安全です。');
$text = Lingua::JA::Fold::fold_full(7, $text);
$got = encode('utf8', $text);
$expected = 'ｱｲｳｴｵapougaobu
aEmailアドレス
も必須です（こ
ちらから返事を
する際に必要と
なりますので、
アドレスの記入
ミスをなさらぬ
ようご注意下さ
い）。改行は、
原則として段落
を変えたい時の
み使用するgaou
baようにしてく
ださい。aaaa手
a動で行を折り
返して長さを揃
える必要はあり
ません。 作成
中に誤って消し
てしまった場合
はショックが大
きいものです。
特に長文の場合
などは、一旦、
テキストエディ
タやワープロ等
で原稿を作成し
てから、それを
メールの書き込
み欄にコピー＆
ペーストして送
信するやり方に
すれば安aaa全
です。 Emailア
ドレスも必須で
す（こちらから
返事をoubabaす
る際に必要とな
りますので、ア
ドレスの記入ミ
スをなさらぬよ
うご注意下さい
）。改行は、原
則として段落を
変えたい時のみ
使用するように
してください。
aaaa手a動で行
を折り返して長
さを揃える必要
はありません。
作成中に誤って
消してしまった
場合はショック
が大きいもaga
のです。特にag
abb長文の場合
などは、一旦、
テキストエディ
タやワープロ等
で原稿を作成し
てから、それを
メールの書き込
み欄にコピー＆
ペーストして送
信するやり方に
すれば安全です
。Emailアドレ
スも必須です（
こちらから返事
をする際に必要
となりますので
、アドレスの記
入ミスをなさら
ぬようご注意下
さい）。 改行
は、原則として
段落を変えたい
時のみ使用する
ようにしてくだ
さい。aaaa手a
動で行を折り返
して長さを揃え
る必要はありま
せん。 作成中
に誤って消して
しまった場合は
ショックが大き
いものです。特
に長文の場合な
どは、一旦、テ
キストエディタ
やワープロ等で
原稿を作成して
から、それをメ
ールの書き込み
欄にコピー＆ペ
ーストして送信
するやり方にす
れば安全です。';
is ( $got, $expected,
	'folding: final long text trial');
