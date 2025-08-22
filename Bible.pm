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

use feature 'say';

# Ubuntu system packages used
use DDP; #alias for Data::Printer; Ubuntu package: libdata-printer-perl; allows use of p command to say a variable's value, e.g. p $spring; p %hash
use Getopt::Long; # Ubuntu package: libgetopt-long-perl; Consider for later: https://metacpan.org/pod/Getopt::Euclid
use Text::Unidecode; # Ubuntu package libtext-unidecode-perl

# ROCKS packages used
unless (defined $ENV{ROCKS_HOME}) { croak "$0: Processing failed. Environment variable ROCKS_HOME is undefined."; }
use lib "$ENV{ROCKS_HOME}/lib";

use InitLogger;
our $Logger = Log::Any->get_logger(); # Ubuntu package: liblog-any-adapter-dispatch-perl

# Module global variables

our $BookAttribute    = '';
our %BookAttributes   = ();
our %BooksInfo        = ();
&Set_BooksInfo();
our @BookNames        = sort keys %BooksInfo;
our @Translations     = qw(CEB CEI DHH DRA ESV ESVUK GNB MBBTAG-DC NRSVA NRSVCE NRSVUE RSV RSVCE TLA VULGATE WYC);

our @ExportedFunctions = qw(Get_Chapter Set_BookAttribute Set_BookAttributes);
our @ExportedVariables = ($BookAttribute, %BookAttributes, @BookNames, %BooksInfo, @Translations);

# Get the import method from Exporter to export functions and variables
use Exporter 'import';
our $VERSION = '1.00'; # set the version for version checking
our @EXPORT_OK = (@ExportedFunctions, @ExportedVariables);

# Module subroutines/methods

sub Get_Chapter
{
#   my $self = shift;
    my $subName = (caller(0))[3];
    $Logger->debug("Entering $subName");

    my (%args) = @_;
    my $bookName    = $args{BookName}    || '';
    my $chapNum     = $args{ChapNum}     || '';
    my $inFP        = $args{InFP}        || '';
    my $outFP       = $args{OutFP}       || '';
    my $translation = $args{Translation} || '';

    my $usage;

    my $allowableValuesMsg = "allowable values: (" . join('|', @Translations) .')';
    if ($translation eq '') {
        croak "${subName}: No Translation specified; ${allowableValuesMsg}.";
    } else {
        unless (grep( /^$translation$/, @Translations)) { croak "${subName}: Got invalid Translation:'${translation}'; ${allowableValuesMsg}."; }
    }

    $allowableValuesMsg = "allowable values: (" . join('|', @BookNames) .')';
    if ($bookName eq '') {
        croak "${subName}: No BookName specified; ${allowableValuesMsg}.";
    } else {
        unless (grep( /^$bookName$/, @BookNames)) { croak "${subName}: Got invalid BookName:'${bookName}'; ${allowableValuesMsg}."; }
    }

    Set_BookAttribute(BookName      => "${bookName}",
                      BookAttribute => 'ChapCount');
    my $chapCount = $BookAttribute;
    $allowableValuesMsg = "allowable values: (1..${chapCount})";
    if ($chapNum eq '') {
        croak "${subName}: No ChapNum specified; ${allowableValuesMsg}.";
    } else {
        unless ($chapNum <= $chapCount) { croak "${subName}: Got invalid ChapNum:'${chapNum};  ${allowableValuesMsg}."; }
    }

    my $inFH;
    if (length ($inFP) > 0) {
        unless (open ($inFH, "<", $inFP)) {
            $Logger->debug("Exiting $subName");
            croak "$subName: Couldn't open file $inFP for read: $!";
        }
    } else {
        $inFH = *STDIN;
    }

    my $outFH;
    if (length ($outFP) > 0) {
        unless (open ($outFH, ">", $outFP)) {
            $Logger->debug("Exiting $subName");
            croak "$subName: Couldn't open file $outFP for write: $!";
        }
    } else {
        $outFH = *STDOUT;
    }

    my $footnotesFound  = 0;
    my $textFound       = 0;
    my @footnotesLines  = ();
    my @textLines       = ();

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
    } else {
        if (length ($outFP) > 0) { close ($outFH); }
        $Logger->debug("Exiting $subName");
        croak "$subName: Processing failed; no text found for ${bookName} ${chapNum} (${translation}).";
    }

    if ($#footnotesLines > 0) {
        print $outFH @footnotesLines;
    }

    if (length ($outFP) > 0) {
        close ($outFH);
        say "Created output file $outFP";
    }

    $Logger->debug("Exiting $subName");
    return 1;
}

sub Set_BooksInfo
{
#   my $self = shift;
    my $subName = (caller(0))[3];
    $Logger->debug("Entering $subName");

    %BooksInfo = ();

    my $booksInfoFH;
    my $booksInfoFP = "$ENV{ROCKS_HOME}/Bible/BooksInfo.tsv";
    if (-e $booksInfoFP) {
        unless (open ($booksInfoFH, "<", $booksInfoFP)) {
            $Logger->debug("Exiting $subName");
            croak "$subName: Couldn't open file $booksInfoFP";
        }
    } else {
        $Logger->debug("Exiting $subName");
        croak "$subName: BooksInfo file $booksInfoFP does not exist.";
    }

#   Read the first line of the file, the header, as keys for hash:
    my @booksInfoKeysArray = split /\t/, <$booksInfoFH>;

#   Skip first header element ("BookName")
    shift @booksInfoKeysArray;
    my @booksInfoKeysRange = (0..$#booksInfoKeysArray);

    my $bookName;
    my @booksInfoValuesArray = ();

    while (<$booksInfoFH>)
    {
        @booksInfoValuesArray = split /\t/, $_;
        $bookName = shift @booksInfoValuesArray;
        for (@booksInfoKeysRange) {$BooksInfo{$bookName}{$booksInfoKeysArray[$_]} = shift @booksInfoValuesArray; }
    }

    close $booksInfoFH;

    $Logger->debug("Exiting $subName");
}

sub Set_BookAttribute
{
#   my $self = shift;
    my $subName = (caller(0))[3];
    $Logger->debug("Entering $subName");

    my (%args) = @_;
    my $bookName         = $args{BookName}      || '';
    my $bookAttributeKey = $args{BookAttribute} || '';

    my $allowableValuesMsg = "allowable values: (" . join('|', @BookNames) .')';
    if ($bookName eq '') {
        croak "${subName}: No BookName specified; ${allowableValuesMsg}.";
    } else {
        unless (grep( /^$bookName$/, @BookNames)) { croak "${subName}: Got invalid BookName:'${bookName}'; ${allowableValuesMsg}."; }
    }

    &Set_BookAttributes(BookName => "${bookName}");
    my @bookAttributesKeys = sort keys %BookAttributes;

    $allowableValuesMsg = 'allowable values: (' . join('|', @bookAttributesKeys) .')';
    if ($bookAttributeKey eq '') {
        croak "${subName}: No BookAttribute specified; ${allowableValuesMsg}.";
    } else {
        unless (grep( /^$bookAttributeKey$/, @bookAttributesKeys)) { croak "${subName}: Got invalid BookAttribute:'${bookAttributeKey}'; ${allowableValuesMsg}."; }
    }

    $BookAttribute = $BookAttributes{$bookAttributeKey};

    $Logger->debug("Exiting $subName");
}

sub Set_BookAttributes()
{
#   my $self = shift;
    my $subName = (caller(0))[3];
    $Logger->debug("Entering $subName");

    my (%args) = @_;
    my $bookName = $args{BookName} || '';

    my $allowableValuesMsg = "allowable values: (" . join('|', @BookNames) .')';
    if ($bookName eq '') {
        croak "${subName}: No BookName specified; ${allowableValuesMsg}.";
    } else {
        unless (grep( /^$bookName$/, @BookNames)) { croak "${subName}: Got invalid BookName:'${bookName}'; ${allowableValuesMsg}."; }
    }

    %BookAttributes = %{$BooksInfo{$bookName}};

    $Logger->debug("Exiting $subName");
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

