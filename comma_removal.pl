use strict;
use warnings;

my ($input_dir,$output_dir) = @ARGV;

opendir(DIR,"$input_dir") or die "could not open directory";

my @files = grep(/\.vcf$/,readdir(DIR));

foreach my $file (@files){
   open RES,"$input_dir$file" or die "could not open $file \n";
   open RES1,">$output_dir$file";
   my @slot=<RES>;
   foreach my $line(@slot){
   	chomp($line);
	  if($line=~/\#/g){
		 print RES1 $line,"\n";
	 }
  	else
	 {
		my @arr=split("\t",$line);
		if($arr[4]=~/,/g){
			my @alt=split(",",$arr[4]);
			for(my $i=0;$i<$#alt+1;$i++){
				my @cov=split(":",$arr[9]);
				my @alt_depth=split(",",$cov[1]);
				my $j=$i+1;
				my $str=$cov[0]."\:".$alt_depth[0].",".$alt_depth[$j]."\:".$cov[2]."\:".$cov[3]."\:".$cov[4];
				print RES1 $arr[0]."\t".$arr[1]."\t".$arr[2]."\t".$arr[3]."\t".$alt[$i]."\t".$arr[5]."\t".$arr[6]."\t".$arr[7]."\t".$arr[8]."\t".$str,"\n";
			}
		}else{
			print RES1 $line,"\n";
		}
	}
 }
}

