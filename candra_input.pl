use strict;
use warnings;

my ($input_dir,$output_dir) = @ARGV;

my $file='corrected_recurrent_database_annotation.maf';
my $file1='candra_input';

open(INFO,"$input_dir$file")||die "Can not open INFO.\n";
open(INFO1,">"."$output_dir$file1")||die "Can not open INFO1.\n";

my @arr;

foreach my $line (<INFO>) {
	chomp($line);
	if ($line =~ /^#/) {
        }
        else {
	@arr=split("\t",$line);
	
	
        if ( $arr[0] ne "Hugo_Symbol" && $arr[8] ne "3'UTR" && $arr[8] ne "5'UTR" && $arr[8] ne "IGR" && $arr[8] ne "Intron" && $arr[8] ne "lincRNA" && $arr[8] ne "RNA") {
          print INFO1 $arr[4],"\t",$arr[5],"\t",$arr[11],"\t",$arr[12],"\t",$arr[36],"\n";
	}
        }
}

close(INFO);
close(INFO1);


