#!/usr/bin/env perl

use strict;
use warnings;

#https://perldoc.perl.org/Getopt::Long
use Getopt::Long;

my $usage = "Usage: $0 -i InputPDFPath -o OutputPDFPath\n";

my $inFilePath = '';
my $outFilePath = '';
GetOptions ('i=s' => \$inFilePath,
            'o=s' => \$outFilePath);

use PDF::API2;

# Open an existing PDF file
unless ($inFilePath ne '') { die $usage; }
my $inFileObj = PDF::API2->open($inFilePath);

if ( $inFileObj->is_encrypted() ) {
    print "Warning: $inFilePath is encrypted!\n";
}

my $tocHash = $inFileObj->outlines();
$inFileObj->close();

use Data::Dump "dd";
my $tocText = dd($tocHash);
print "TOC: $tocText\n";

# Create a blank PDF file
unless ($outFilePath ne '') { die $usage; }
my $outFileObj = PDF::API2->new();

my $font = $outFileObj->font('Helvetica-Bold');
my $page = $outFileObj->page();
my $content = $page->text();
$content->position(1 * 72, 9 * 72);
$content->font($font, 24);
$content->text('Hello, World!');
$content->position(0, -36);
$content->font($font, 12);
$content->text($tocText);

$outFileObj->save($outFilePath);
$outFileObj->close();

