#! usr/bin/perl -w
# GOdiffexp_dcl10.pl

# Extracts data from a file listing gene names and their descriptions and 
# a file containing RNASeq data on differential expression. The files are compared
# for matching gene names, descriptions and p-values from the RNASeq experiment.
# The results are combined into a .tsv file.

use strict;

# Get input from GO0003723.genelist.tsv.
my @GOInput;
# Get input from diffexp.tsv.
my @diffInput;
# Get hash, keys and values from GO0003723.genelist.tsv.
my %geneData;
my @geneKeys;
my @geneValues;
# Get hash, keys and values from diffexp.tsv.
my %diffExpData;
my @diffExpKeys;
my @diffExpValues;

# Open file streams.
# GOFILE and DEFILE are the input files.
# RESULTS is the output file.
open (GOFILE, "<GO0003723.genelist.tsv") or die ("Could not locate GO0003723.genelist.tsv");
open (DEFILE, "<diffexp.tsv") or die ("Could not locate diffexp.tsv");
open (RESULTS, ">results.tsv") or die ("Could not locate results.tsv");

# Extract data from GO0003723.genelist.tsv. 
# The foreach loop reads the file line-by-line and and splits into an array.
# The array is then searched by index [3] and [4], corresponding to
# columns 4 and 5 (gene name and description, respectively). 
# The gene name is saved as the KEY and the description as the VALUE.
# I downloaded it is a .tsv do make the columns show up nicer in Libre Office to count
# the column numbers more easily.
foreach (<GOFILE>) {
	@GOInput = split ("\t", $_);
	$geneData{$GOInput[3]} = $GOInput[4];
}
@geneKeys = keys %geneData;
@geneValues = values %geneData;

# Extract data from diffexp.tsv. 
# The foreach loop reads the file line-by-line and and splits into an array.
# The array is then searched by index [0] and [4], corresponding to
# columns 1 and 5 (gene name and p-value, respectively). 
# The gene name is saved as the KEY and the p-value as the VALUE.
foreach (<DEFILE>) {
	@diffInput = split ("\t", $_);
	$diffExpData{$diffInput[0]} = $diffInput[4];
}
@diffExpKeys = keys %diffExpData;
@diffExpValues = values %diffExpData;

# Print the results to a .tsv file.
# Foreach loop runs through the geneKeys array and if it is a key in the
# diffExpData hash, the gene name, description and p-value is printed to
# results.tsv.
print RESULTS "Gene name\tDescription\tp-value\n";
foreach (@geneKeys) {
	if (exists $diffExpData{$_}) {
		printf RESULTS ("%s\t%s\t%s", $_, $geneData{$_}, $diffExpData{$_});
	}
}

# Close the file streams.
close GOFILE;
close DEFILE;
close RESULTS;
