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

# Ubuntu system packages used
use DDP; #alias for Data::Printer; Ubuntu package: libdata-printer-perl; allows use of p command to say a variable's value, e.g. p $spring; p %hash

# Bible class attributes
our $ErrMsg       = '';
our @TRANSLATIONS = qw(CEB CEI DHH DRA ESV ESVUK GNB MBBTAG-DC NRSVA NRSVCE NRSVUE RSV RSVCE TLA VULGATE WYC);

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
    my (%args) = @_;
    my $bookName = $args{BookName} || '';

    my $allowableValuesMsg = "allowable values: (" . join('|', @BooksNames) .')';
    if ($bookName eq '') {
        $ErrMsg = "${subName}: No BookName specified; ${allowableValuesMsg}.";
        $Logger->debug("Exiting ${subName}; failed: ${ErrMsg}");
        return 0;
    } else {
        unless (grep( /^$bookName$/, @BooksNames)) {
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
    my (%args) = @_;
    my $bookAttributeKey = $args{BookAttributeKey} || '';
    my $bookName         = $args{BookName}         || '';

#   BookName parm required
    my $allowableValuesMsg = "allowable values: (" . join('|', @BooksNames) .')';
    if ($bookName eq '') {
        $ErrMsg = "${subName}: No BookName specified; ${allowableValuesMsg}.";
        $Logger->debug("Exiting ${subName}; failed: ${ErrMsg}");
        return 0;
    } else {
        unless (grep( /^$bookName$/, @BooksNames)) {
            $ErrMsg = "${subName}: Got invalid BookName:'${bookName}'; ${allowableValuesMsg}.";
            $Logger->debug("Exiting ${subName}; failed: ${ErrMsg}");
            return 0;
        }
    }

#   BookAttributeKey parm required
    &Bible::Set_BookAttributes($self,
                               BookName => $bookName);
    my @bookAttributesKeys = sort keys %BookAttributes;
    $allowableValuesMsg = 'allowable values: (' . join('|', @{bookAttributesKeys}) . ')';
    if ($bookAttributeKey eq '') {
        $ErrMsg = "${subName}: No BookAttributeKey specified; ${allowableValuesMsg}.";
        $Logger->debug("Exiting ${subName}; failed: ${ErrMsg}");
        return 0;
    } else {
        unless (grep( /^$bookAttributeKey$/, @bookAttributesKeys)) {
            $ErrMsg = "${subName}: Got invalid BookAttributeKey:'${bookAttributeKey}'; ${allowableValuesMsg}.";
            $Logger->debug("Exiting ${subName}. Failed: ${ErrMsg}.");
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
    my (%args) = @_;
    my $bookName    = $args{BookName}    || '';
    my $chapNum     = $args{ChapNum}     || '';
    my $inFP        = $args{InFP}        || '';
    my $outFP       = $args{OutFP}       || '';
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
        unless (grep( /^$bookName$/, @BooksNames)) {
            $ErrMsg = "${subName}: Got invalid BookName:'${bookName}'; ${allowableValuesMsg}.";
            $Logger->debug("Exiting ${subName}; failed: ${ErrMsg}");
            return 0;
        }
    }

#   ChapNum parm required
    &Set_BookAttributeValue($self,
                            BookName      => "${bookName}",
                            BookAttribute => 'ChapCount');
    my $chapCount = $BookAttributeValue;
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

#   InFH parm optional
    my $inFH;
    if (length ($inFP) > 0) {
        unless (open ($inFH, "<", $inFP)) {
            $ErrMsg = "$subName: Couldn't open file $inFP for read: $!";
            $Logger->debug("Exiting ${subName}; failed: ${ErrMsg}");
            return 0;
        }
    } else {
        $inFH = *STDIN;
    }

#   OutFH parm optional
    my $outFH;
    if (length ($outFP) > 0) {
        unless (open ($outFH, ">", $outFP)) {
            $ErrMsg = "$subName: Couldn't open file $outFP for write: $!";
            $Logger->debug("Exiting ${subName}; failed: ${ErrMsg}");
            return 0;
        }
    } else {
        $outFH = *STDOUT;
    }

#   Initialise lexical variables
    my $footnotesFound  = 0;
    my $textFound       = 0;
    my @footnotesLines  = ();
    my @textLines       = ();

#   Populate BookChapter package attribute
    while (<$inFH>){
        s/^\s+//g;
        if ($_ =~ /\(BUTTON\) Update/) {
            $textFound = 1;
            $footnotesFound = 0;
            #Skip blank line.
            next;
        } elsif ($_ =~ /^Footnotes/) {
            $footnotesFound = 1;
            $textFound = 0;
        } elsif ($_ =~ /\d+\].+\Q$translation/) {
            last;
        } elsif ($_ =~ /^No results found/) {
            last;
        }
        if ($textFound) {
            s/^\d+ /\^1 /;
            push(@textLines, $_);
        }
        if ($footnotesFound) {
            push(@footnotesLines, $_);
        }
    }

    if (length ($inFP) > 0) { close ($inFH); }

    if ($#textLines > 0) {
        print $outFH @textLines;
        if (length ($outFP) > 0) { close ($outFH); }
    } else {
        if (length ($outFP) > 0) { close ($outFH); }
        $ErrMsg = "$subName: Processing failed; no text found for ${bookName} ${chapNum} (${translation}).";
        $Logger->debug("Exiting ${subName}; failed: ${ErrMsg}");
        return 0;
    }

    if ($#footnotesLines > 0) {
        print $outFH @footnotesLines;
    }

    if (length ($outFP) > 0) {
        close ($outFH);
        say "Created output file $outFP";
    }

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
    my $booksAttributesFP = "$ENV{ROCKS_HOME}/lib/BooksAttributes.tsv";
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

    chomp(my @booksAttributesLines = <$booksAttributesFH>);
    close $booksAttributesFH;

#   Read the first line of the file, the header, as keys for hash:
    my @booksAttributesKeys = split /\t/, shift @booksAttributesLines;

#   Skip BookName in header as this is the primary key of BooksAttributes hash, not a book attribute
    shift @booksAttributesKeys;

#   Sort package attribute
    @BooksAttributesKeys = sort @booksAttributesKeys;

#   Initialise lexical variables
    my $bookAttributeKey   = '';
    my $bookName           = '';
    my $bookAttributeValue = '';
    my @bookAttributes     = ();

#   Populate package attribute
    foreach (@booksAttributesLines)
    {
        @bookAttributes = split /\t/, $_;
        $bookName = shift @bookAttributes;
        my $booksAttributesIndex = 0;
        foreach (@bookAttributes) {
            $bookAttributeKey = $booksAttributesKeys[$booksAttributesIndex++];
            $bookAttributeValue = shift @bookAttributes;
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
#   BibleGateway: for English versions, spaces allowed if all ASCII, e.g.:
#   https://www.biblegateway.com/passage/?search=James\ 5\&version=RSVCE
#   https://www.biblegateway.com/passage/?search=1\ Peter\ 1\&version=RSVCE

#   BibleGateway: for non-English versions, encritics chars are expanded to hex in link copies and browser address bar, e.g.:
#   https://www.biblegateway.com/passage/?search=ΚΑΤΑ ΜΑΤΘΑΙΟΝ 1&version=SBLGNT
#   https://www.biblegateway.com/passage/?search=%CE%9A%CE%91%CE%A4%CE%91%20%CE%9C%CE%91%CE%A4%CE%98%CE%91%CE%99%CE%9F%CE%9D%201&version=SBLGNT
#   https://www.biblegateway.com/passage/?search=G%C3%A9nesis%201&version=DHH
#   https://www.biblegateway.com/passage/?search=%20%CE%A0%CE%A1%CE%9F%CE%A3%20%CE%9A%CE%9F%CE%A1%CE%99%CE%9D%CE%98%CE%99%CE%9F%CE%A5%CE%A3%20%CE%91%CE%84%201&version=SBLGNT

#   NewAdvent: (only dumps LXX for some reason) Genesis=gen, 1 Peter=1pe, e.g.:
#   https://www.newadvent.org/bible/gen001.htm
#   https://www.newadvent.org/bible/1pe001.htm

#   $text=`lynx -dump $url`;

