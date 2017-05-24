#! usr/bin/perl

# This program is a pipeline for searching the SwissProt database with a protein
# sequence, finding the top 10 matches and performing a multiple sequence
# alignement on them before visualising them in ClustalX

use strict;
use warnings FATAL => 'all';

# Modules to be used in this script
use Bio::Tools::Run::StandAloneBlastPlus;
use Bio::DB::Fasta;
use Bio::Tools::Run::Alignment::Muscle;
use Bio::SearchIO;

# Variables to be used in this script
my ($query, $database) = @ARGV;
my ($parsed, $sequences) = ('hits.txt', 'hits.fasta');

# Enforce correct usage
die ("Usage: perl bioperl_dcl10.pl [FASTA file] [Database]") if (@ARGV != 2);
die ("\"$query\" not found. Please input a valid FASTA file.") unless (-e $query);
die ("Database file (\"$database\") not found.") unless (-e "$database");
die ("The query is larger than the database! Did you put the arguments in order?") if (-s $query >= -s $database);

# Implement subroutines for checking database formatting
my $format = &getDBFormat($database);
my $dbname = &getDBName($database);

# Set up a SwissProt database if one is not present/configured
# And set up the BLAST search
my $blast;
unless (-e $format) {
	print "Formatting database\n";
	$blast = Bio::Tools::Run::StandAloneBlastPlus->new(
		-db_name => "$dbname",
		-db_data => "$database",
		-create => 1);
}
# Otherwise set up the BLAST search
else { 
	$blast = Bio::Tools::Run::StandAloneBlastPlus->new(-db_name => $dbname);
}

# Run the BLAST search against the SwissProt database
# Save the results to 'query.bls'
my $result = $blast->blastp( 
	-query => $query,
	-outfile => 'query.bls');

# Create SearchIO object to parse 'query.bls'
print "Running BLAST search against SwissProt with query \"$query\"\n";
my $searchio = Bio::SearchIO -> new(
	-format => 'blast',
	-file => 'query.bls');

# Parse Sequence name, length, E-value, bit score & percent identity
# from BLAST search results. Only retrieves the first 10.
print "Parsing top 10 BLAST results\n";
open (OUT, ">$parsed") or die ("Cannot open $parsed\n");
my $count = 0;
# For collecting the sequnece IDs to get their sequences below
my @seqid = ();
while ($result = $searchio -> next_result) {
	print OUT "Query: ".$result -> query_name."\n";
	print OUT "Length: ".$result -> query_length."\n\n";
	if ($result -> num_hits == 0){print OUT "Not hits found.\n";}
	else {
		while (my $hit = $result -> next_hit) {
			# Get the names of the hit sequences
			push @seqid, $hit -> name;
			print OUT "Sequence name: ".$hit -> name."\n";
			# Get the lengths of the hit sequences
			print OUT "Sequence length: ".$hit -> length."\n";
			# Get the E-values of the hit sequences
			print OUT "E-value: ".$hit -> significance."\n";
			# Get the bit score of the hit sequences
			print OUT "Score: ".$hit -> bits."\n";
			while (my $hsp = $hit -> next_hsp) {
				# Get the percent identity between query and hit
				printf OUT ("%s%1d\n\n", "Percent identity: ", ($hsp -> frac_identical * 100));
			}
			$count++;
			# Cut out after the first 10 hits are parsed
			last if ($count == 10);
		}
	}
}
close OUT;

# Retrieve the sequences for the top 10 BLAST hits
# and print them to 'hits.fasta' with their indentifiers
print "Preparing multiple sequence alignment\n";
open(OUT, ">$sequences") or die ("Could not write to multiFASTA file $sequences\n");
my $db = Bio::DB::Fasta -> new($database);
foreach (@seqid) {
    # Addition of ">" necessary for the MUSCLE to work
    print OUT ">".$_."\n".$db -> seq($_)."\n";
}
close OUT;

# Run multiple sequence alignment in MUSCLE
# Saves output to 'hits.aln'
# System call to visualise alignment in ClustalX
print "Running multiple sequence alignment in MUSCLE\n";
my $factory = Bio::Tools::Run::Alignment::Muscle->new(-outfile_name => 'hits.aln');
my $aln = $factory -> align($sequences);
system "clustalx hits.aln &";

# Subroutines to assist checking if the database is formatted and gets the name of the 
# database. This means if the user has a pre-existing formatted database, time won't be wasted
# re-formatting the database
sub getDBFormat {
	my $toChange = $_[0];
	$toChange =~ s/.fasta/.phr/;
	return $toChange;
}
sub getDBName {
	my $name = $_[0];
	$name =~ s/.fasta//;
	return $name;
}
