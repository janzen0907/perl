#!/usr/bin/perl
#
# Purpose: Script for managaing LDAP users on a remote system. 
# 
# Issues: Currently the Prompts for the client are appearing on the server.. I sadly ran
# out of time to try and fix this. I think its due to some of my send -> recv messages
# being backwards.
# 
# Author: John Janzen (janzen0907)
# Class: COOS 291 - Section B

use strict;
use warnings;
use IO::Socket;

# Variables
my $userlist;
my $grouplist;
my $next_uid = 5000;
my $add_group;
my $client_socket;
my $client_message;
my $group_name;
my $new_uid;
my $home_dir;
my $PORT = 10912;
my $localhost = '10.36.106.94';
my $server_mode = 0;

# Check if an ip address is provided
if (@ARGV == 0) 
{ 
    print "Attempting to start server mode";
    $server_mode = 1; # Server mode
    print "Server mode is set to : $server_mode";
}
elsif (@ARGV == 1)
{
    print "In Client mode";
    $server_mode = 0; # Client mode
    print "Server mode is set to : $server_mode";
}
else
{
    die "Supply 0 args for server mode and 1 argument (ip address of server) for client mode";
}

if($server_mode)
{
    print "In server Mode";
    start_server($localhost);
    print "The server is running";
}
else 
{
    my $server_address = shift;
    $client_socket = new IO::Socket::INET(
        PeerAddr => $server_address,
        PeerPort => $PORT,
        Proto => 'tcp'
    );
    # Check if the conenction is successful
    die "Could not connect to server: $!\n" unless $client_socket; 


    print "CLIENT: Connected to $server_address. Please select an option\n";
    print_menu();
    
    # Continue looping until the client enters 5
    while (1) 
    {
        print "Enter your choice\n";
        my $user_choice = <STDIN>;
        chomp($user_choice);
        last if $user_choice eq "5"; # Break out of the loop
        process_client_choice($client_socket, $user_choice);
    }
    close($client_socket);
}

sub start_server{
    my ($server_address) = $localhost;
    my $server_socket = new IO::Socket::INET(
       #  LocalAddr => $server_address,
        LocalPort => $PORT,
        Proto => 'tcp',
        Listen => 5,
        Reuse => 1
    )
    or die "Could not create server: $!\n";
    
     # Accept Connections from client
    while (my $client_socket = $server_socket->accept()) {
        print "SERVER: Connection received from client\n";
        my $client_message;
        $client_socket->recv($client_message, 1024);
        chomp($client_message);
        print "SERVER: Received message from client: $client_message\n";
        process_client_request($client_socket, $client_message);
    }
}


sub print_menu{

    print "1: List the LDAP Users\n";
    print "2: List the LDAP Groups\n";
    print "3: Set a group\n";
    print "4: Create a user\n";
    print "5: Exit\n";
    print "Enter your choice please\n";
}



# Sub to get the message that the client is sending to the server
# sub get_message_from_client {
#     my ($client_socket) = @_;
#     my $client_message;
#     $client_socket->recv($client_message, 1024);
#     chomp($client_message);
#     return $client_message;
# }

# Sub to get the string from the client and then call required subroutines to complete the request
sub process_client_request {
    my ($client_socket, $client_message) = @_;

    # Current issue here is that the prints to prompt for further information are displaying
    # on the client and not the server

    $client_socket->send("$client_message\n");

    my $response;
    $client_socket->recv($response, 1024);
    chomp($response);
    if ($client_message eq "1")
    {
        $userlist = get_userlist();
        $response = "userlist";
    }
    elsif ($client_message eq "2")
    {
        $grouplist = get_grouplist();
        $response = "grouplist";
    }
    elsif ($client_message eq "3")
    {
        print "Enter the name of the group: ";
        my $group = <STDIN>;
        chomp($group);
        $response = "setgroup $group";
    }
    elsif ($client_message eq "4")
    {
        print "Enter the username: ";
        my $username = <STDIN>;
        chomp($username);
        print "Enter the password: ";
        my $password = <STDIN>;
        chomp($password);
        $response = "createuser $username $password";
        #create_user($client_socket, $username, $password);
    }
    else
    {
        $response = "Invalid command";
    }

    print "SERVER: Sending response to client: $response\n";
    $client_socket->recv($response, 1024);
}

# Sub to process the client choice and send it to the server
sub process_client_choice{

    my ($server_socket, $user_choice) = @_;
    $server_socket->send("$user_choice\n");

    my $response;
    $client_socket->recv($response, 1024);
    chomp($response);
    print "CLIENT: Server response: $response\n";

    # Prompt the user for additional input based on the response
    if ($response eq "3") {
        print "Enter the name of the group: ";
        my $group = <STDIN>;
        chomp($group);
        $client_socket->send("$group\n");
    } elsif ($response eq "4") {
        print "Enter the username: ";
        my $username = <STDIN>;
        chomp($username);
        print "Enter the password: ";
        my $password = <STDIN>;
        chomp($password);
        $client_socket->send("$username $password\n");
    }
     print_menu();

}


# Subroutine to get a list of users from ldap
sub get_userlist
{
    my $userlist;
    open(my $LDAPUSERS, `sudo slapcat |` ) or die "Couldn't Open the ldap database. $!\n"; 

        while (my $line = <$LDAPUSERS>)
        {
            chomp($line);
            # Use a regex to get the users from slapcat
            if ($line =~ /uid=([a-zA-Z0-9]+)/)
            {
                # Add the users to a cs list
                $userlist .= "$1,";
                print "$userlist";
            }
        }  
        # Get rid of the trailing comma
        # $userlist =~ s/,$//; 
        # Close the file handle
        close($LDAPUSERS);
        return $userlist;
}

# Subroutine to query ldap and get the groups 
sub get_grouplist
{
    my $grouplist;
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
        }
        # Get rid of the trailing comma
        $grouplist =~ s/,$//;
        close($LDAPGROUPS);
        return $grouplist;
}

sub set_group
{
    my ($client_socket, $group_name) = @_;
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

sub create_user
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
}
        
