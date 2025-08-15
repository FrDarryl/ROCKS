#!/usr/bin/env perl

=pod
=head1 Package: CreateBibleVersionDir.pl
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

my $usage = "Usage: $0 -v DRA|VULGATE|etc.\n";

my $version;
GetOptions ('v=s' => \$version);

unless (defined $version) { die $usage; }

unless (defined $ENV{ROCKS_HOME}) { $logger->logdie("Processing failed. Environment variable ROCKS_HOME is undefined."); }

my $biblesInfoFilePath = "$ENV{ROCKS_HOME}/txt/Bibles/BiblesInfo.txt";
my $biblesInfoFileHandle;
open ($biblesInfoFileHandle, "<", $biblesInfoFilePath) or die "Couldn't open file $biblesInfoFilePath for read: $!";
# Read the first line of the file:
my %biblesInfoHash;
my $bookName;
my $bookLectorAnnouncement;
my $bookChaptersCount;
my $totalChaptersCount = 0;
while (<$biblesInfoFileHandle>)
{
    ($bookName, $bookChaptersCount, $bookLectorAnnouncement) = split /\t/, $_;
    $biblesInfoHash{$bookName} = $bookChaptersCount;
    $totalChaptersCount += $bookChaptersCount;
}
close ($biblesInfoFileHandle) || die "Couldn't close \$biblesInfoFilePath:$biblesInfoFilePath properly: $!";

print "Total chapters: $totalChaptersCount\n";
use Data::Dumper;
print Dumper \%biblesInfoHash;

#lynx -dump "https://www.biblegateway.com/passage/?search=James\ 5\&version=RSVCE" | GetBibleTxtFromBibleGateway.pl -v=RSVCE -o="RSVCE/RSVCE_James-5.txt"
#lynx -dump "https://www.biblegateway.com/passage/?search=1\ Peter\ 1\&version=RSVCE" | GetBibleTxtFromBibleGateway.pl -v=RSVCE -o="RSVCE/RSVCE_1Peter-1.txt"

#$text=`lynx -dump $url`;

my $state = "Success";
unless ($state eq "Success") {
    $logger->logdie("Processing failed. \$version:$version State: \$state:$state");
}
