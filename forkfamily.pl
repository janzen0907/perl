#!/usr/bin/perl
#
# Demonstarte forking to create multiple children

use strict;
use warnings;

my $fork_pid;
my $wait_pid;
my $exit_status;
my $birth_order = 0;

print "PARENT: I'm the parent, my PID is $$.\n";

for (1..3)
{
    # If not fork. If fork returns 0 then its the child
    if (!($fork_pid = fork)) # If fork returns 0 then we are the child
    {
        # The topic is where we are in the for loop, so 1 then 2 then 3
        $birth_order = $_;
        print "CHILD$birth_order: My Pid is $$ and fork returned $fork_pid. I'm child $birth_order.\n";
        for (1..5)
        {
            print "CHILD$birth_order: My PID is $$ and I'm doing something important.\n";
            sleep 1;
        }
        print "CHILD$birth_order: Now I'm done.\n";
        exit 16 + $birth_order;
    }
}

print "PARENT: MY PID is $$. I'm obviously the parent, because otherwise how would i get to this code?\n";
print "PARENT: I'll wait for my children to die.\n";

while ( ($wait_pid = wait) != -1) # NOTE: If there are no children wait will return -1
{
    $exit_status = $? >> 8;
    print "PARENT: Done waiting for my child. Wait returned $wait_pid and the exit code was $exit_status.\n";
}



print "PARENT: All my children are dead. I am done.\n";
exit 0;