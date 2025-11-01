#!/bin/env perl

# Perl CORE and system packages used
use strict;
use utf8;
use warnings;

use English;

use feature 'say';

die "Usage: $0 OrdoDate (YYYY-MM-DD) OrdoDOW (Sun|...|Sat) Rite (NOE|VOE) PropersID\n" if @ARGV < 3;

my $ordoDate = shift;
my $ordoDOW = shift;
my $rite = shift;
my $propersID = shift;

# First part of VCS event

$propersID =~ s/SUMMARY://;

# PropersIDs separator for choices of the day replaced with pipe ('|')

$propersID =~ s/\,\\n or /\|/g;
$propersID =~ s/\,\\n/\|/g;
#$propersID =~ s/ or //g;

# Detox temporale

# General text cleanup

# Remove cardinality suffix (nd|rd|st|th)

$propersID =~ s/of the (\d+).. week of /of week $1 of /;
$propersID =~ s/(\d+).. Sunday (of|in) /Sunday of week $1 $2 /;

# Detox day-of-week references
#
$propersID =~ s/(Mon|Tue|Wed|Thu|Fri|Sat).+? of .eek (\d+) of (Advent|Christmas|Lent|Eastertide|Easter)/$3 $2:$1/;
$propersID =~ s/Sunday of .eek (\d+) of (Advent|Christmas|Lent|Eastertide|Easter)/$2 $1:Sun/;
$propersID =~ s/(Mon|Tue|Wed|Thu|Fri|Sat).+? after Epiphany Sunday/Epiphany Octave:$1/;
$propersID =~ s/(Mon|Tue|Wed|Thu|Fri|Sat).+? in the .eek after Epiphany/Epiphanytide I:$1/;
$propersID =~ s/(Mon|Tue|Wed|Thu|Fri|Sat).+? after the (.+?) Sunday after (Epiphany|Trinity)/$3tide $2:$1/;
$propersID =~ s/(.+?) Sunday after (Epiphany|Trinity)/$2 $1:Sun/;
$propersID =~ s/(Mon|Tue|Wed|Thu|Fri|Sat).+? of .eek (\d+) in Ordinary Time/Ord Time $2:$1/;
$propersID =~ s/Sunday of .eek (\d+) in Ordinary Time/Ordinary Time $1:Sun/;
$propersID =~ s/^.*?Sunday.+?before Lent \((.+gesima)\)/$1:Sun/;
$propersID =~ s/(Mon|Tue|Wed|Thu|Fri|Sat).+? after (.+?gesima)/$2:$1/;
$propersID =~ s/(Mon|Tue|Wed|Sat).+? of Holy Week/Holy Week:$1/;
$propersID =~ s/(Mon|Tue|Wed|Thu|Fri|Sat).+? after the Most Holy Trinity/Trinity Octave:$1/;
$propersID =~ s/(Mon|Tue|Wed|Thu|Fri|Sat).+? after Trinity/Trinity:$1/;

# Do ordinal conversions; required format is Roman numerals

$propersID =~ s/ 1:(Sun|Mon|Tue|Wed|Thu|Fri|Sat)/ I:$1/;
$propersID =~ s/ 2:(Sun|Mon|Tue|Wed|Thu|Fri|Sat)/ II:$1/;
$propersID =~ s/ 3:(Sun|Mon|Tue|Wed|Thu|Fri|Sat)/ III:$1/;
$propersID =~ s/ 4:(Sun|Mon|Tue|Wed|Thu|Fri|Sat)/ IV:$1/;
$propersID =~ s/ 5:(Sun|Mon|Tue|Wed|Thu|Fri|Sat)/ V:$1/;
$propersID =~ s/ 6:(Sun|Mon|Tue|Wed|Thu|Fri|Sat)/ VI:$1/;
$propersID =~ s/ 7:(Sun|Mon|Tue|Wed|Thu|Fri|Sat)/ VII:$1/;
$propersID =~ s/ 8:(Sun|Mon|Tue|Wed|Thu|Fri|Sat)/ VIII:$1/;
$propersID =~ s/ 9:(Sun|Mon|Tue|Wed|Thu|Fri|Sat)/ IX:$1/;
$propersID =~ s/ 10:(Sun|Mon|Tue|Wed|Thu|Fri|Sat)/ X:$1/;
$propersID =~ s/ 11:(Sun|Mon|Tue|Wed|Thu|Fri|Sat)/ XI:$1/;
$propersID =~ s/ 12:(Sun|Mon|Tue|Wed|Thu|Fri|Sat)/ XII:$1/;
$propersID =~ s/ 13:(Sun|Mon|Tue|Wed|Thu|Fri|Sat)/ XIII:$1/;
$propersID =~ s/ 14:(Sun|Mon|Tue|Wed|Thu|Fri|Sat)/ XIV:$1/;
$propersID =~ s/ 15:(Sun|Mon|Tue|Wed|Thu|Fri|Sat)/ XV:$1/;
$propersID =~ s/ 16:(Sun|Mon|Tue|Wed|Thu|Fri|Sat)/ XVI:$1/;
$propersID =~ s/ 17:(Sun|Mon|Tue|Wed|Thu|Fri|Sat)/ XVII:$1/;
$propersID =~ s/ 18:(Sun|Mon|Tue|Wed|Thu|Fri|Sat)/ XVIII:$1/;
$propersID =~ s/ 19:(Sun|Mon|Tue|Wed|Thu|Fri|Sat)/ XIX:$1/;
$propersID =~ s/ 20:(Sun|Mon|Tue|Wed|Thu|Fri|Sat)/ XX:$1/;
$propersID =~ s/ 21:(Sun|Mon|Tue|Wed|Thu|Fri|Sat)/ XXI:$1/;
$propersID =~ s/ 22:(Sun|Mon|Tue|Wed|Thu|Fri|Sat)/ XXII:$1/;
$propersID =~ s/ 23:(Sun|Mon|Tue|Wed|Thu|Fri|Sat)/ XXIII:$1/;
$propersID =~ s/ 24:(Sun|Mon|Tue|Wed|Thu|Fri|Sat)/ XXIV:$1/;
$propersID =~ s/ 25:(Sun|Mon|Tue|Wed|Thu|Fri|Sat)/ XXV:$1/;
$propersID =~ s/ 26:(Sun|Mon|Tue|Wed|Thu|Fri|Sat)/ XXVI:$1/;
$propersID =~ s/ 27:(Sun|Mon|Tue|Wed|Thu|Fri|Sat)/ XXVII:$1/;
$propersID =~ s/ 28:(Sun|Mon|Tue|Wed|Thu|Fri|Sat)/ XXVIII:$1/;
$propersID =~ s/ 29:(Sun|Mon|Tue|Wed|Thu|Fri|Sat)/ XXIX:$1/;
$propersID =~ s/ 30:(Sun|Mon|Tue|Wed|Thu|Fri|Sat)/ XXX:$1/;
$propersID =~ s/ 31:(Sun|Mon|Tue|Wed|Thu|Fri|Sat)/ XXXI:$1/;
$propersID =~ s/ 32:(Sun|Mon|Tue|Wed|Thu|Fri|Sat)/ XXXII:$1/;
$propersID =~ s/ 33:(Sun|Mon|Tue|Wed|Thu|Fri|Sat)/ XXXIII:$1/;
$propersID =~ s/ 34:(Sun|Mon|Tue|Wed|Thu|Fri|Sat)/ XXXIV:$1/;

$propersID =~ s/(Epiphanytide|Epiphany|Trinitytide|Trinity) First/$1 I/;
$propersID =~ s/(Epiphanytide|Epiphany|Trinitytide|Trinity) Second/$1 II/;
$propersID =~ s/(Epiphanytide|Epiphany|Trinitytide|Trinity) Third/$1 III/;
$propersID =~ s/(Epiphanytide|Epiphany|Trinitytide|Trinity) Fourth/$1 IV/;
$propersID =~ s/(Epiphanytide|Epiphany|Trinitytide|Trinity) Fifth/$1 V/;
$propersID =~ s/(Epiphanytide|Epiphany|Trinitytide|Trinity) Sixth/$1 VI/;
$propersID =~ s/(Epiphanytide|Epiphany|Trinitytide|Trinity) Seventh/$1 VII/;
$propersID =~ s/(Epiphanytide|Epiphany|Trinitytide|Trinity) Eighth/$1 VIII/;
$propersID =~ s/(Epiphanytide|Epiphany|Trinitytide|Trinity) Ninth/$1 IX/;
$propersID =~ s/(Epiphanytide|Epiphany|Trinitytide|Trinity) Tenth/$1 X/;
$propersID =~ s/(Epiphanytide|Epiphany|Trinitytide|Trinity) Eleventh/$1 XI/;
$propersID =~ s/(Epiphanytide|Epiphany|Trinitytide|Trinity) Twelfth/$1 XII/;
$propersID =~ s/(Epiphanytide|Epiphany|Trinitytide|Trinity) Thirteenth/$1 XIII/;
$propersID =~ s/(Epiphanytide|Epiphany|Trinitytide|Trinity) Fourteenth/$1 XIV/;
$propersID =~ s/(Epiphanytide|Epiphany|Trinitytide|Trinity) Fifteenth/$1 XV/;
$propersID =~ s/(Epiphanytide|Epiphany|Trinitytide|Trinity) Sixteenth/$1 XVI/;
$propersID =~ s/(Epiphanytide|Epiphany|Trinitytide|Trinity) Seventeenth/$1 XVII/;
$propersID =~ s/(Epiphanytide|Epiphany|Trinitytide|Trinity) Eighteenth/$1 XVIII/;
$propersID =~ s/(Epiphanytide|Epiphany|Trinitytide|Trinity) Nineteenth/$1 XIX/;
$propersID =~ s/(Epiphanytide|Epiphany|Trinitytide|Trinity) Twentieth/$1 XX/;
$propersID =~ s/(Epiphanytide|Epiphany|Trinitytide|Trinity) Twenty-.irst/$1 XXI/;
$propersID =~ s/(Epiphanytide|Epiphany|Trinitytide|Trinity) Twenty-.econd/$1 XXII/;
$propersID =~ s/(Epiphanytide|Epiphany|Trinitytide|Trinity) Twenty-.hird/$1 XXIII/;
$propersID =~ s/(Epiphanytide|Epiphany|Trinitytide|Trinity) Twenty-.ourth/$1 XXIV/;
$propersID =~ s/(Epiphanytide|Epiphany|Trinitytide|Trinity) Twenty-.ifth/$1 XXV/;
$propersID =~ s/(Epiphanytide|Epiphany|Trinitytide|Trinity) Twenty-.ixth/$1 XXVI/;
$propersID =~ s/(Epiphanytide|Epiphany|Trinitytide|Trinity) Twenty-.eventh/$1 XXVII/;

# Month names are abbreviated

$propersID =~ s/December/Dec/;
$propersID =~ s/January/Jan/;

# Sundays (only) are not named 'tide'

$propersID =~ s/tide ([XVI]+)\:Sunday/ $1:Sun/;
$propersID =~ s/tide ([XVI]+)\:Sun/ $1:Sun/;
$propersID =~ s/ ([XVI]+)\:Sunday/ $1:Sun/;
$propersID =~ s/ ([XVI]+)\:Sun/ $1:Sun/;

# Detox specific temporale days

$propersID =~ s/(Advent III:Sun).*$/$1/; # (Gaudete)
$propersID =~ s/(Advent IV:Sun).*$/$1/; # (Rorate)
$propersID =~ s/(17 Dec)(.*)/$1:O Sapientia$2/;
$propersID =~ s/(18 Dec)(.*)/$1:O Adonai$2/;
$propersID =~ s/(19 Dec)(.*)/$1:O Radix Jesse$2/;
$propersID =~ s/(20 Dec)(.*)/$1:O Clavis David$2/;
$propersID =~ s/(21 Dec)(.*)/$1:O Oriens$2/;
$propersID =~ s/(22 Dec)(.*)/$1:O Rex Gentium$2/;
$propersID =~ s/(23 Dec)(.*)/$1:O Emmanuel$2/;
$propersID =~ s/^6 Jan \(.efore Epiphany\)/6 Jan/;
$propersID =~ s/(Epiphany III:Sun).*$/$1/; # (Word of God)
$propersID =~ s/(Lent IV:Sun).*$/$1/; # (Laetare) also Mothering Sunday
$propersID =~ s/(Lent V:Sun).*$/$1/; # (Passion Sunday)
if ($rite eq 'VOE' && $propersID =~ m/Lent V:Sun/) {
    $propersID =~ s/.+/Passion Sunday/;
}
$propersID =~ s/Maundy Thursday.*/Mass of the Lord's Supper/;
$propersID =~ s/Good Friday.*/Mass of the Presanctified/;
$propersID =~ s/.*Easter Sunday.*/Resurrection of the Lord/;
$propersID =~ s/.*Easter (Mon|Tue|Wed|Thu|Fri|Sat).*?day/Easter Octave:$1/;
$propersID =~ s/.*Divine Mercy.*/Easter II:Sun/;
$propersID =~ s/(Easter.+ V:Sun).*$/$1/; # (Rogation)
$propersID =~ s/(Eastertide|Easter) VI:(Fri|Sat).+/Ascensiontide I:$2/;
$propersID =~ s/(Eastertide|Easter) VII:(Mon|Tue|Wed|Thu|Fri|Sat).+/Ascensiontide II:$2/;
$propersID =~ s/^Pentecost$/Pentecost Sunday/;
$propersID =~ s/.*(Whit-Sunday).*/Pentecost Sunday/;
$propersID =~ s/.*(Tue|Wed|Fri|Sat).*?day after Pentecost/Pentecost Octave:$1/;
$propersID =~ s/.*(Mary, Mother of the Church)/Pentecost Octave:Mon/; # Remove parenthetical aliases (showing them handled in Lookup_PropersID_English-Alias.tsv)
$propersID =~ s/.*(Our Lord Jesus Christ the Eternal High Priest)/Pentecost Octave:Thu/; # Remove parenthetical aliases (showing them handled in Lookup_PropersID_English-Alias.tsv)
$propersID =~ s/(Most Holy Trinity)/Trinity Sunday/; # (Most Holy Trinity)
$propersID =~ s/(Most Holy Body .+?Christ)/Corpus Christi/; # (Most Holy Body and Blood of Christ)
$propersID =~ s/(Ordinary Time III:Sun).*$/$1/; # (Word of God)

# Detox sanctorale

# General cleanup

# Required PropersID format:
#   no leading definite articles, e.g., The Nativity/Resurrection/Assumption
#   'and' is abbreviated

$propersID =~ s/^The //g;
$propersID =~ s/\|The /\|/g;
$propersID =~ s/ and / \& /g;

$propersID =~ s/^Blessed /Bl /;
$propersID =~ s/\|Blessed /\|Bl /g;
$propersID =~ s/Birthday/Nativity/;
$propersID =~ s/Bishop & Missionary/Bishop, Missionary/g;
$propersID =~ s/Bishops and Missionaries/Bishops, Missionaries/g;
$propersID =~ s/ \(commemoration of (.+)\)/$1/;
$propersID =~ s/(\,*) Doctor of the Church/$1 Doctor/g;
$propersID =~ s/hermit/Hermit/g;
$propersID =~ s/(his|their) Companions/Companions/g;
$propersID =~ s/husband/Husband/g;
$propersID =~ s/\, Joint Principal Patron of the Diocese//;
$propersID =~ s/monk/Monk/g;
$propersID =~ s/of the Blessed Virgin Mary/of our Lady/;
$propersID =~ s/parents/Parents/g;
$propersID =~ s/priest/Priest/g;
$propersID =~ s/^Saint /St /;
$propersID =~ s/\|Saint /\|St /g;
$propersID =~ s/^Saints /Ss /;
$propersID =~ s/\|Saints /\|Ss /g;
$propersID =~ s/ of Saint / of St /g;
$propersID =~ s/ of Saints / of Ss /g;
$propersID =~ s/ the .aints / of Ss /g;
$propersID =~ s/.pouse of our Lady/Husband of our Lady/g;

# Specific days

$propersID =~ s/Christmas Day/Nativity of the Lord/;
$propersID =~ s/(the)* first .artyr/Proto-Martyr/g;
$propersID =~ s/.*(St Stephen, Proto-Martyr).*/26 Dec:Christmas Octave II\|$1/;
$propersID =~ s/.*(St John, Apostle, Evangelist).*/27 Dec:Christmas Octave III\|$1/;
$propersID =~ s/.*(Holy Innocents, Martyrs).*/28 Dec:Christmas Octave IV\|$1/;
$propersID =~ s/.*(St Thomas Becket, Bishop, Martyr).*/29 Dec:Christmas Octave V\|$1/;
$propersID =~ s/6th day within the .ctave of Christmas.*/30 Dec:Christmas Octave VI/;
$propersID =~ s/\|?St Sylvester I, Pope//;
$propersID =~ s/7th day within the .ctave of Christmas.*/31 Dec:Christmas Octave VII\|St Sylvester I, Pope/;
$propersID =~ s/.*(Mary, the Holy Mother of God).*/Mary, Mother of God/;
$propersID =~ s/^3 Jan.*/3 Jan:Most Holy Name of Jesus/;

# Normalise names

$propersID =~ s/Antony/Anthony/g;
$propersID =~ s/Ephraem/Ephrem/g;
$propersID =~ s/Kęty/Kanty/g;
$propersID =~ s/of Calasanz/Calasanz/g; # Most common is place as surname
$propersID =~ s/Lawrence/Laurence/g;
$propersID =~ s/Thérèse/Teresa/g;

$propersID =~ s/Dedication of the Lateran Basilica/Dedication of the Archbasilica of St John Lateran/;

$propersID =~ s/Bl Dominic of the Mother of God.+?Priest/Bl Dominic of the Mother of God, Priest/;

$propersID =~ s/S. Christopher Magallanes.+Martyrs/Ss Christopher Magallanes, Priest, & Companions, Martyrs/;
$propersID =~ s/Ss Cyril, Monk, & Methodius, Bishop/Ss Cyril, Monk, & Methodius, Bishop, Europe Co-Patrons/;
$propersID =~ s/Ss Chad.+Missionaries/Ss Chad & Cedd, Bishops, Missionaries/;
$propersID =~ s/Ss Denis, Bishop, & Companions, Martyrs/Ss Denis, France Co-Patron, Bishop, & Companions, Martyrs/;
$propersID =~ s/Ss John de Brébeuf.+Martyrs/Ss John de Brébeuf & Isaac Jogues, Priests, & Companions, Martyrs/;
$propersID =~ s/Ss Philip & James, Apostles/Ss Philip & James the Less, Apostles/;

$propersID =~ s/St Aidan.+?Lindisfarne/St Aidan of Lindisfarne, Bishop, Missionary/;
$propersID =~ s/St Alban,Proto-Martyr of England/St Alban, Britain Proto-Martyr/;
$propersID =~ s/St Alphonsus Mary de' Liguori, Bishop, Doctor/St Alphonsus Liguori, Bishop, Doctor/;
$propersID =~ s/St Andrew, Apostle/St Andrew, Scotland Patron, Apostle/;
$propersID =~ s/St Ansgar.+?Bishop/St Ansgar, Bishop/;
$propersID =~ s/St Augustine, Bishop, Doctor/St Augustine of Hippo, Bishop, Doctor/;
$propersID =~ s/St Augustine Zhao/Ss Augustine Zhao/;
$propersID =~ s/St Anthony, Abbot/St Anthony the Great, Abbot/;
$propersID =~ s/St Benedict.+?Europe/St Benedict of Nursia, Europe Patron, Founder, Abbot/;
$propersID =~ s/St Benet .+Abbot/St Benet Biscop, Abbot/;
$propersID =~ s/St Bernard, Abbot, Doctor/St Bernard of Clairvaux, Abbot, Doctor/;
$propersID =~ s/St Bridget of Sweden.+Europe/St Bridget of Sweden, Europe Co-Patron/;
$propersID =~ s/St Brigid, Virgin/St Brigid of Kildare, Ireland Co-Patron, Virgin/;
$propersID =~ s/St Casimir/St Casimir, Confessor/;
$propersID =~ s/St Catherine of Siena, Virgin, Doctor/St Catherine of Siena, Europe Co-Patron, Virgin, Doctor/;
$propersID =~ s/St Columba .+?Abbot/St Columba of Iona, Abbot/;
$propersID =~ s/St Columban.+?Missionary/St Columbanus, Abbot, Missionary/;
$propersID =~ s/St David.+?Bishop/St David, Wales Patron, Bishop/;
$propersID =~ s/St Dominic, Priest/St Dominic, Natural Science Patron, Founder, Priest/;
$propersID =~ s/St Elizabeth.+?Portugal/St Elizabeth of Portugal, Queen, Widow/;
$propersID =~ s/St Ephrem.+?Doctor/St Ephrem of Edessa, Deacon, Doctor/;
$propersID =~ s/St Etheldreda.+?Abbess/St Etheldreda, Abbess/;
$propersID =~ s/St Francis of Assisi/St Francis of Assisi, Ecology Patron, Founder, Confessor/;
$propersID =~ s/St George, Martyr/St George, England Patron, Martyr/;
$propersID =~ s/St Henry/St Henry of Bavaria, Holy Roman Emperor/;
$propersID =~ s/St Hilary, Bishop, Doctor/St Hilary of Poitiers, Bishop, Doctor/;
$propersID =~ s/St Ignatius.*?Loyola, Priest/St Ignatius of Loyola, Founder, Priest/;
$propersID =~ s/St Irenaeus, Bishop, Doctor, Martyr/St Irenaeus of Lyons, Bishop, Doctor, Martyr/;
$propersID =~ s/St Isidore, Bishop, Doctor/St Isidore of Seville, Bishop, Doctor/;
$propersID =~ s/St James.*?Apostle/St James the Great, Spain Patron, Apostle/;
$propersID =~ s/St Jerome Emilian\|/St Jerome Emiliani, Orphans Patron, Founder\|/;
$propersID =~ s/St John .+?Latinam\)/St John Before the Latin Gate/;
$propersID =~ s/St John Baptist de la Salle, Priest/St John Baptist de La Salle, Catholic Education Co-Patron, Priest, Religious, Founder, Confessor/;
if ($ordoDOW ne 'Sun' && $propersID !~ m/Ascension of the Lord/ && $ordoDate =~ m/05-15/) {
    $propersID =~ s/^(.*)$/St John Baptist de La Salle, Catholic Education Co-Patron, Priest, Religious, Founder, Confessor\|$1/;
}
$propersID =~ s/St John Bosco, Priest/St John Bosco, Youth Patron, Priest/;
$propersID =~ s/St John Henry Newman.+Doctor/St John Henry Newman, Catholic Education Co-Patron, Priest, Doctor/;
$propersID =~ s/St Kentigern.+?Bishop/St Kentigern, Bishop/;
$propersID =~ s/St Louis/St Louis of France, King\|/;
$propersID =~ s/St Louis.+Montfort.+?Priest/St Louis Grignion de Montfort, Priest/;
$propersID =~ s/St Mary Magdalen/St Mary Magdalene/;
$propersID =~ s/Magdalenee/Magdalene/; # MUST BE AFTER St Mary Magdalene; some Ordo references omit the closing 'e'
$propersID =~ s/St Margaret of Scotland/St Margaret of Scotland, Queen/;
$propersID =~ s/St Nicholas, Bishop/St Nicholas of Myra, Bishop/;
$propersID =~ s/St Norbert, Bishop/St Norbert, Founder, Bishop/;
$propersID =~ s/St Patrick, Bishop, Missionary/St Patrick, Ireland Patron, Bishop, Missionary/;
$propersID =~ s/St Peter Claver/St Peter Claver, Priest/;
$propersID =~ s/St Peter\'s Chair/Chair of St Peter, Apostle/;
$propersID =~ s/St Philip Neri, Priest/St Philip Neri, Founder, Priest/;
$propersID =~ s/St Pius of Pietrelcina.+?Priest/St Pius of Pietrelcina, Priest/;
$propersID =~ s/St Rita of Cascia/St Rita of Cascia, Religious/;
$propersID =~ s/St Robert Bellarmine, Bishop, Doctor/St Robert Bellarmine, Down Syndrome Patron, Bishop, Doctor/;
$propersID =~ s/St Stephen of Hungary/St Stephen of Hungary, King/;
$propersID =~ s/St Teresa Benedicta.+Martyr/St Teresa Benedicta of the Cross, Virgin, Martyr/;
$propersID =~ s/St Thomas Aquinas, Priest, Doctor/St Thomas Aquinas, Catholic Education Patron, Priest, Doctor/;
$propersID =~ s/St Teresa of Calcutta \(Mother Teresa\)/St Teresa of Calcutta, Virgin/;
$propersID =~ s/St Teresa of the Child Jesus, Virgin, Doctor/St Teresa of Lisieux, Virgin, Doctor/;
$propersID =~ s/St Turibius of Mongrovejo, Bishop/St Turibius of Mogrovejo, Bishop/;

# Sometimes duplicated depending on whether these titles are in the source Ordo for a feast

$propersID =~ s/Bishop, Bishop/Bishop/;
$propersID =~ s/Bishops, Bishops/Bishops/;
$propersID =~ s/Confessor, Confessor/Confessor/;
$propersID =~ s/Doctor, Doctor/Doctor/;
$propersID =~ s/King, King/King/;
$propersID =~ s/Martyr, Martyr/Martyr/;
$propersID =~ s/Martyrs, Martyrs/Martyrs/;
$propersID =~ s/Priest, Priest/Priest/;
$propersID =~ s/Queen, Queen/Queen/;
$propersID =~ s/Religious, Religious/Religious/;
$propersID =~ s/Virgin, Virgin/Virgin/;

# Capitalise all Sundays and Holydays of Obligation

$propersID =~ s/(.+):Sun/\U$1\E/;
$propersID =~ s/(.+ Sunday)$/\U$1\E/;
$propersID =~ s/^((Nativity of the Lord|Holy Family|Epiphany of the Lord|Baptism of the Lord|Resurrection of the Lord|Ascension of the Lord|Corpus Christi|Ss Peter . Paul, Apostles|Assumption of our Lady|All Saints|Christ the King))$/\U$1\E/;

chomp $propersID;

say $propersID;

exit 1;
__END__;
