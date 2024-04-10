#!/usr/bin/perl
#
# Bosses around processes on the system

use strict;
use warnings;
use Data::Dumper;

# $! will give the command that failed
open(my $PS, qq(ps -Ao "%p,%u,%a" |)) or die "Couldn't open pipe from ps. $!\n";

while (<$PS>)
{
    chomp;
    # create the 3 variables based on spliting on a comma
    (my $pid, my $owner, my $command) = split ",";
    # =~ for a regex
    $pid =~ s/^\s+//;
    $owner =~ s/\s+$//;
    print "Process $pid is owned by $owner and was started with $command.\n";
}