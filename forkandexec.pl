#!/usr/bin/perl
#
# Demonstrate fork and exec combined to run other programs. 

use strict;
use warnings;

my $child_pid;
my $wait_pid;
my $exit_status;

print "PARENT: I'm the parent. My PID is $$.\n";

if (! ($child_pid = fork))
{
    # If the fork returns zero we are the child
    print "CHILD: I'm the child, my PID is $$.\n";
    print "CHILD: I think I'll go run a script.\n";
    exec("../scripts/endless_script.bash");
    die "CHILD: We should never get to this point.\n";
}

print "PARENT: I'm the parent. My PID is $$ and my child is $child_pid.\n";
print "PARENT: I'll wait on them.\n";

$wait_pid = wait;
$exit_status = $? >> 8;

print "PARENT: My child has died returning an error code of $exit_status.\n";
print "PARENT: I'm done.\n";