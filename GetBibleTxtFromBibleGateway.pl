#!/usr/bin/env perl

=pod
=head1 Package: GetBibleTxtFromBibleGateway.pl
=head2 Author: Fr Darryl Jordan OLW BSc MDiv
=head3 Date: 15 August 2025 (Solemnity of the Assumption of our Lady)
=cut

use strict;
use warnings;

#https://perlmaven.com/logging-with-log4perl-the-easy-way
use Log::Log4perl qw(:easy);
Log::Log4perl->easy_init($DEBUG);
#https://metacpan.org/release/MSCHILLI/Log-Log4perl-1.49/view/lib/Log/Log4perl.pm#Initialize_via_a_configuration_file
Log::Log4perl->init("$ENV{ROCKS_HOME}/config/log4perl.conf");
my $logger = Log::Log4perl->get_logger();

#https://perldoc.perl.org/Getopt::Long
use Getopt::Long;

my $usage = "Usage: $0 -v DRA|VULGATE|etc. [-i InputFilePath (default:STDIN)] [-o OutputFilePath (default:STDOUT)]\n";

my $inFilePath;
my $outFilePath;
my $version;
GetOptions ('v=s' => \$version,
            'i=s' => \$inFilePath,
            'o=s' => \$outFilePath);

unless (defined $version) { die $usage; }

my $inFileHandle;
if (defined $inFilePath){
    open ($inFileHandle, "<", $inFilePath) or die "Couldn't open file $inFilePath for read: $!";
} else {
    $inFileHandle = *STDIN;
}

my $outFileHandle;
if (defined $outFilePath){
    open ($outFileHandle, ">", $outFilePath) or die "Couldn't open file $outFilePath for write: $!";
} else {
    $outFileHandle = *STDOUT;
}

my @bibleTextArray = ();
my @footnotesTextArray = ();
my $state = "PreText";
while (<$inFileHandle>){
    s/^\s+//g;
    if ($_ =~ /\(BUTTON\) Update/) {
        $state = "Text";
        #Skip blank line.
        next;
    } elsif ($_ =~ /^No results found/) {
        $state = "NoResultsFound";
    } elsif ($_ =~ /^Footnotes/) {
        $state = "Footnotes";
    } elsif ($_ =~ /\d+\].+\Q$version/) {
        $state = "Success";
        last;
    } elsif ($_ =~ /^No results found/) {
        $state = "NoResultsFound";
        last;
    }
    $logger->debug("$_");

    if ($state eq "Text") {
        s/^\d+ /\^1 /;
        push(@bibleTextArray, $_);
    } elsif ($state eq "Footnotes") {
        push(@footnotesTextArray, $_);
    }
}

unless ($state eq "Success") {
    $logger->logdie("Processing failed. \$version:$version State: \$state:$state");
}
unless ($#bibleTextArray > 0) {
    $logger->logdie("Processing failed; no Bible text detected. \$version:$version State: \$state:$state");
}

print $outFileHandle @bibleTextArray;
print $outFileHandle @footnotesTextArray;

if (defined $inFilePath){ close ($inFileHandle) || die "Couldn't close \$inFile:$inFilePath properly: $!"; }
if (defined $outFilePath){ close ($outFileHandle) || die "Couldn't close \$outFilePath:$outFilePath properly: $!"; }

