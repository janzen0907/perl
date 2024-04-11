#!/usr/bin/perl
#
# A simple socket client

use strict;
use warnings;
use IO::Socket;

# Who are we going to connect to?
(@ARGV == 2) or die "Supply only two arguements - the adderss and port of the server";

my $server_address = shift;
my $server_port = shift;

print "CLIENT: We will try to connect to $server_address:$server_port\n";

my $SOCKET = new IO::Socket::INET(
    PeerAddr => $server_address,
    PeerPort => $server_port,
    Proto => 'tcp'
);
# Run this commmand unless this is true. Reverse of an if almost
die "Could not create socket to $server_address:$server_port" unless $SOCKET;

print "CLIENT: Successfully connect to $server_address:$server_port";

# Sending a message to ther server
$SOCKET->send("Client says hello!");

while (<$SOCKET>)
{
    print "CLIENT: Recived from server: $_\n";
}

print "CLIENT: Server has closed our connection.\n";
close $SOCKET or die "Coudln't close socket.\n";