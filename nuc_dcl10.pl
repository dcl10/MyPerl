#! usr/bin/perl -w
# nuc_dcl10.pl

# Takes a DNA sequence from user's terminal input and counts the number of each codon,
# the proportion each nucleotide forms of the sequence as a percentage of the input sequence
# and outputs a polyadenylated version of the sequence.

use strict;

# Prompt the user for a DNA sequence.
print "Please enter a DNA sequence to analyse.\nDo not separate the values in any way.\n";

# Get a sequence from the user's command line input.
chomp(my $inputSeq = <STDIN>);

# Declare variables for analysis.
my @inputSeqArray = split("", $inputSeq);
my $numberOfA = 0;
my $numberOfT = 0;
my $numberOfG = 0;
my $numberOfC = 0;
my $numberOfOther = 0;
my $sequenceLength = @inputSeqArray;

# Check the sequence for putative stop codons.
# Does not take into account of the reading frame.
if ($inputSeq =~ m/tag/i || $inputSeq =~ m/taa/i || $inputSeq =~ m/tga/i) {
	print "STOP codon detected.\n";
} else { print "No STOP codon detected.\n";
}

# Count the number of each nucleotide.
foreach (@inputSeqArray) {
	if ($_ =~ m/a/i) {
		$numberOfA++;
	} elsif ($_ =~ m/t/i) {
		$numberOfT++;
	} elsif ($_ =~ m/g/i) {
		$numberOfG++; 
	} elsif ($_ =~ m/c/i) {
		$numberOfC++; 
	} elsif ($_ !~ m/[atgc]/i) {
		$numberOfOther++; 
	}
}

# Print the number of nucleotides and their percentages.
print "Sequence length: $sequenceLength\n";
printf("A:\t%i\t%2.2f%s", $numberOfA, 100*$numberOfA/$sequenceLength, "% of input sequence\n");
printf("T:\t%i\t%2.2f%s", $numberOfT, 100*$numberOfT/$sequenceLength, "% of input sequence\n");
printf("G:\t%i\t%2.2f%s", $numberOfG, 100*$numberOfG/$sequenceLength, "% of input sequence\n");	
printf("C:\t%i\t%2.2f%s", $numberOfC, 100*$numberOfC/$sequenceLength, "% of input sequence\n");	
printf("Other:\t%i\t%2.2f%s", $numberOfOther, 100*$numberOfOther/$sequenceLength, "% of input sequence\n");

# Analyse GC-content.
printf("GC-content:\t%2.2f%s", 100*($numberOfG+$numberOfC)/$sequenceLength, "%\n");

# Polyadenlyate the sequence.
# Forces uppercase output of $inputSeq.
print "Polyadenylated sequence:\n", join ("", uc $inputSeq, "AAAAAAAAAAAA"), "\n";
