package InitLogger;

=pod
=head1 Package: Bible.pm
=head1 Author: davewood (Adapted from stackoverflow post: https://stackoverflow.com/questions/23357231/mention-time-in-a-log-file-using-perl)
=head1 Co-Author: Fr Darryl Jordan OLW BSc MDiv
=head1 Date: 15 August 2025 (Solemnity of the Assumption of our Lady)
=cut

# Perl CORE and system packages used
use strict;
use warnings;
use POSIX qw/strftime/;

use feature qw/ say /;

use Log::Any::Adapter; #Ubuntu Package liblog-any-adapter-dispatch-perl; allows use of p command to say a variable's value, e.g. p $spring; p %hash
use Log::Dispatch; #Ubuntu Package ibid.

my $log_file = "$ENV{ROCKS_HOME}/log/ROCKS.log";

my $log = Log::Dispatch->new(
    outputs   => [
            [
            'Screen',
            name      => 'screen',
            min_level => 'error',
            newline   => 1
            ],
            [
            'File',
            filename  => $log_file,
            min_level => 'debug',
            newline   => 1,
            mode      => 'append'
            ]
    ],
    callbacks => [
        sub {
            my %msg = @_;
            return sprintf(
                "%s %d %s",
                strftime("%F %H:%M:%S", localtime),
                $$,
                $msg{message}
            );
        }
    ]
);

Log::Any::Adapter->set( 'Dispatch', dispatcher => $log );

1;
