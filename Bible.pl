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

# Ubuntu system packages used
use DDP; #alias for Data::Printer; Ubuntu package: libdata-printer-perl; allows use of p directive to say a variable's value, e.g. p $spring; p %hash
use Getopt::Long; # Ubuntu package: libgetopt-long-perl; consider for later: https://metacpan.org/pod/Getopt::Euclid

# ROCKS packages used
unless (defined $ENV{ROCKS_HOME}) { croak "$0: Processing failed. Environment variable ROCKS_HOME is undefined."; }
use lib "$ENV{ROCKS_HOME}/lib";

use InitLogger;
our $logger = Log::Any->get_logger(); # Ubuntu package: liblog-any-adapter-dispatch-perl

use Bible;

our $directive = shift;
our @directives = ('Show_BooksInfo', 'Show_BookAttribute', 'Show_BookAttributes', 'Show_BookNames', 'Show_Chapter', 'Show_Translations');
our $usage = "Usage: $0 Directive (" .  join('|', @directives) . ')';
if (defined $directive) {
    unless (grep( /^$directive$/, @directives)) { croak "${usage}"; }
} else {
    croak "${usage}";
}

our $bookAttribute   = '';
our $bookName        = '';
our $chapNum         = '';
our $inFP            = '';
our $outFP           = '';
our $translation     = '';

if ($directive eq 'Show_BooksAttribute') {
    $usage = "Usage: $0 $directive -b BookName -a BookAttribute";
} elsif  ($directive eq 'Show_BooksAttributes') {
    $usage = "Usage: $0 $directive -b BookName";
} elsif  ($directive eq 'Show_Chapter') {
    $usage = "Usage: $0 $directive -b BookName -t Translation -b BookName -c ChapNum [-i InputFile (default:STDIN)] [-o OutputFile (default:STDOUT)]";
} else {
    $usage = '';
}

# Process arguments
GetOptions ('a=s' => \$bookAttribute,
            'b=s' => \$bookName,
            'c=s' => \$chapNum,
            'i=s' => \$inFP,
            'o=s' => \$outFP,
            't=s' => \$translation) || croak "${usage}";

# Do specified directive

if ($directive eq 'Show_BookAttribute') {
    &Bible::Set_BookAttribute(BookName      => $bookName,
                              BookAttribute => $bookAttribute) || croak "${directive} failed";
    p $Bible::BookAttribute;
} elsif ($directive eq 'Show_BookAttributes') {
    &Bible::Set_BookAttributes(BookName => $bookName) || croak "${directive} failed";
    p %Bible::BookAttributes;
} elsif ($directive eq 'Show_BooksInfo') {
    p %Bible::BooksInfo;
} elsif ($directive eq 'Show_BookNames') {
    p @Bible::BookNames;
} elsif ($directive eq 'Show_Chapter') {
    &Bible::Get_Chapter(Translation => $translation,
                        BookName    => $bookName,
                        ChapNum     => $chapNum,
                        InFP        => $inFP,
                        OutFP       => $outFP) || croak "${directive} failed";
} elsif ($directive eq 'Show_Translations') {
    p @Bible::Translations;
}
__END__
