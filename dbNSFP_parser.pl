use strict;
use warnings;
use List::Util qw(sum);

my ($input_dir,$output_dir) = @ARGV;

my $file='dbNSFP_output'; 
my $file1='dbNSFP_prediction_score';
my $file2='prediction_score_specific';

open(INFO,"$input_dir$file")||die "Can not open INFO.\n";
open(INFO1,">"."$input_dir$file1")||die "Can not open INFO1.\n";
open(INFO2,">"."$input_dir$file2")||die "Can not open INFO1.\n";

my @val;
my @arr;

foreach my $line (<INFO>) {
      chomp($line);
      if($line=~ /^#/){
      }
      else
      {
      @arr=split("\t",$line);
 
      if (index($arr[25], "D") != -1) {
          $val[0]=1;
      }
      else{
          $val[0]=0;
      }
      if ((index($arr[28], "D") != -1) or (index($arr[28], "P") != -1)){
          $val[1]=1;
      }
      else{
          $val[1]=0;
      }
      if ((index($arr[31], "D") != -1) or (index($arr[31], "P") != -1)){
          $val[2]=1;
      }
      else{
          $val[2]=0;
      }
      if (index($arr[34], "D") != -1){
          $val[3]=1;
      }
      else{
          $val[3]=0;
      }
      if ((index($arr[37], "A") != -1) or (index($arr[37], "D") != -1)){
	  $val[4]=1;
      }
      else{
          $val[4]=0;
      }
      if ((index($arr[40], "H") != -1) or (index($arr[40], "M") != -1)){
          $val[5]=1;
      }
      else{
          $val[5]=0
      }      
      if (index($arr[43], "D") != -1) {
          $val[6]=1;
      }
      else{
          $val[6]=0;
      }
      print INFO1 $arr[0],"\t",$arr[1],"\t",$arr[2],"\t",$arr[3],"\t",$arr[4],"\t",$arr[5],"\t",$arr[6],"\t",$arr[23],"\t",$arr[25],"\t",$val[0],"\t",$arr[26],"\t",$arr[28],"\t",$val[1],"\t",$arr[29],"\t",$arr[31],"\t",$val[2],"\t",$arr[32],"\t",$arr[34],"\t",$val[3],"\t",$arr[35],"\t",$arr[37],"\t",$val[4],"\t",$arr[38],"\t",$arr[40],"\t",$val[5],"\t",$arr[41],"\t",$arr[43],"\t",$val[6],"\t",sum(0,@val),"\n"; 
      print INFO2 $arr[0],"_",$arr[1],"_",$arr[2],"_",$arr[3],"\t",sum(0,@val),"\n";     
      }
      }
close(INFO);
close(INFO1);
close(INFO2);

