#! usr/bin/perl -w

# This program is used to gather information from a GTF file.
# It can count the number of genes and exons, calculate the average exon length
# and find the gene with the most exons.

use strict;

# Import module for analysing GTF files.
use gtf_dcl10;

# Import module for setting up command line flags.
use Getopt::Std;

# Set up command line flags.
our ($opt_g, $opt_e, $opt_a, $opt_n, $opt_h);
getopts('geanh: ');

# Display program usage in a text editor.
if ($opt_h || @ARGV == 0 || @ARGV > 1) {system 'more guide.txt';}
# Store reference to file.
my $file = $ARGV[0];
# Make sure there is a file before using these functions.
if ($file) {
	# Count the number of genes.
	if ($opt_g) {gtf_dcl10::countgenes($file);}
	# Count the number of exons.
	if ($opt_e) {gtf_dcl10::countexons($file);}
	# Calculate the average exon length.
	if ($opt_a) {gtf_dcl10::AEL($file);}
	# Find the gene with the most exons.
	if ($opt_n) {gtf_dcl10::biggene($file);}
}
