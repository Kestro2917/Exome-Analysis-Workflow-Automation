use strict;
use warnings;
use List::Util qw(first);

my ($input_dir,$output_dir) = @ARGV;

my $file='corrected_recurrent_database_annotation.maf';
my $file1='simple_maf';

open(INFO,"$input_dir$file")||die "Can not open INFO.\n";
open(INFO1,">"."$output_dir$file1")||die "Can not open INFO1.\n";

my @arr;

foreach my $line (<INFO>) {
	chomp($line);
	if($line=~ /^#/){
	}
	else{
		@arr=split("\t",$line);
		last;
	}
}

my @header;

@header=('Hugo_Symbol','Chromosome','Start_position','Variant_Classification','Variant_Type','Tumor_Seq_Allele1','Tumor_Seq_Allele2','Protein_Change','Source','Cosmic','dbSNP','MyLabDB');

my @index;
for(my $i=0,my $j=0;$i<$#header+1;$i++,$j++){
	$index[$j]=first {$arr[$_] eq $header[$i]} 0..$#arr;
}

my @new_index;
for (my $z=0,my $k=0;$z<$#index+1;$z++,$k++){
	$new_index[$k]=$index[$z];
}

seek INFO,0,0;

my @arr1;

foreach my $line1 (<INFO>) {
	chomp($line1);
	if ($line1 =~ /^#/) {
        }
        else {
	@arr1=split("\t",$line1);

	
        if ( $arr1[$new_index[3]] ne "3'UTR" && $arr1[$new_index[3]] ne "5'UTR" && $arr1[$new_index[3]] ne "IGR" && $arr1[$new_index[3]] ne "Intron" && $arr1[$new_index[3]] ne "lincRNA" && $arr1[$new_index[3]] ne "RNA" && $arr1[$new_index[3]] ne "5'Flank") {
          print INFO1 $arr1[$new_index[1]],"_",$arr1[$new_index[2]],"_",$arr1[$new_index[5]],"_",$arr1[$new_index[6]],"\t",$arr1[$new_index[0]],"\t",$arr1[$new_index[1]],"\t",$arr1[$new_index[2]],"\t",$arr1[$new_index[3]],"\t",$arr1[$new_index[4]],"\t",$arr1[$new_index[5]],"\t",$arr1[$new_index[6]],"\t",$arr1[$new_index[7]],"\t",$arr1[$new_index[8]],"\t",$arr1[$new_index[9]],"\t",$arr1[$new_index[10]],"\t",$arr1[$new_index[11]],"\n";
	}
        }
}

close(INFO);
close(INFO1);



