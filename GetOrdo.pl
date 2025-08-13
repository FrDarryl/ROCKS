#!/usr/bin/env perl

use strict;
use warnings;

my $usage = "Usage: $0 Rite(NOE|VOE) Date(YYYY)\n";

if ($#ARGV != 1) {
    die $usage;
}

my $rite = shift;
my $year = shift;

unless ($year =~ m/\d{4}/) {
    die $usage;
}

my $url;

if ($rite eq "NOE") {
    $url = "http://www.universalis.com/europe.england.portsmouth/${year}0101/vcalendar.ics";
} elsif ($rite eq "VOE") {
    $url = "http://www.universalis.com/europe.england.ordinariate/${year}0101/vcalendar.ics";
} else {
    die $usage
}
#print "URL: $url\n";

#https://stackoverflow.com/questions/9565844/using-lwp-to-get-webpage-contents
use LWP::UserAgent;

my $ua = new LWP::UserAgent;
my $request = HTTP::Request->new('GET');
$request->url($url);

my $response = $ua->request($request);
my $urlContent;
if ($response->is_success) {
    $urlContent = $response->content;
} else {
    die "HTTP GET failed for URL $url\n";
}
#print "$urlContent";

use utf8;
use Text::Unidecode;

my $ordoDate;
my $ordoLine;
my @ordo = split /\n/, $urlContent;
foreach ( @ordo ) {

    s/\r//g;
    #$_ =~ s/([^[:ascii:]]+)/unidecode($1)/ge;

    if ($_ =~ /DTSTART/) {
        $ordoDate = $_;
        $ordoDate =~ s/^.+\:(\d{4})(\d{2})(\d{2})/$1-$2-$3/;
    }

    next if $_ !~ /SUMMARY:/;

    s/SUMMARY://;
    s/,\\n/|/g;
    s/ or //g;
    s/^The //g;
    s/\|The /\|/g;
    s/of the Lord/of our Lord/;
    s/of the Blessed Virgin Mary/of our Lady/;
    s/\, Joint Principal Patron of the Diocese//;
    s/ \(commemoration of (.+)\)/$1/;
    s/^Saint /St /;
    s/\|Saint /\|St /g;
    s/^Saints /Ss /;
    s/\|Saints /\|Ss /g;
    s/ of Saint / of St /g;
    s/ of Saints / of Ss /g;
    s/ the .aints / of Ss /g;
    s/^Blessed /Bl /;
    s/\|Blessed /\|Bl /g;
    s/\,* and (his|their) Companions/ \& Companions/g;
    s/\,* and Doctor of the Church/\, Doctor/g;
    s/ and Missionary/\, Missionary/g;
    s/Bishops and Missionaries/Bishops, Missionaries/g;
    s/priest/Priest/g;
    s/husband/Husband/g;
    s/(the)* first .artyr/Protomartyr/g;
    s/ and / \& /g;
    s/(17 Dec)ember(.*)/$1:O Sapientia$2/;
    s/(18 Dec)ember(.*)/$1:O Adonai$2/;
    s/(19 Dec)ember(.*)/$1:O Radix Jesse$2/;
    s/(20 Dec)ember(.*)/$1:O Clavis David$2/;
    s/(21 Dec)ember(.*)/$1:O Oriens$2/;
    s/(22 Dec)ember(.*)/$1:O Rex Gentium$2/;
    s/(23 Dec)ember(.*)/$1:O Emmanuel$2/;
    s/December/Dec/;
    s/January/Jan/;
    s/Christmas Day/Nativity of our Lord/;
    s/.*(St Stephen, Protomartyr).*/Christmas Octave:26 Dec\|$1/;
    s/.*(St John, Apostle, Evangelist).*/Christmas Octave:27\ Dec|$1/;
    s/.*(Holy Innocents, Martyrs).*/Christmas Octave:28 Dec\|$1/;
    s/.*(St Thomas Becket, Bishop, Martyr).*/Christmas Octave:29 Dec\|$1/;
    s/.*(St Sylvester I, Pope).*/Christmas Octave:31 Dec\|$1/;
    s/6th day within the .ctave of Christmas.*/Christmas Octave:30 Dec/;
    s/7th day within the .ctave of Christmas.*/Christmas Octave:31 Dec\|St Sylvester I, Pope/;
    s/.*(Mary, the Holy Mother of God).*/Christmas Octave:1 Jan ($1 & Circumcision of our Lord)/;
    s/Birthday/Nativity/;
    s/^(3 Jan).*/Christmastide:$1 (Most Holy Name of Jesus)/;
    s/^([245] Jan)/Christmastide:$1/;
    s/^The Holy Family/Christmas I:Sun (Holy Family)/;
    s/^(\d+ Jan)/Epiphanytide:$1/;
    s/of the (\d+).. week of /of week $1 of /;
    s/(\d+).. Sunday (of|in) /Sunday of week $1 $2 /;
    s/(Mon|Tue|Wed|Thu|Fri|Sat).*? of .eek (\d+) of (Advent|Christmas|Lent|Eastertide|Easter)/$3 $2:$1/;
    s/(Mon|Tue|Wed|Thu|Fri|Sat).*? of .eek (\d+) in Ordinary Time/Ordinary Time $2:$1/;
    s/Sunday of .eek (\d+) of (Advent|Christmas|Lent|Eastertide|Easter)/$2 $1:Sun/;
    s/Sunday of .eek (\d+) in Ordinary Time/Ordinary Time $1:Sun/;
    s/(Sun|Mon|Tue|Wed|Thu|Fri|Sat).*? in the .eek after Epiphany/Epiphanytide I:$1/;
    s/(Sun|Mon|Tue|Wed|Thu|Fri|Sat).*? after the Most Holy Trinity/Trinitytide I:$1/;
    s/(Sun|Mon|Tue|Wed|Thu|Fri|Sat).*? after the (.+?) Sunday after (Epiphany|Trinity)/$3tide $2:$1/;
    s/(.+?) Sunday after (Epiphany|Trinity)/$2tide $1:Sun/;
    s/^.*?Sunday.+?before Lent \((.+gesima)\)/$1 Sunday/;
    s/(Mon|Tues|Wed|Thu|Fri|Sat).* after Epiphany Sunday/Epiphany Octave:$1/;
    s/(Mon|Tue|Wed|Thu|Fri|Sat).* after (.+?gesima)/$2 $1/;
    s/((Mon|Tue|Sat).*?) of Holy Week/Holy $1/;
    s/Wed.* of Holy Week/Holy Wednesday (Spy Wednesday, Tenebrae)/;
    s/(Maundy Thursday)/$1 (Mass of the Lord's Supper)/;
    s/(Good Friday)/$1 (Mass of the Presanctified)/;
    s/.*Easter Sunday.*/EASTER SUNDAY (Resurrection of our Lord)/;
    s/.*Easter (Mon|Tue|Wed|Thu|Fri|Sat).*?day/Easter Octave:$1/;
    s/.*Divine Mercy.*/EASTER II (Divine Mercy)/;
    s/Eastertide 6:(Friday.*)/Ascensiontide I:$1/;
    s/Eastertide 6:(Saturday.*)/Ascensiontide I:$1/;
    s/Eastertide 7:(.+)/Ascensiontide I:$1/;
    s/Eastertide 7:(.+)/Ascensiontide I:$1/;
    s/^Pentecost$/PENTECOST SUNDAY/;
    s/.*(Whit-Sunday).*/PENTECOST SUNDAY ($1)/;
    s/.*(Tue|Wed|Fri|Sat).*?day after Pentecost/Pentecost Octave:$1/;
    s/.*(Mary, Mother of the Church)/Pentecost Octave:Mon ($1)/;
    s/.*(Our Lord Jesus Christ the Eternal High Priest)/Pentecost Octave:Thu ($1)/;
    s/ 1:(Sun|Mon|Tue|Wed|Thu|Fri|Sat)/ I:$1/;
    s/ 2:(Sun|Mon|Tue|Wed|Thu|Fri|Sat)/ II:$1/;
    s/ 3:(Sun|Mon|Tue|Wed|Thu|Fri|Sat)/ III:$1/;
    s/ 4:(Sun|Mon|Tue|Wed|Thu|Fri|Sat)/ IV:$1/;
    s/ 5:(Sun|Mon|Tue|Wed|Thu|Fri|Sat)/ V:$1/;
    s/ 6:(Sun|Mon|Tue|Wed|Thu|Fri|Sat)/ VI:$1/;
    s/ 7:(Sun|Mon|Tue|Wed|Thu|Fri|Sat)/ VII:$1/;
    s/ 8:(Sun|Mon|Tue|Wed|Thu|Fri|Sat)/ VIII:$1/;
    s/ 9:(Sun|Mon|Tue|Wed|Thu|Fri|Sat)/ IX:$1/;
    s/ 10:(Sun|Mon|Tue|Wed|Thu|Fri|Sat)/ X:$1/;
    s/ 11:(Sun|Mon|Tue|Wed|Thu|Fri|Sat)/ XI:$1/;
    s/ 12:(Sun|Mon|Tue|Wed|Thu|Fri|Sat)/ XII:$1/;
    s/ 13:(Sun|Mon|Tue|Wed|Thu|Fri|Sat)/ XIII:$1/;
    s/ 14:(Sun|Mon|Tue|Wed|Thu|Fri|Sat)/ XIV:$1/;
    s/ 15:(Sun|Mon|Tue|Wed|Thu|Fri|Sat)/ XV:$1/;
    s/ 16:(Sun|Mon|Tue|Wed|Thu|Fri|Sat)/ XVI:$1/;
    s/ 17:(Sun|Mon|Tue|Wed|Thu|Fri|Sat)/ XVII:$1/;
    s/ 18:(Sun|Mon|Tue|Wed|Thu|Fri|Sat)/ XVIII:$1/;
    s/ 19:(Sun|Mon|Tue|Wed|Thu|Fri|Sat)/ XIX:$1/;
    s/ 20:(Sun|Mon|Tue|Wed|Thu|Fri|Sat)/ XX:$1/;
    s/ 21:(Sun|Mon|Tue|Wed|Thu|Fri|Sat)/ XXI:$1/;
    s/ 22:(Sun|Mon|Tue|Wed|Thu|Fri|Sat)/ XXII:$1/;
    s/ 23:(Sun|Mon|Tue|Wed|Thu|Fri|Sat)/ XXIII:$1/;
    s/ 24:(Sun|Mon|Tue|Wed|Thu|Fri|Sat)/ XXIV:$1/;
    s/ 25:(Sun|Mon|Tue|Wed|Thu|Fri|Sat)/ XXV:$1/;
    s/ 26:(Sun|Mon|Tue|Wed|Thu|Fri|Sat)/ XXVI:$1/;
    s/ 27:(Sun|Mon|Tue|Wed|Thu|Fri|Sat)/ XXVII:$1/;
    s/ 28:(Sun|Mon|Tue|Wed|Thu|Fri|Sat)/ XXVIII:$1/;
    s/ 29:(Sun|Mon|Tue|Wed|Thu|Fri|Sat)/ XXIX:$1/;
    s/ 30:(Sun|Mon|Tue|Wed|Thu|Fri|Sat)/ XXX:$1/;
    s/ 31:(Sun|Mon|Tue|Wed|Thu|Fri|Sat)/ XXXI:$1/;
    s/ 32:(Sun|Mon|Tue|Wed|Thu|Fri|Sat)/ XXXII:$1/;
    s/ 33:(Sun|Mon|Tue|Wed|Thu|Fri|Sat)/ XXXIII:$1/;
    s/ 34:(Sun|Mon|Tue|Wed|Thu|Fri|Sat)/ XXXIV:$1/;
    s/ ([XVI]+)\:Sunday/ $1:Sun/;
    s/ ([XVI]+)\:Sun/ $1:Sun/;
    s/tide Second/tide II/;
    s/tide Third/tide III/;
    s/tide Fourth/tide IV/;
    s/tide Fifth/tide V/;
    s/tide Sixth/tide VI/;
    s/tide Seventh/tide VII/;
    s/tide Eighth/tide VIII/;
    s/tide Ninth/tide IX/;
    s/tide Tenth/tide X/;
    s/tide Eleventh/tide XI/;
    s/tide Twelfth/tide XII/;
    s/tide Thirteenth/tide XIII/;
    s/tide Fourteenth/tide XIV/;
    s/tide Fifteenth/tide XV/;
    s/tide Sixteenth/tide XVI/;
    s/tide Seventeenth/tide XVII/;
    s/tide Eighteenth/tide XVIII/;
    s/tide Nineteenth/tide XIX/;
    s/tide Twentieth/tide XX/;
    s/tide Twenty-.irst/tide XXI/;
    s/tide Twenty-.econd/tide XXII/;
    s/tide Twenty-.hird/tide XXIII/;
    s/tide Twenty-.ourth/tide XXIV/;
    s/tide Twenty-.ifth/tide XXV/;
    s/tide Twenty-.ixth/tide XXVI/;
    s/tide Twenty-.eventh/tide XXVII/;
    s/tide ([XVI]+)\:Sunday/ $1:Sun/;
    s/tide ([XVI]+)\:Sun/ $1:Sun/;
    s/(Advent III:Sun).*$/$1 (Gaudete)/;
    s/(Advent IV:Sun).*$/$1 (Rorate)/;
    s/(Lent IV:Sun).*$/$1 (Laetare & Mothering Sunday)/;
    if (m/Lent V:Sun/ && $rite eq "VOE") {
        s/.+/Lent V:Sun (Passion Sunday)/;
    }
    s/(Easter V:Sun).*$/$1 (Rogation)/;
    s/(Eastertide|Easter) 6:Friday/Friday after Ascension)/;
    s/(Eastertide|Easter) 6:Saturday/Saturday after Ascension/;
    s/(Eastertide|Easter) 6/Eastertide VI/;
    s/(Eastertide|Easter) 7/Ascensiontide II/;
    s/tide First/tide I/;
    s/(Most Holy Trinity)/Trinity Sunday ($1)/;
    s/(Most Holy Body .+?Christ)/Corpus Christi ($1)/;
    s/(Ordinary Time III:Sun).*$/$1 (Word of God)/;
    s/(.+):Sun/\U$1\E/;
    s/Ordinary Time/Ord Time/;
    s/(.+ Sunday)$/\U$1\E/;
    s/((Nativity of our Lord|Holy Family|Epiphany of our Lord|Baptism of our Lord|Ascension of our Lord|Trinity Sunday|Corpus Christi|Ss Peter . Paul, Apostles|Assumption of our Lady|Christ the King))/\U$1\E/;
    s/^(All Saints)$/\U$1\E/;

    #Until new Ordos reflect it:
    s/(St John Henry Newman, Priest)/$1, Doctor/;

    s/\|/\t/g;
    $ordoLine = join "\t", $ordoDate, $rite, $_;

    print "$ordoLine\n";
}
