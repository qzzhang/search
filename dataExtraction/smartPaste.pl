#!/usr/bin/perl                                                                 

use strict;
use warnings;

my @mt_vals = ();
my $mt_vals_str = '';

my %new_field = ();
# hack to handle initial line of files
# may not work with tacking on domains
$new_field{'fid'} = 'external_id';
my @new_field_names=qw/
external_id
/;

# not sure how to handle this situation
# need a switch to decide how many columns are being pasted on
# if pasting multiple columns, need fid column to be unique in
# the stdin file
@new_field_names=qw/
domain_id
domain_desc
/;

# needs the file extension on argv[1]
my $extension=shift @ARGV;

#open (FILE, $ARGV[1]);
# mapping input comes in on stdin
my $i;
while (<STDIN>) {
	++$i;
	warn $i . ': ' . $_ unless $i%100000;
    chomp;
    next if (/^\s*$/);
    my ($id, @vals) = split (/\t/, $_);

    if (! @mt_vals) {
        for ($i=0; $i <= $#vals; ++$i) {
            $mt_vals[$i] = '';
        }
        $mt_vals_str = join ("\t", @mt_vals);
    }

    # this won't work if there are multiple rows per fid
    # how to handle?
    # yuck, but shouldn't matter for solr
    if ((scalar @new_field_names) == 1)
    {
    	$new_field{$id} .= join (' ', ' ', @vals);
    } else {
    	$new_field{$id} = join ("\t", @vals);
    }

#    if (defined $new_field{$id}) {
#        $new_field{$id} .= " ". (join "\t",@vals);
#    } else {
#        $new_field{$id} = join "\t",@vals;
#    }
}

foreach my $filename (@ARGV)
{
	open (INPUT, $filename) or die "couldn't open $filename: $!";
	open (OUTPUT, '>', "$filename.$extension") or die "couldn't open $filename.$extension: $!";
	while (<INPUT>) {
	    chomp;
	    next if (/^\s*$/);
	    my ($id) = split (/\t/, $_);

    if ($new_field{$id}) {
        print OUTPUT join ("\t", $_, $new_field{$id})."\n";
    } else {
        print OUTPUT join ("\t", $_, $mt_vals_str)."\n";
    }
	}
	close (INPUT);
	close (OUTPUT);
}


