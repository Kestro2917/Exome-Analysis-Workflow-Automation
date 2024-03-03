use strict;
use warnings;

use strict;


my ($input_dir,$file1) = @ARGV;

opendir(DIR,"$input_dir") or die "could not open directory";


opendir DIR,"$input_dir";

opendir(DIR,"$input_dir") or die "can't opendir $input_dir";
open(INFO1,">"."$file1")||die "Can not open INFO1.\n";

print INFO1 "File_Name","\t","3'UTR","\t","5'Flank","\t","5'UTR","\t","IGR","\t","Intron","\t","De_novo_Start_InFrame","\t","De_novo_Start_OutOfFrame","\t","Frame_Shift_Del","\t","Frame_Shift_Ins","\t","In_Frame_Del","\t","In_Frame_Ins","\t","lincRNA","\t","RNA","\t","Start_Codon_Del","\t","Start_Codon_Ins","\t","Start_Codon_SNP","\t","Stop_Codon_Del","\t","Stop_Codon_Ins","\t","Missense_Mutation","\t","Nonsense_Mutation","\t","Nonstop_Mutation","\t","Silent","\t","Splice_Site","\n";


my @docs=grep(/\.txt$/,readdir(DIR));
foreach my $file (@docs) {
	open(RES,"$input_dir$file") or die "Could not open $file\n";
      my @arr=0;
      my $missense=0; 
      my $nonsense=0; 
      my $nonstop=0; 
      my $splice=0; 
      my $threeutr=0; 
      my $fiveflank=0; 
      my $fiveutr=0; 
      my $igr=0; 
      my $intron=0; 
      my $silent=0; 
      my $DenovoStartInFrame=0; 
      my $DenovoStartOutOfFrame=0; 
      my $FrameShiftDel=0; 
      my $FrameShiftIns=0; 
      my $InFrameDel=0; 
      my $InFrameIns=0; 
      my $lincRNA=0; 
      my $RNA=0; 
      my $StartCodonDel=0; 
      my $StartCodonIns=0; 
      my $StartCodonSNP=0; 
      my $StopCodonDel=0; 
      my $StopCodonIns=0;
foreach my $line(<RES>) {
		chomp($line);
    @arr=split("\t",$line);      
      if($arr[8] eq "3'UTR") {
        $threeutr++;
      }
      if($arr[8] eq "5'Flank") {
        $fiveflank++;
      }
      if($arr[8] eq "5'UTR") {
        $fiveutr++;
      }
      if($arr[8] eq "IGR") {
        $igr++;
      }
      if($arr[8] eq "Intron") {
        $intron++;
      }
      if($arr[8] eq "De_novo_Start_InFrame") {
        $DenovoStartInFrame++;
      }
      if($arr[8] eq "De_novo_Start_OutOfFrame") {
        $DenovoStartOutOfFrame++;
      }
      if($arr[8] eq "Frame_Shift_Del") {
        $FrameShiftDel++;
      }
      if($arr[8] eq "Frame_Shift_Ins") {
        $FrameShiftIns++;
      }
      if($arr[8] eq "In_Frame_Del") {
        $InFrameDel++;
      }
      if($arr[8] eq "In_Frame_Ins") {
        $InFrameIns++;
      }
      if($arr[8] eq "lincRNA") {
        $lincRNA++;
      }
      if($arr[8] eq "RNA") {
        $RNA++;
      }
      if($arr[8] eq "Start_Codon_Del") {
        $StartCodonDel++;
      }
      if($arr[8] eq "Start_Codon_Ins") {
        $StartCodonIns++;
      }
      if($arr[8] eq "Start_Codon_SNP") {
        $StartCodonSNP++;
      }
      if($arr[8] eq "Stop_Codon_Del") {
        $StopCodonDel++;
      }
      if($arr[8] eq "Stop_Codon_Ins") {
        $StopCodonIns++;
      }
      if($arr[8] eq "Missense_Mutation") {
        $missense++;
      }
      if($arr[8] eq "Nonsense_Mutation") {
        $nonsense++;
      }
      if($arr[8] eq "Nonstop_Mutation") {
        $nonstop++;
      }
      if($arr[8] eq "Silent") {
        $silent++;
      }
      if($arr[8] eq "Splice_Site") {
        $splice++;
      }
      
  }
    print INFO1 $file,"\t",$threeutr,"\t",$fiveflank,"\t",$fiveutr,"\t",$igr,"\t",$intron,"\t",$DenovoStartInFrame,"\t",$DenovoStartOutOfFrame,"\t",$FrameShiftDel,"\t",$FrameShiftIns,"\t",$InFrameDel,"\t",$InFrameIns,"\t",$lincRNA,"\t",$RNA,"\t",$StartCodonDel,"\t",$StartCodonIns,"\t",$StartCodonSNP,"\t",$StopCodonDel,"\t",$StopCodonIns,"\t",$missense,"\t",$nonsense,"\t",$nonstop,"\t",$silent,"\t",$splice,"\n";
}
