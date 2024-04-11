#!/usr/bin/perl
#
# Demonstrate the fork system call

use strict;
use warnings;

my $fork_pid;
my $wait_pit;
my $exit_status;

# Use $$ to get the pid of the current process
print "I'm the parent and my pid is $$\n";

$fork_pid = fork;

 

# This print runs twice, becuase it creates another procress that is doing the same thing
# They don't share the same memory, it is a copy of the process in a new memory location
# Fork Creates a child, the child is an exact duplicate of the parent.
# print "My Pid is $$ and fork returned $fork_pid.\n";
if ($fork_pid)
{
   print "PARENT: My PID is $$, my child's PID is $fork_pid.\n";
   print "PARENT: I am going to wait for my child to finsih.\n";
   $wait_pit = wait;
   # Shift it 8 bits to the right so the exit status is correct
   $exit_status = $? >> 8; # Checking what the exit status was
   print "PARENT: Done waiting for my child $fork_pid. Wait returned $wait_pit. It's exit code was $exit_status.\n";
   exit 0;
} else {
    print "CHILD: My PID is $$ and fork returned $fork_pid.\n";
    # Loop in a range, same as Python and Swift
    for (1..5)
    {
        print "CHILD: I'm doing something!\n";
        sleep 1;
    }
    print "CHILD: Now I'm done.\n";
    exit 21;
} 
