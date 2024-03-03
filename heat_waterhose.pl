use strict;
use warnings;


my ($input_dir,$output_dir) = @ARGV;

my $file='merged_new';
my $file1='mutaionwise_heatmap';

open(INFO,"$input_dir$file")||die "Can not open INFO.\n";
open(INFO1,">"."$input_dir$file1")||die "Can not open INFO1.\n";

sub uniq {
	my %seen;
	grep !$seen{$_}++,@_;
}

my @arr;
my @file_name;
my @unique;

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
	}
}

my @filtered= uniq(@unique);	

#for (my $j=0;$j < $#filtered+1; $j++) {
#	print $filtered[$j],"\t";
#}

print INFO1 "key","\t","Hugo_Symbol","\t","Chromosome","\t","Start_position","\t","Variant_Classification","\t","Variant_Type","\t","Tumor_Seq_Allele1","\t","Tumor_Seq_Allele2","\t","Protein_Change","\t","Source","\t","Cosmic","\t","dbSNP","\t","TMC_SNPdb","\t","Prediction","\t";

										
#print INFO1 " ","\t";
for(my $j=0;$j < $#filtered+1; $j++){
        print INFO1 $filtered[$j],"\t";
}

seek INFO,0,0;

print INFO1 "\n";

my @arr1;
my @file_name1;

foreach my $line1 (<INFO>) {
        chomp($line1);
        @arr1=split("\t",$line1);
        if ($arr1[0] eq "Chromosome_Start_position_Tumor_Seq_Allele1_Tumor_Seq_Allele2"){
                next;
        }
        else {
		#print INFO1 $arr1[11],"\t";
                print INFO1 $arr1[0],"\t",$arr1[1],"\t",$arr1[2],"\t",$arr1[3],"\t",$arr1[4],"\t",$arr1[5],"\t",$arr1[6],"\t",$arr1[7],"\t",$arr1[8],"\t",$arr1[9],"\t",$arr1[10],"\t",$arr1[11],"\t",$arr1[12],"\t",$arr1[13],"\t";

		#print $arr1[11],"\n";
                @file_name1=split(",",$arr1[9]);
	 	#print $file_name1[0],"\n";
	 	#print $#filtered,"\n";
                for(my $k=0;$k < $#filtered+1 ;$k++){
                        if ( grep {$_ eq $filtered[$k]} @file_name1 ){
                                print INFO1 "1","\t";
                        }
                        else {
                                print INFO1 "0","\t";
                        }

                }
        }
        print INFO1 "\n";
    }

