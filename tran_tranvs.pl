use strict;
use warnings;

my ($input_dir,$file1) = @ARGV;

opendir(DIR,"$input_dir") or die "could not open directory";


opendir DIR,"$input_dir";

opendir(DIR,"$input_dir") or die "can't opendir $input_dir";
open(INFO1,">"."$file1")||die "Can not open INFO1.\n";

print INFO1 "File_Name","\t","C>A","\t","C>G","\t","C>T","\t","T>A","\t","T>C","\t","T>G","\t","G>C","\t","G>T","\t","A>G","\t","A>C","\t","A>T","\t","G>A","\n";

my @docs=grep(/\.txt$/,readdir(DIR));
foreach my $file (@docs) {
	open(RES,"$input_dir$file") or die "Could not open $file\n";
    my @arr=0;
    my $CA=0;
		my $CG=0;
		my $CT=0;
		my $TA=0;
		my $TC=0;
		my $TG=0;
		my $GC=0;
		my $GT=0;
  	my $AG=0;
		my $AC=0;
		my $AT=0;
		my $GA=0;
foreach my $line(<RES>) {
		chomp($line);
    @arr=split("\t",$line);
    
    if ( $arr[8] ne "3'UTR" && $arr[8] ne "5'UTR" && $arr[8] ne "IGR" && $arr[8] ne "Intron" && $arr[8] ne "lincRNA" && $arr[8] ne "RNA" && $arr[8] ne "5'Flank") {
          if ( $arr[11] eq "C" && $arr[12] eq "A"){
						   $CA++;
          }
					if ( $arr[11] eq "C" && $arr[12] eq "G"){
						   $CG++;
          }
					if ( $arr[11] eq "C" && $arr[12] eq "T"){
						   $CT++;
          }
					if ( $arr[11] eq "T" && $arr[12] eq "A"){
						   $TA++;
          }
					if ( $arr[11] eq "T" && $arr[12] eq "C"){
	             $TC++;     
          }
          if ( $arr[11] eq "T" && $arr[12] eq "G"){
						   $TG++;
          }
					if ( $arr[11] eq "G" && $arr[12] eq "C"){
               $GC++;
          }
          if ( $arr[11] eq "G" && $arr[12] eq "T"){
               $GT++;
          }
          if ( $arr[11] eq "A" && $arr[12] eq "G"){
               $AG++;
          }
          if ( $arr[11] eq "A" && $arr[12] eq "C"){
               $AC++;
          }
          if ( $arr[11] eq "A" && $arr[12] eq "T"){
               $AT++;
          }
          if ( $arr[11] eq "G" && $arr[12] eq "A"){
               $GA++;
          }
    }
  }
  print INFO1 $file,"\t",$CA,"\t",$CG,"\t",$CT,"\t",$TA,"\t",$TC,"\t",$TG,"\t",$GC,"\t",$GT,"\t",$AG,"\t",$AC,"\t",$AT,"\t",$GA,"\n";
}
