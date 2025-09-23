package Bible;

=pod
=head1 Package: Bible.pm
=head1 Author: Fr Darryl Jordan OLW BSc MDiv
=head1 Date: 15 August 2025 (Solemnity of the Assumption of our Lady)
=cut

# CORE packages and features used
use strict;
use utf8;
use warnings;

use Carp;
use English;
use Exporter 'import';
our $VERSION = '1.00'; # set the version for version checking

use feature 'say';

# Ubuntu system packages used. See help/UbuntuPackagesRequired.txt
use Data::Printer; # allows use of p command to say a variable's value, e.g. p $spring; p %hash
use Mojo::DOM;
use Mojo::UserAgent;

# Bible class attributes
our $ErrMsg       = '';
our @TRANSLATIONS = qw(BG-DHH BG-DRA BG-ESV BG-ESVUK BG-GNB BG-MBBTAG-DC BG-NRSVA BG-NRSVCE BG-NRSVUE BG-RSV BG-RSVCE BG-SBLGNT BG-TLA BG-VULGATE BG-WYC NA-KNOX NA-LXX NA-VULGATE);

unless (defined $ENV{ROCKS_HOME}) {
    $ErrMsg = "$0: Processing failed; environment variable ROCKS_HOME is undefined.";
    exit 0;
}
# ROCKS packages used
use lib "$ENV{ROCKS_HOME}/lib";
use InitLogger;
our $Logger = Log::Any->get_logger(); # Should be declared first; Ubuntu package: liblog-any-adapter-dispatch-perl

# Bible class attributes set by Set_BooksAttributes
our %BooksAttributes     = ();
our @BooksAttributesKeys = ();
our @BooksNames          = ();
&Set_BooksAttributes();

# Bible class attributes set/get by invoked functions:
our %BookAttributes      = (); # (Set|Get)_BookAttributes
our $BookAttributeValue  = ''; # (Set|Get)_BookAttributeValue
our %BookChapter         = (); # (Set|Get)_BookChapter

# Bible class methods
our @ExportedFunctions   = qw(new
                              Set_BookChapter
                              Set_BookAttributes
                              Set_BookAttributeValue);
our @ExportedVariables   = ($ErrMsg);
our @EXPORT_OK           = (@ExportedFunctions, @ExportedVariables); # for Use Export

# Module subroutines/methods
sub new {
    my $class = shift;
    my $self = {};
    bless $self, $class;
    return $self;
}

sub Set_BookAttributes
{
    my $self = shift;
    my $subName = (caller(0))[3];
    $Logger->debug("Entering ${subName}");

#   Initialise and process parameters
    my (%args)   = @_;
    my $bookName = $args{BookName} || '';

    my $allowableValuesMsg = "allowable values: (" . join('|', @BooksNames) .')';
    if ($bookName eq '') {
        $ErrMsg = "${subName}: No BookName specified; ${allowableValuesMsg}.";
        $Logger->debug("Exiting ${subName}; failed: ${ErrMsg}");
        return 0;
    } else {
        unless (exists $BooksAttributes{$bookName}) {
            $ErrMsg = "${subName}: Got invalid BookName:'${bookName}'; ${allowableValuesMsg}.";
            $Logger->debug("Exiting ${subName}; failed: ${ErrMsg}");
            return 0;
        }
    }

    %BookAttributes = %{$BooksAttributes{$bookName}};

    $Logger->debug("Exiting ${subName}");
    return 1;
}

sub Set_BookAttributeValue
{
    my $self = shift;
    my $subName = (caller(0))[3];
    $Logger->debug("Entering ${subName}");

#   Initialise and process parameters
    my (%args)           = @_;
    my $bookAttributeKey = $args{BookAttributeKey} || '';
    my $bookName         = $args{BookName}         || '';

#   BookName parm required
    my $allowableValuesMsg = "allowable values: (" . join('|', @BooksNames) .')';
    if ($bookName eq '') {
        $ErrMsg = "${subName}: No BookName specified; ${allowableValuesMsg}.";
        $Logger->debug("Exiting ${subName}; failed: ${ErrMsg}");
        return 0;
    } else {
        unless (exists $BooksAttributes{$bookName}) {
            $ErrMsg = "${subName}: Got invalid BookName:'${bookName}'; ${allowableValuesMsg}.";
            $Logger->debug("Exiting ${subName}; failed: ${ErrMsg}");
            return 0;
        }
    }

#   BookAttributeKey parm required
    my @bookAttributesKeys = sort keys %{$BooksAttributes{$bookName}};
    $allowableValuesMsg = 'allowable values: (' . join('|', @{bookAttributesKeys}) . ')';
    if ($bookAttributeKey eq '') {
        $ErrMsg = "${subName}: No BookAttributeKey specified; ${allowableValuesMsg}.";
        $Logger->debug("Exiting ${subName}; failed: ${ErrMsg}");
        return 0;
    } else {
        unless (exists $BooksAttributes{$bookName}{$bookAttributeKey}) {
            $ErrMsg = "${subName}: Got invalid BookAttributeKey:'${bookAttributeKey}'; ${allowableValuesMsg}.";
            $Logger->debug("Exiting ${subName}; failed: ${ErrMsg}");
            return 0;
        }
    }

#   Set package attribute
    $BookAttributeValue = $BooksAttributes{$bookName}{$bookAttributeKey};

    $Logger->debug("Exiting ${subName}");
    return 1;
}

sub Set_BookChapter
{
    my $self = shift;
    my $subName = (caller(0))[3];
    $Logger->debug("Entering ${subName}");

#   Initialise and process parameters
    my (%args)      = @_;
    my $bookName    = $args{BookName}    || '';
    my $chapNum     = $args{ChapNum}     || '';
    my $translation = $args{Translation} || '';

#   Translation parm required
    my $allowableValuesMsg = "allowable values: (" . join('|', @TRANSLATIONS) .').';
    if ($translation eq '') {
        $ErrMsg = "${subName}: No Translation specified; ${allowableValuesMsg}.";
        $Logger->debug("Exiting ${subName}; failed: ${ErrMsg}");
        return 0;
    } else {
        unless (grep( /^$translation$/, @TRANSLATIONS)) {
            $ErrMsg = "${subName}: Got invalid Translation:'${translation}'; ${allowableValuesMsg}.";
            $Logger->debug("Exiting ${subName}; failed: ${ErrMsg}");
            return 0;
        }
    }

#   BookName parm required
    $allowableValuesMsg = "allowable values: (" . join('|', @BooksNames) .')';
    if ($bookName eq '') {
        $ErrMsg = "${subName}: No BookName specified; ${allowableValuesMsg}.";
        $Logger->debug("Exiting ${subName}; failed: ${ErrMsg}");
        return 0;
    } else {
        unless (exists $BooksAttributes{$bookName}) {
            $ErrMsg = "${subName}: Got invalid BookName:'${bookName}'; ${allowableValuesMsg}.";
            $Logger->debug("Exiting ${subName}; failed: ${ErrMsg}");
            return 0;
        }
    }

#   ChapNum parm required
    my $chapCount = $BooksAttributes{$bookName}{ChapCount};
    my $chapCountKey = 'ChapCount_' . $translation;
    $chapCount = $BooksAttributes{$bookName}{$chapCountKey} if (exists $BooksAttributes{$bookName}{$chapCountKey});
    $allowableValuesMsg = "allowable values: (1..${chapCount})";
    if ($chapNum eq '') {
        $ErrMsg = "${subName}: No ChapNum specified; ${allowableValuesMsg}.";
        $Logger->debug("Exiting ${subName}; failed: ${ErrMsg}");
        return 0;
    } else {
        unless (($chapNum > 0) && ($chapNum <= $chapCount)) {
            $ErrMsg = "${subName}: Got invalid ChapNum:'${chapNum}'; ${allowableValuesMsg}.";
            $Logger->debug("Exiting ${subName}; failed: ${ErrMsg}");
            return 0;
        }
    }

#   Create URL for fetch of chapter HTML

    my $website = '';
    my $url     = 'https://www.';
    if ($translation =~ /^BG-/) {
#       https://www.biblegateway.com/passage/?search=James\ 5\&version=RSVCE
#       https://www.biblegateway.com/passage/?search=1\ Peter\ 1\&version=RSVCE
#       https://www.biblegateway.com/passage/?search=ΚΑΤΑ ΜΑΤΘΑΙΟΝ 1&version=SBLGNT
#       For non-English versions, encritics chars are expanded to hex in link copies and browser address bar, e.g.:
#       https://www.biblegateway.com/passage/?search=%CE%9A%CE%91%CE%A4%CE%91%20%CE%9C%CE%91%CE%A4%CE%98%CE%91%CE%99%CE%9F%CE%9D%201&version=SBLGNT
#       https://www.biblegateway.com/passage/?search=G%C3%A9nesis%201&version=DHH
        $website = 'biblegateway.com';
        $url     .= $website;

        my $bookAttributesKey = "BookName_${translation}";
        my $bookNameToken     = '';
        if ($BooksAttributes{$bookName}{$bookAttributesKey} ne '') {
            $bookNameToken = $BooksAttributes{$bookName}{$bookAttributesKey} ;
        } else {
            $bookNameToken = $bookName;
        }
        $bookNameToken =~ s/ /\\ /;

        my $translationToken = $translation;
        $translationToken =~ s/^BG.//;

        $url .= '/passage/?search=' . $bookNameToken . '\ ' . $chapNum . '\&version=' . $translationToken;

    } elsif ($translation =~ /^NA./) {

#       https://www.newadvent.org/bible/gen001.htm
#       https://www.newadvent.org/bible/1pe001.htm
#       N.B. For NewAdvent, lynx only dumps LXX for some reason
        $website = 'newadvent.org';
        $url     .= $website;

        my $bookNameToken = lc($bookName);
        $bookNameToken =~ s/ //g;
        $bookNameToken =~ s/^(...).+$/$1/g;

        my $pad = 3;
        my $chapNumToken = sprintf ("%0${pad}d", $chapNum);
        $url .= '/bible/' . $bookNameToken . $chapNumToken . '.htm';
    } else {
        $ErrMsg = "${subName}: Could not infer website (BibleGateway.com|NewAdvent.org).";
        $Logger->debug("Exiting ${subName}; failed: ${ErrMsg}");
        return 0;
    }

#   Fetch URL as HTML
#   cf. https://metacpan.org/pod/Mojo::UserAgent
    my $ua = Mojo::UserAgent->new;

    my $dom = $ua->get( $url )
        ->res
        ->dom;

#   Chapter content is in this <div> element:
    $DB::single = 1;
    if ($website eq 'biblegateway.com') {
# Example for 1 Peter 5 (ESVUK): https://www.biblegateway.com/passage/?search=1%20Peter%205&version=ESVUK
# <div class="passage-text">
#     <div class="passage-content passage-class-0">
#         <div class="version-ESVUK result-text-style-normal text-html">
#             <h3><span id="en-ESVUK-30450" class="text 1Pet-5-1">Shepherd the Flock of God</span></h3>
#             <p class="chapter-1">
#                 <span class="text 1Pet-5-1">
#                     <span class="chapternum">5&nbsp;</span>
#                     So I exhort the elders among you, <sup class="crossreference" data-cr="#cen-ESVUK-30450A" data-link="(<a href=&quot;#cen-ESVUK-30450A&quot; title=&quot;See cross-reference A&quot;>A</a>)">(<a href="#cen-ESVUK-30450A" title="See cross-reference A">A</a>)</sup>as a fellow elder and <sup $class="crossreference" data-cr="#cen-ESVUK-30450B" data-link="(<a href=&quot;#cen-ESVUK-30450B&quot; title=&quot;See cross-reference B&quot;>B</a>)">(<a href="#cen-ESVUK-30450B" title="See cross-reference B">B</a>)</sup>a witness of the sufferings of Christ, as well as a partaker in the glory that is going to be revealed:
#                 </span>
#             </p>
#         </div>
#     </div>
# </div>
#
# https://stackoverflow.com/questions/34719421/how-to-print-the-text-in-a-paragraph-element-using-mojolicious
        my $div = $dom->find('div[class="passage-text"]');
    } else {
# Example for Matthew 5 (ESVUK): https://www.newadvent.org/bible/mat001.htm
# <table class="bibletable"><tbody><tr>
#     <tbody>
#         <tr>
#             <td class="bibletd1">
#                 <span class="verse">1</span>
#                 <span class="bible-greek">Βίβλος γενέσεως Ἰησοῦ Χριστοῦ υἱοῦ Δαυὶδ υἱοῦ Ἀβραάμ.</span>
#                 <span class="verse">2</span>
#             </td>
#             <td class="bibletd2">
#                 <span class="verse">1</span>&nbsp;
#                 A record of the ancestry from which Jesus Christ, the son of David, son of Abraham, was born.
#                 <span class="verse">2</span>&nbsp
#             </td>
#             <td class="bibletd3">
#                 <span class="verse">1</span>
#                 <span class="bible-latin">Liber generationis Jesu Christi filii David, filii Abraham.</span>
#                 <span class="verse">2</span>
#             </td>
#         </tr>
#     </tbody>
# </table>
        my $table = $dom->find('table[class="bibletable"]');
    }

#   Populate BookChapter package attribute
    %BookChapter = ();
    my $chapterHashKey            = '';
    my $chapterHashValue          = '';
    $BookChapter{$chapterHashKey} = '';

    $Logger->debug("Exiting ${subName}");
    return 1;
}

sub Set_BooksAttributes
{
    my $self = shift;
    my $subName = (caller(0))[3];
    $Logger->debug("Entering ${subName}");

    # Initialise package attribute
    %BooksAttributes = ();

#   Process parameters
    my $booksAttributesFH;
    my $booksAttributesFP = "$ENV{ROCKS_BIBLIAE}/BooksAttributes.tsv";
    if (-e $booksAttributesFP) {
        unless (open ($booksAttributesFH, "<", $booksAttributesFP)) {
            $ErrMsg = "$subName: Couldn't open file ${booksAttributesFP}.";
            $Logger->debug("Exiting ${subName}; failed: ${ErrMsg}.");
            return 0;
        }
    } else {
        $ErrMsg = "$subName: BooksAttributes file $booksAttributesFP does not exist.";
        $Logger->debug("Exiting ${subName}; failed: ${ErrMsg}.");
        return 0;
    }

    my @booksAttributesLines = <$booksAttributesFH>;
    close $booksAttributesFH;

#   Read the first line of the file, the header, as keys for hash:
    my $headerLine = shift @booksAttributesLines;
    chomp $headerLine;
    my @booksAttributesKeys = split /\t/, $headerLine;

#   Skip BookName in header as this is the primary key of BooksAttributes hash, not a book attribute
    shift @booksAttributesKeys;

#   Sort as package attribute
    @BooksAttributesKeys = sort @booksAttributesKeys;

#   Initialise lexical variables
    my $bookAttributeKey   = '';
    my $bookAttributeValue = '';
    my @bookAttributes     = ();
    my $bookName           = '';

#   Populate package attribute
    foreach (@booksAttributesLines)
    {
        @bookAttributes = split /\t/, $_;
        $bookName = shift @bookAttributes;
        foreach (0..$#bookAttributes-1) {
            $bookAttributeKey   = $booksAttributesKeys[$_];
            $bookAttributeValue = $bookAttributes[$_];
            $BooksAttributes{$bookName}{$bookAttributeKey} = $bookAttributeValue;
        }
    }

#   Sort as package attribute
    @BooksNames = sort keys %BooksAttributes;

    $Logger->debug("Exiting ${subName}");
    return 1;
}
END {}
__PACKAGE__;
