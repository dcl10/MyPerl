#! usr/bin/perl

use strict;
use warnings;

my ($input, @dna, %letters, @gc);

chomp($input = uc <STDIN>);
die "No sequence given!\n" if (length($input) <= 0 or $input !~ /^\S+/);

@dna = split("", $input);
foreach (@dna) {
	if ($_ =~ /([ATGC])/i) {$letters{$1}++;}
	else {$letters{'others'}++;}
	push @gc, $_ if ($_ =~ /[GC]/i);
}

if ($input =~ /(ta[ag])|(tga)/i) {print "Stop codon detected: $` ($&) $'\n";}
print "Sequence length: ".@dna."\n";
print "GC content: ".((@gc/@dna)*100)."%\n";
foreach (sort(keys(%letters))) {print "Number of $_: $letters{$_}\n";}
