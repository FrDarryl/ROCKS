#!/usr/bin/env perl

=pod
=head1 Package: Ordo.pm
=head2 Author: Fr Darryl Jordan OLW) BSl MDiv
=head3 Date: 15 August 2025 (Solemnity of the Assumption of our Lady)
=cut

# CORE packages and features used
use strict;
use warnings;

use Carp;
use English;
use utf8;
use feature 'say';

# Ubuntu system packages used
use DDP; #alias for Data::Printer; Ubuntu package: libdata-printer-perl; allows use of p directive to say a variable's value, e.g. p $spring; p %hash
use Getopt::Long; # Ubuntu package: libgetopt-long-perl; consider for later: https://metacpan.org/pod/Getopt::Euclid

# ROCKS packages used
unless (defined $ENV{ROCKS_HOME}) { croak "$0: Processing failed. Environment variable ROCKS_HOME is undefined."; }
use lib "$ENV{ROCKS_HOME}/lib";

use InitLogger;
our $logger = Log::Any->get_logger(); # Ubuntu package: liblog-any-adapter-dispatch-perl

use Ordo;

# Commands (Ordo subroutines) and their parameters
our $directive = shift;
our @directives = ('Create_Ordo');
our $usage = "Usage: $0 Directive (" .  join('|', @directives) . ')';
if (defined $directive) {
    unless (grep( /^$directive$/, @directives)) { croak "${usage}"; }
} else {
    croak "${usage}";
}

our $outFP  = "";
our $rite   = "";
our $year   = "";

if ($directive eq 'Create_Ordo') {
    $usage = "Usage: $0 $directive  (NOE|VOE)] -y Year (YYYY) [-o OutputFile]";
} else {
    $usage = '';
}
GetOptions ('r=s' => \$rite,
            'y=s' => \$year,
            'o=s' => \$outFP) || croak "${usage}";

# Do specified directive

if ($directive eq 'Create_Ordo') {
    unless ($rite =~ /^(NOE|VOE)$/ && $year =~ /^\d{4}$/) { croak "$usage"; }

    unless ($outFP ne '') { $outFP = "$ENV{ROCKS_HOME}/tsv/${rite}_Ordo_${year}.tsv"};

    unless (Ordo->Create_Ordo (Rite => $rite,
                               Year => $year,
                               OutFP => $outFP)) {
        croak "Create_Ordo failed";
    }
}

exit 1;
__END__;
