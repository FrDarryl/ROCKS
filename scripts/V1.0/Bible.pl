#!/usr/bin/env perl

=pod
=head1 Package: Bible.pl
=head2 Author: Fr Darryl Jordan OLW) BSl MDiv
=head3 Date: 15 August 2025 (Solemnity of the Assumption of our Lady)
=cut

# CORE packages and features used
use strict;
use utf8;
use warnings;
use Carp;
use English;

use feature 'say';

unless (defined $ENV{ROCKS_HOME}) { croak "$0: Processing failed. Environment variable ROCKS_HOME is undefined."; }

# Ubuntu system packages used
use DDP; #alias for Data::Printer; Ubuntu package: libdata-printer-perl; allows use of p directive to say a variable's value, e.g. p $spring; p %hash

use Exporter 'import';
our $VERSION = '1.00'; # set the version for version checking

use Getopt::Long; # Ubuntu package: libgetopt-long-perl; consider for later: https://metacpan.org/pod/Getopt::Euclid

# ROCKS packages used
use lib "$ENV{ROCKS_HOME}/lib";

use InitLogger;
use Bible;

# Local variables used
our $Bible                 = Bible->new;
our $BibleBookAttributeKey = '';
our $BibleBookName         = '';
our $BibleChapNum          = '';
our $BibleInFP             = '';
our $BibleOutFP            = '';
our $BibleTranslation      = '';

our $Directive = shift;
our @Directives = qw(Show_BookAttributes
                     Show_BookAttributeValue
                     Show_BookChapter
                     Show_BooksAttributes
                     Show_BooksAttributesKeys
                     Show_BooksNames
                     Show_BooksTranslations);

our $Logger = Log::Any->get_logger(); # Ubuntu package: liblog-any-adapter-dispatch-perl

our $Usage = '';

# Process arguments

if (defined $Directive) {
    unless (grep( /^$Directive$/, @Directives)) {
        $Usage = "Usage: $0 Directive (" . join(' ', @Directives) . ')';
        croak "Got invalid Directive:'${Directive}'.\n${Usage}";
    }
} else {
    $Usage = "Usage: $0 Directive (" . join(' ', @Directives) . ')';
    croak "No Directive specified.\n${Usage}";
}

$Usage = "Usage: $0 ${Directive} ";

if ($Directive eq 'Show_BookAttributeValue') {
    $Usage .= "-b BookName -a BookAttribute";
} elsif  ($Directive eq 'Show_BookAttributes') {
    $Usage .= "-b BookName";
} elsif  ($Directive eq 'Show_BookChapter') {
    $Usage .= "-t Translation -b BookName -c ChapNum [-i InputFile (default:STDIN)] [-o OutputFile (default:STDOUT)]";
} else {
    $Usage .= '(parms not needed)';
}

GetOptions ('a=s' => \$BibleBookAttributeKey,
            'b=s' => \$BibleBookName,
            'c=s' => \$BibleChapNum,
            'i=s' => \$BibleInFP,
            'o=s' => \$BibleOutFP,
            't=s' => \$BibleTranslation) || croak "${Usage}";

# Do specified directive

if ($Directive eq 'Show_BookAttributeValue') {
    Bible->Set_BookAttributeValue(BookName         => $BibleBookName,
                                  BookAttributeKey => $BibleBookAttributeKey)
      || croak "${Directive} failed.\nError: ${Bible::ErrMsg}\n${Usage}";
    p $Bible::BookAttributeValue;
} elsif ($Directive eq 'Show_BookAttributes') {
    Bible->Set_BookAttributes(BookName => $BibleBookName)
      || croak "${Directive} failed.\nError: ${Bible::ErrMsg}\n${Usage}";
    p %Bible::BookAttributes;
} elsif ($Directive eq 'Show_BookChapter') {
    Bible->Set_BookChapter(Translation => $BibleTranslation,
                           BookName    => $BibleBookName,
                           ChapNum     => $BibleChapNum,
                           InFP        => $BibleInFP,
                           OutFP       => $BibleOutFP)
      || croak "${Directive} failed.\nError: ${Bible::ErrMsg}\n${Usage}";
} elsif ($Directive eq 'Show_BooksAttributes') {
    p %Bible::BooksAttributes;
} elsif ($Directive eq 'Show_BooksAttributesKeys') {
    p @Bible::BooksAttributesKeys;
} elsif ($Directive eq 'Show_BooksNames') {
    p @Bible::BooksNames;
} elsif ($Directive eq 'Show_BooksTranslations') {
    p @Bible::TRANSLATIONS;
}
__END__
