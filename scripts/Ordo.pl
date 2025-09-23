#!/usr/bin/env perl

=pod
=head1 Package: Ordo.pm
=head2 Author: Fr Darryl Jordan OLW) BSl MDiv
=head3 Date: 15 August 2025 (Solemnity of the Assumption of our Lady)
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

unless (defined $ENV{ROCKS_HOME}) { croak "$0: Processing failed. Environment variable ROCKS_HOME is undefined."; }

# Ubuntu system packages used. See help/UbuntuPackagesRequired.txt
use Data::Printer; # allows use of p command to say a variable's value, e.g. p $spring; p %hash
use Getopt::Long; # Ubuntu package: libgetopt-long-perl; consider for later: https://metacpan.org/pod/Getopt::Euclid

# ROCKS packages used
use lib "$ENV{ROCKS_HOME}/lib";

use InitLogger;

use Ordo;

# Local variables used
our $Directive = shift;
our @Directives = qw(Create_Ordo
                     Show_Rites);

our $Logger = Log::Any->get_logger(); # Ubuntu package: liblog-any-adapter-dispatch-perl

our $Ordo       = Ordo->new;
our $OrdoOutFP  = "";
our $OrdoRite   = "";
our $OrdoYear   = "";
our $OrdoUrl    = "";

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

$Usage = "Usage: $0 $Directive ";

if ($Directive eq 'Create_Ordo') {
    $Usage .= "-r Rite -y Year (YYYY) [-u URL] [-o OutputFile]";
} else {
    $Usage = '(parms not needed)';
}

GetOptions ('r=s' => \$OrdoRite,
            'y=s' => \$OrdoYear,
            'o=s' => \$OrdoOutFP,
            'u=s' => \$OrdoUrl) || croak "${Usage}";

# Do specified directive

if ($Directive eq 'Create_Ordo') {
    Ordo->Create_Ordo (Rite  => $OrdoRite,
                       Year  => $OrdoYear,
                       OutFP => $OrdoOutFP,
                       URL   => $OrdoUrl) ||
        croak "Create_Ordo failed.\n$Ordo::ErrMsg\n${Usage}";
} elsif ($Directive eq 'Show_Rites') {
    my $ordoRitesRef = Ordo->Get_Rites;
    p @{$ordoRitesRef};
}

exit 1;
__END__;
