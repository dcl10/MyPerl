#! usr/bin/perl

use strict;
use warnings;

my (@input, %geneData, %diffExpData);

open (GOFILE, "<GO0003723.genelist.tsv") or die ("Could not locate GO0003723.genelist.tsv");
open (DEFILE, "<diffexp.tsv") or die ("Could not locate diffexp.tsv");
open (RESULTS, ">results.tsv") or die ("Could not locate results.tsv");

foreach (<GOFILE>) {
	@input = split ("\t", $_);
	$geneData{$input[3]} = $input[4];
}

foreach (<DEFILE>) {
	@input = split ("\t", $_);
	$diffExpData{$input[0]} = $input[4];
}

print RESULTS "Gene name\tDescription\tp-value\n";
foreach (sort(keys(%geneData))) {
	if (exists $diffExpData{$_}) {printf RESULTS ("%s\t%s\t%s", $_, $geneData{$_}, $diffExpData{$_});}
}

close GOFILE; close DEFILE; close RESULTS;
