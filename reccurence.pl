use strict;


my ($input_dir,$output_dir) = @ARGV;

opendir(DIR,"$input_dir") or die "could not open directory";


opendir DIR,"$input_dir";

my $file = "recurrent_information";
open F3,">$input_dir$file";

my @files = grep(/\.txt/,readdir(DIR));
my %hash1=();
map{
my $code=$_;
open F1,"$input_dir$code";
my @arr=<F1>; close(F1);
foreach my $line(@arr){
        chomp($line);
        my @array=split("\t",$line);
        push(@{$hash1{$array[0]}},$array[1]);
          }
}@files;

foreach(keys(%hash1)){
                      local $"=",";
      print F3 "$_\t@{$hash1{$_}}\n";
}
