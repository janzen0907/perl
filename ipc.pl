#!/usr/bin/perl
#
# Demonstrate a way to communicate between parent and child

use strict;
use warnings;

my $pid;

$pid = open (my $CHILDPROC, "|-");

unless (defined $pid) {
    die "Could not fork child";
}

if ($pid) {
    print "PARENT: I'm the parent, my child's PID is $pid\n";
    print $CHILDPROC "Hello my child";
}
else
{
    print "CHILD: I'm the child and my PID is $$ and the open returned $pid\n";
    while (<STDIN>)
    {
        print "CHILD: The parent sent me $_\n";
    }
}

$pid = open (my $SECONDCHILD, "-|");

if($pid) 
{
    print "PARENT: I'm the parent, my new child's pid is $pid\n";
    while(<$SECONDCHILD>)
    {
        print "PARENT: My child sent me $_\n";
    }
    exit 0;
}
else 
{
    print "CHILD: I'm the child my pid is $$, and the fork returned $pid\n";
    exit 0;
}