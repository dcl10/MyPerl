#! usr/bin/perl -w

# This module is used to gather information from a GTF file.
# It can count the number of genes and exons, calculate the average exon length
# and find the gene with the most exons.

package gtf_dcl10;

use strict;

# Count the number of genes.
# Counts how often "gene_name" appears next to a UNIQUE gene name.
sub countgenes {
	my $file = $_[0];
	my $count = 0;
	my $gene = "";
	my %uniqgene = ();
	open (FILE, $file) or die ("Could not open $file\n");
	while (<FILE>) {
		if ($_ =~ /gene_id\s\"(\S+)\"\;/) {$gene = $1;}
		unless ($uniqgene{$gene}) {
			$uniqgene{$gene} = 1;
			$count ++;
		}
	}
	print "There are $count genes in $file\n";
	close FILE;
}

# Count the number of exons.
# Simply count how often "exon" appears in the file.
sub countexons {
	my $file = $_[0];
	my $count = 0;
	open (FILE, $file) or die ("Could not open $file\n");
	while (<FILE>) {
		if ($_ =~ /exon/) {$count ++;}
	}
	print "There are $count exons in $file\n";
	close FILE;
}

# Calculate the average exon length.
# Captures the start and finish position of each exon, subtracts the finish
# from the start and adds the result to $length. $length is divided by the 
# number of exons to get the average length.
sub AEL {
	my $file = $_[0];
	my $length = 0;
	my $count = 0;
	open (FILE, $file) or die ("Could not open $file\n");
	while (<FILE>) {
		if ($_ =~ /exon\s+(\d+)\s+(\d+)/) {
			$length += ($2 - $1);
			$count ++;
		}
	}
	printf ("%s %i\n", "The average exon length is", ($length/$count));
	close FILE;
}

# Find the gene with the most exons.
# First selects the exons. Identifies the individual genes they are in and counts up.
# If the gene is different, the previous gene name is stored along with the number of 
# exons IF the number of exons in the new gene is greater than that of the old gene.
sub biggene {
	my $file = $_[0];
	my $count = 0;
	my $max = 0;
	my $gene = "";
	my $biggene = "";
	open (FILE, $file) or die ("Could not open $file\n");
	while (<FILE>) {
		if ($_ =~ /exon/) {
			$count++;
			if ($_ !~ /$gene/) {
				if ($count > $max) {
					$max = $count;
					$biggene = $gene;
				}
				$count = 0;
			}
			if ($_ =~ /gene_name\s\"(\S+)\"\;/) {$gene = $1;}
		}
	}
	print "The largest gene is $biggene with $max exons in $file\n";
	close FILE;
}
	
1;
