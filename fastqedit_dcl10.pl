#1 usr/bin/perl -w

# This program parses sequence data from FASTQ files and saves them as
# as FASTA file. It also saves the information to a DBM database.
# Optionally, the user can supply a sequence identifier to query the database.

use strict;

# Enforce proper usage of the program. Exits if @ARGV is 0 or greater than 1. 
if (@ARGV == 0 || @ARGV > 1 ) {
	print "Usage: perl fastqedit_dcl10.pl <FASTQ file>\nOptional: perl fastqedit_dcl10.pl <gene entry>\n";
	exit;
}

# Creates the directory to store the output of the program unless it already exists.
unless (-e "./dcl10_sequences") {system 'mkdir dcl10_sequences';}

# Variables to be used in the program.
my $fastq = "";
my $fasta = "";
my $logfile = "dcl10_sequences/log.txt";
my $entry = "";
my $flag = 0;
my $id = "";
my $count = 0;
my %DATA = ();

# Determines if the user wants to edit a FASTQ file or lookup a gene in the database.
if ($ARGV[0] =~ /.fq/) {
	$fastq = $ARGV[0];
	print "$fastq\n";
	$fasta = &newfile($ARGV[0]);
	&fastqedit;
} else {
	$entry = $ARGV[0];
	&lookup;
}

# Iterates through the FASTQ file and retrieves the sequence data. Operations are
# printed to the terminal and to the log file.
# The subroutine checks if a database already exists and gives the user the option
# add to the database or not.
sub fastqedit {
	open (FQFILE, "$fastq") or die ("$fastq not found, enter a valid FASTQ file\n");
	open (FAFILE, ">$fasta") or die ("Failed to create $fasta\n");
	open (LOG, ">$logfile") or die ("Could not create $logfile\n");
	while (<FQFILE>) {
		if ($_ =~ /^\@(\S{1,15})\n$/) {
			$count++;
			$flag = 1;
			$_ =~ s/\@/>/;
			print FAFILE ($_);
			chomp; $id = $_;
		} elsif ($_ =~ /^\+\n/) {
			$flag = 0;
			print "Added $id to $fasta\n";
			print LOG ("Added $id to $fasta\n");
		} else {
			if ($flag == 1) {print FAFILE ($_);}
		}
	}
	&check;	
	close FQFILE; close FAFILE; close LOG;
	print "Please consult the log file ($logfile) for full details\n";
}

# Checks to see if the database already exists and asks the user if they wish to
# append data to it.
# If the database does not already exist, one if automatically created.
sub check{
	if (-e "./dcl10_sequences/FASTAseqs.dir") {
		print "The database may already exists. Add to the database? (Y/N)\n";
		my $approve = <STDIN>;
		if ($approve =~ /Y/i) {&editdb;}
		else { dbmopen (%DATA, "dcl10_sequences/FASTAseqs", 0644) or die ("Cannot create database\n");}
	} else {&editdb;}
}

# Subroutine for looking up a gene in the database.
sub lookup{
	if ($entry) {
		dbmopen (%DATA, "dcl10_sequences/FASTAseqs", 0644);
		open (LOG, ">$logfile") or die ("Could not create $logfile\n");
		print "$entry:\n$DATA{$entry}";
		print LOG ("$entry:\n$DATA{$entry}");
		close LOG; close %DATA;
		print "Please consult the log file ($logfile) for full details\n";
	}
}

# Subroutine for making the FASTA with the same name as the FASTQ file.
sub newfile {
	$_[0] =~ s/.fq/.fa/;
	return "dcl10_sequences/$_[0]";
}

# Subroutine for storing the sequence data in a DBM database.
# Only called if the user wants add to it or the database does not already
# exist.
sub editdb {
	dbmopen (%DATA, "dcl10_sequences/FASTAseqs", 0644) or die ("Cannot create database\n");
	open (FAFILE, "<$fasta") or die ("Failed to create $fasta\n");
	while (<FAFILE>) {
		if ($_ =~ /^\>(\S+)\n/) {chomp; $id = $1;} 
		else {$DATA{$id} .= $_;}
	}
	close %DATA; close FAFILE;
}
