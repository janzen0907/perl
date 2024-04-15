#!/usr/bin/perl
#
# A perl reference is a scalar data type that holds the location of another
# value - which could be a scalar, an arrray, or a hash. So a reference can be used
# anywhere a scalar can be used
#
# You can construct lists containing references to other lists, which could 
# contain references to hashes, which could contain references to other hashes.
# etc. This is how in perl you can build complex nested data structures.

use strict;
use warnings;
use Data::Dumper;

# create a reference with a backslash
my $foo = "Bar";
my $fooref = \$foo; 

print "foo contains $foo and Fooref contains $fooref\n";

# You can dereference with whatever symbol is appropriate to what
# the reference points at - if it points at a scalar, use 
# a $, if it points at a list use @, if it points at a hash, use %
print "fooref points at location $fooref which contains the value $$fooref\n";
# Still points to the same location in memory, but will contain the new value. Not copying, just a reference. 
$foo = "fee";
print "foo is $foo and fooref points at location $fooref which contains the value $$fooref\n";

# You can also create references to arrays
my @array = (1,2,3,4,5);
my $arrayref = \@array;
print "array is @array and array ref is @$arrayref which is at location $arrayref\n";

# You can also create a reference to an anonymous array using square brackets:
my $anonarrayref = ['a', 'b', 'c', 'd'];
print "anonarrayref is $anonarrayref, and it dereferences to @$anonarrayref\n";

# hashes can be created a value at a time or via a list of key-value pairs
# Key Value pairs
my %hash = ('Do', 'Rae', 'Fee', 'Fi');
$hash{'Fo'} = 'fum';
print  Dumper \%hash;

my $hashref = \%hash;
print Dumper $hashref;

# Just like with arrays, we can declare an anonymous hash using curly braces
my $anonhashref = {
    'Fred' => 'Flinstone',
    'Barney' => 'Ruble'
};

print Dumper $anonhashref;

# You can also declare references to functions if you want to pass functions
# around - for callbacks or whatever

sub HiThere{
    print "Hi There!\n";
}

sub RunSub {
    my $passed_function = @_[0];
    &$passed_function;
}

# Passing a reference from the HiThere Function
my $function = \&HiThere;
# Dereference it and run it
&$function;

RunSub($function);

# If you get confused on wheter soemthing is a scalar, a ref, or whatever? use the ref function
# Will return nothing if it is not a REF, returns what it is a reference too if it is a reference
print "Refs:\n";
print ref $anonarrayref;
print "\n";
print ref @array;
print "\n";
print ref $arrayref;
print "\n";
print ref $function;
print "\n";