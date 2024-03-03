use strict;
use warnings;

my ($input_dir,$output_dir) = @ARGV;

my $file='merged_new';
my $file1='genewise_heatmap';

open(INFO,"$input_dir$file")||die "Can not open INFO.\n";
open(INFO1,">"."$input_dir$file1")||die "Can not open INFO1.\n";

sub uniq {
	my %seen;
	grep !$seen{$_}++,@_;
}

my @arr;
my @unique;
my %dict;
my @file_name;
my %dict1;

foreach my $line (<INFO>) {
	chomp($line);
	@arr=split("\t",$line);
	if ( $arr[0] eq "Chromosome_Start_position_Tumor_Seq_Allele1_Tumor_Seq_Allele2") {
		next;
	}
	else {
		@file_name=split(",",$arr[9]);
		for (my $i=0;$i < $#file_name+1; $i++) {
			push(@unique,($file_name[$i]));
		}
		foreach my $value (@file_name) {
			push @{$dict{$arr[1]}},$value;
		}
	}
}

#for my $value (keys %dict) {
#	print $value,"\t",join(',',@{$dict{$value}}),"\n";
#}


my @filtered=uniq(@unique);

print INFO1 " ","\t";

for (my $j=0;$j < $#filtered+1;$j++){
	print INFO1 $filtered[$j],"\t";
}

print INFO1 "\n";

seek INFO,0,0;

my @arr1;
my @file_name1;


for my $value (keys %dict) {
	print INFO1 $value,"\t";
	for(my $k=0; $k < $#filtered+1 ; $k++){
		if ( grep {$_ eq $filtered[$k]} @{$dict{$value}}) {
			print INFO1 "1","\t";
		}
		else {
			print INFO1 "0","\t";
		}
	}
	print INFO1 "\n";
}
	
close(INFO);
close(INFO1);

