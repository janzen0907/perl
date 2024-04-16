#!/usr/bin/perl
#
# Purpose: Script for managaing LDAP users on a remote system. 
# Author: John Janzen (janzen0907)

use strict;
use warnings;
use feature qw(switch);
use IO::Socket;

# Variables
my $userlist;
my $grouplist;
my $next_uid = 5000;
# my $client_socket;
my $add_group;
my $client_message;
my $group_name;
my $new_uid;
my $home_dir;
my $PORT = 10912;

# Check if any command-line arguments are provided
if (@ARGV) {
    # Client mode
    my $server_address = shift(@ARGV);

    print "CLIENT: Attempting to connect to $server_address\n";

    # Create a client socket
    my $client_socket = new IO::Socket::INET(
        PeerAddr => $server_address,
        PeerPort => $PORT,
        Proto    => 'tcp'
    ) or die "Could not create socket to $server_address:$PORT: $!\n";

    # Menu to provide the valid options to the user.
    print "CLIENT: Successfully connected to $server_address. Please select an option\n";
    print "1: List the LDAP Users\n";
    print "2: List the LDAP Groups\n";
    print "3: Set a group\n";
    print "4: Create a user\n";
    print "5: Exit\n";
    print "Enter your choice please: ";

    # Get the choice from the user
    my $user_choice = <STDIN>;

    # Send the choice to the server
    $client_socket->send($user_choice);

    # Receive response from the server
    my $response;
    $client_socket->recv($response, 1024);
    print "CLIENT: Received from server: $response\n";

    # Close client socket
    close($client_socket) or die "Couldn't close socket: $!\n";
} else {
    # Server mode
    # Start the server
    my $server_socket = new IO::Socket::INET(
        LocalPort => $PORT,
        Proto     => 'tcp',
        Listen    => 5,
        Reuse     => 1
    ) or die "Could not create server socket: $!\n";

    print "Server is listening on port $PORT\n";

    print "The socket is: $server_socket\n";

# Start the server
my $server_socket = new IO::Socket::INET(
    LocalPort => $PORT,
    Proto => 'tcp',
    Listen => 5,
    Reuse => 1
) or die "Could not create server socket: $!\n";

print "Server is listening on port $PORT\n";

print "The socket is: $server_socket\n";

# Client Code
while (my $client_socket = $server_socket->accept())
{
        # Get the client message
    $client_socket->recv(my $client_message, 1024);
    chomp($client_message);
    
    # Check what the message coming from the client is
    if ($client_message eq "userlist")        {
        # Code here to get a comma seperated list of all the LDAP users on the server
        # Osudo slapcat to get the LDAP Database
        open(my $LDAPUSERS, "sudo slapcat |" ) or die "Couldn't Open the ldap database. $!\n";            # I can either put all the input into a file then parse it or just parse the stream

        while (my $line = <$LDAPUSERS>)
        {
            chomp($line);
            # Use a regex to get the users from slapcat
            if ($line =~ /uid=([a-zA-Z0-9]+)/)
            {
                # Add the users to a cs list
                $userlist .= "$1,";
            }

            # Get rid of the trailing comma
            $userlist =~ s/,$//; 
        }  
        # Close the file handle
        close($LDAPUSERS);
    }

    elsif ($client_message eq "grouplist")
    {

        # Code here to get a comma seperated list of all the LDAP groups on the server
        open(my $LDAPGROUPS, "sudo slapcat |") or die "Couldn't Open the ldap database. $!\n";

        while(my $line = <$LDAPGROUPS>)
        {
            chomp($line);

            # Use a regex to get the group from slapcat
            if ($line =~ /gid:\s*(\d+)/)
            {
                # Add the groups to a cs list
                $grouplist .= "$1,";
            }

            # Get rid of the trailing comma
            $grouplist =~ s/,$//;

        }
            # Close the file handle
            close($LDAPGROUPS);
    }

    elsif ($client_message eq "setgroup") 
    {
        # Code here to get two arguments - first is the command second is the name of the group to create new users in
        (@ARGV == 2) or die "Please supply the name of the group to create\n";
        my $newgroup = shift;
        # Boolean to see if the group exists
        my $group_exists = 0;
        open(my $LDAPNEWGROUP, "sudo slapcat | ") or die "Couldn't Open the ldap database. $!\n";
            
        while(my $line = <$LDAPNEWGROUP>)
        {
            chomp($line);

            # Use a regex to get the group name (cn) from LDAP
            if ($line =~ /cn: ([a-zA-Z0-9]+)/)
            {
                # Get the name of the group to compare
                my $group_name = $1;

                # Check if the passed in group matches any group names
                if ($group_name eq $newgroup)
                {
                    # Set our boolean to 1, indicating the group does exist
                    $group_exists = 1;
                    # Respond with “set” if the group existed
                    print $client_socket "set\n";
                    last; # Exit the loop we are done at this point
                }
                    
                }
            # If this group does not exist, the server should create it. The server should respond to the client 
                
            if (!$group_exists)
            {
                my $add_group = `sudo groupadd $newgroup 2>&1`;
                print $client_socket "set\n";
                if($? == 0)
                {
                    # The group was created successfully
                    #“created” if the group had to be created,
                    print $client_socket "created\n";
                }
                else
                {
                    # or “error” if the group did not exist and could not be created.
                    print $client_socket "error\n";
                } 
                    
            }
                
                    
        }
            # Close the file handle
            close($LDAPNEWGROUP);
    }
        
    elsif ($client_message eq "createuser")
    {
        # Code here to get three arguments - first is the command second is the name of the user the client wants to 
        # make, third is the password for the user being created.
        (@ARGV == 3) or die "Please supply the name of the user and the password for this user\n";
        # Get the username and password from the arguments 
        my ($username, $password) = @ARGV;
        my $group_set = 0;
            
        # The user should use the group previously set with 
        # setgroup, and if setgroup has not been called or was called and failed the user should not be created and 
        # the server should send an “error-nogroup” response to the client. 
            
        # TODO: Create this flag and set it elsewhere
        if (!$group_set)
        {
            print $client_socket "error-nogroup\n";
            return;
        }

        # The new user should have a uid above 5000 and not previously used by any other LDAP user on the server. 
        # You may assume uids and gids in the 5000-6000 range are not being used except by your script. 

        my $uid = $next_uid++;
        if($uid >= 6000 || $uid <= 4999)
        {
            print $client_socket "error-other\n";
            return;
        }

        # The newly created user’s home directory should be in /home/[the name of the user’s group]/[the user’s name] 
        # and the server is responsible for appropriately creating the directory using /etc/skel and chowning the 
        # directory to the right uid and gid. If the directory cannot be created, the server should send an “error-nohome” 
        #response to the client

        # Figure out how to initialize and use this. 
        my $group_gid;
        # Create the home dir path
        my $home_dir = "/home/$group_name/$username";

        # Check if the directory can be created
        unless (-e $home_dir or mkdir $home_dir)
        {
            print $client_socket "error-nohome\n";
            return;
        }

        # If the creation of the LDAP user fails for any other reason, the server should send the client an 
        # “error-other” response

        # How you create the LDAP users is up to you – you can create them as local users first and then convert 
        # them into ldif format before adding them, you can generate the ldifs from a template, or whatever you wish

        # Create the LDIF file for the addition of a new user
        my $ldif_file = "/tmp/$username.ldif";
        open (my $LDIF, '>', $ldif_file) or die "Error creating the LDIF file: $!";
        print $LDIF "dn: uid=$username,ou=People,dc=coos,dc=cst,dc=ca\n";
        print $LDIF "objectClass: posixAccount\n";
        print $LDIF "objectClass: shadowAccount\n";
        print $LDIF "objectClass: inetOrgPerson\n";
        print $LDIF "cn: $username\n";
        print $LDIF "sn: $username\n";
        print $LDIF "uid: $username\n";
        print $LDIF "uidNumber: $new_uid\n";
        print $LDIF "gidNumber: $group_gid\n";
        print $LDIF "homeDirectory: $home_dir\n";
        print $LDIF "loginShell: /bin/bash\n";
        close($LDIF);
            
        # Add the user to LDAP
        my $add_user = `sudo ldapadd -x -W -D "cn=admin,dc=coos,dc=cst,dc=ca" -f $ldif_file 2>&1`;
        if($? == 0)
        {
            print $client_socket "user-created\n";
        }
        else
        {
            print $client_socket "error-other\n";
        }
        # Remove the temp file
        # unlink $ldif_file;
    }
        
}

(@ARGV == 1) or die "Supply one argument, the IP address of the server\n";
# Perhaps consider a variable here for the port number
my $server_address = shift;

print " CLIENT: Attempting to connect to $server_address";

my $client_socket = new IO::Socket::INET(
    PeerAddr => $server_address,
    PeerPort => $PORT,
    Proto => 'tcp'
);
die "Could not create socket to $server_address:$PORT :$!" unless $client_socket;

# Menu to provide the valid options to the user. 
print "CLIENT: Successfully connected to $server_address. Please select an option\n";
print "1: List the LDAP Users\n";
print "2: List the LDAP Groups\n";
print "3: Set a group\n";
print "4: Create a user\n";
print "5: Exit\n";
print "Enter your choice please\n";

# Get the choice from the user
my $user_choice = <STDIN>;

# Get the message from the user and send it to the client
# I didn't want to use if statements, learned switch (given, when) from
# https://www.perltutorial.org/perl-given/
given($user_choice)
{
    when (1) 
    {
        $client_message = "userlist";
    }
    when (2)
    {
        $client_message = "grouplist";
    }
    when (3)
    {
        print "Enter the name of the group: \n";
        my $group = <STDIN>;
        chomp($group);
        $client_message = "setgroup $group";
    }
    when (4)
    {
        print "Enter the username: \n";
        my $username = <STDIN>;
        chomp($username);
        print "Enter the password: \n";
        my $password = <STDIN>;
        chomp($password);
        $client_message = "createuser $username $password";
    }
    when (5)
    {
        print "Closing the script\n";
        last;
    }
    default
    {
        print "Invalid choice, Please choose a selection between 1-5\n";
        next;
    }
}

# Send a message to the server
$client_socket->send($client_message);

print "The server responded:\n";

while (<$client_socket>)
{
    # Use the topic to get the message from the server
    print "CLIENT: Recived from server: $_\n";
}

print "CLIENT: The server has closed the connection\n";
close $client_socket or die "Couldn't close socket.\n";

print "Client Socket is $client_socket\n";

# Server Code
# Loop while there is a connection


# Code to send messages to the client, further refine this
# print $client_socket = 


