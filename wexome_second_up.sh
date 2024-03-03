#second module started, it receive the parameter's from first module

  config=$1  
  outdir=$2
  GATK=$3
  paired=$4
  unpaired=$5
  NORMAL=$6
  Indel=$7
  SNP=$8
  MuTect=$9
  indicator=${10};shift;shift;shift;shift;shift;shift;shift;shift;shift;shift;
  uniq_file=("$@")
  

  # It is showing the parameters which was received from first module
  echo -e "\n\n" >> $outdir$indicator
  echo "Congratulations...You successfully completed the first module of Waterhose... " >> $outdir$indicator
  echo ".............................................................................." >> $outdir$indicator
  echo -e "\n\n" >> $outdir$indicator
  echo "Second module of Waterhose started:" >> $outdir$indicator
  echo "..................................." >> $outdir$indicator
  echo "Started processing in folder:$outdir" >> $outdir$indicator
  echo "Started processing in folder:$GATK" >> $outdir$indicator
  echo "Started processing in folder:$paired" >> $outdir$indicator
  echo "Started processing in folder:$unpaired" >> $outdir$indicator
  echo "Started processing in folder:$NORMAL" >> $outdir$indicator
  echo "Started processing in folder:$Indel" >> $outdir$indicator
  echo "Started processing in folder:$SNP" >> $outdir$indicator
  echo "Started processing in folder:$MuTect" >> $outdir$indicator

  # Creation of new folders for GATK paired and unpaired analysis

   comma_removed="comma_removed""/"	
   	
   echo -e "\n" >> $outdir$indicator	
   echo "Creating Directories for VCF file processing:" >> $outdir$indicator	
   mkdir $outdir$GATK$paired$Indel$comma_removed	
   mkdir $outdir$GATK$paired$SNP$comma_removed	
   mkdir $outdir$GATK$unpaired$Indel$comma_removed	
   mkdir $outdir$GATK$unpaired$SNP$comma_removed	
   mkdir $outdir$GATK$unpaired$NORMAL$Indel$comma_removed	
   mkdir $outdir$GATK$unpaired$NORMAL$SNP$comma_removed	
   mkdir $outdir$MuTect$comma_removed	
   	
	
  	
   echo -e "\n" >> $outdir$indicator	
   echo "VCF file processing started:" >> $outdir$indicator	
   perl comma_removal.pl $outdir$GATK$paired$Indel $outdir$GATK$paired$Indel$comma_removed	
   perl comma_removal.pl $outdir$GATK$paired$SNP $outdir$GATK$paired$SNP$comma_removed	
   perl comma_removal.pl $outdir$GATK$unpaired$Indel $outdir$GATK$unpaired$Indel$comma_removed	
   perl comma_removal.pl $outdir$GATK$unpaired$SNP $outdir$GATK$unpaired$SNP$comma_removed	
   perl comma_removal.pl $outdir$GATK$unpaired$NORMAL$Indel $outdir$GATK$unpaired$NORMAL$Indel$comma_removed	
   perl comma_removal.pl $outdir$GATK$unpaired$NORMAL$SNP $outdir$GATK$unpaired$NORMAL$SNP$comma_removed	
   perl comma_removal.pl $outdir$MuTect $outdir$MuTect$comma_removed	
   	
   coverage_5x_filter_snp="coverage_5x_filter_snp""/"	
   coverage_5x_filter_Indel="coverage_5x_filter_Indel""/"	
   chr_start_end_ref_alt_snp="chr_start_end_ref_alt_snp""/"	
   chr_start_end_ref_alt_Indel="chr_start_end_ref_alt_Indel""/"	
	
   echo -e "\n" >> $outdir$indicator	
   mkdir $outdir$GATK$unpaired$Indel$comma_removed$coverage_5x_filter_Indel	
   mkdir $outdir$GATK$unpaired$SNP$comma_removed$coverage_5x_filter_snp	
   mkdir $outdir$GATK$unpaired$Indel$comma_removed$coverage_5x_filter_Indel$chr_start_end_ref_alt_Indel	
   mkdir $outdir$GATK$unpaired$SNP$comma_removed$coverage_5x_filter_snp$chr_start_end_ref_alt_snp	
   
    gatk_unpaired_processing()	
{	
  #5X filter for SNP	
	
  	
  for file in $(find $outdir$GATK$unpaired$SNP$comma_removed -type f -name "*.vcf") ; 	
  do	
    vcf_filename_with_extn=$(basename $file);	
    vcf_base_name="${vcf_filename_with_extn%T_fxd_sorted_DupRm_realn_recal_variantannotator_SNP*}"	
    alt_base_depth=5	
	
	cat $file | while read LINE 	
	do 	
		if echo $LINE | grep -Eq '^#'	
		then	
				continue;	
	
		else	
					
				echo $LINE | awk -v alt_base_count="$alt_base_depth" -v line="$LINE" '{split($10,a,":|,");if(a[3]>=alt_base_count) print line;}' >> $outdir$GATK$unpaired$SNP$comma_removed$coverage_5x_filter_snp$vcf_base_name"_T_"$alt_base_depth"x_filtered.vcf"	
	
		fi	
	done	
	echo "Completed!!! Output File generated as $vcf_base_name"_T_"$alt_base_depth"x_filtered.vcf"" >> $outdir$indicator	
	
  done;	
	
	
  #5X filter for Indel	
	
  for file in $(find $outdir$GATK$unpaired$Indel$comma_removed -type f -name "*.vcf") ; 	
  do	
   vcf_filename_with_extn=$(basename $file) ;	
   vcf_filename=$(basename "$1")	
   vcf_base_name="${vcf_filename_with_extn%T_fxd_sorted_DupRm_realn_recal_INDEL.*}"	
   alt_base_depth=5	
	
  cat $file | while read LINE 	
	do 	
		if echo $LINE | grep -Eq '^#'	
		then	
				continue;	
       	
		else	
					
				echo $LINE | awk -v alt_base_count="$alt_base_depth" -v line="$LINE" '{split($10,a,":|,");if(a[3]>=alt_base_count) print line;}' >> $outdir$GATK$unpaired$Indel$comma_removed$coverage_5x_filter_Indel$vcf_base_name"_T_"$alt_base_depth"x_filtered.vcf"	
	
	fi	
	done	
	echo "Completed!!! Output File generated as $vcf_base_name"_T_"$alt_base_depth"x_filtered.vcf"" >> $outdir$indicator	
	
  done;	
	
  echo "Analysis of filtering completed!!!!!" >> $outdir$indicator	
	
	
  #Extracting 5 fields from filtered file (chr_start_end_ref_alt) for SNP	
	
  for file in $(find $outdir$GATK$unpaired$SNP$comma_removed$coverage_5x_filter_snp -type f -name "*.vcf") ; 	
  do	
    vcf_filename_with_extn=$(basename $file) ;	
    vcf_base_name="${vcf_filename_with_extn%.*}"	
    awk 'BEGIN { print "chr","\t","start","\t","end","\t","ref_allele","\t","alt_allele"} { print $1,"\t",$2,"\t",$3=length($4)+$2-1,"\t",$4,"\t",$5 }' $file | sed 's/ //g' >> $outdir$GATK$unpaired$SNP$comma_removed$coverage_5x_filter_snp$chr_start_end_ref_alt_snp$vcf_base_name".vcf" 	
  done;	
	
  #Extracting 5 fields from filtered file (chr_start_end_ref_alt) for INDEL	
	
  for file in $(find $outdir$GATK$unpaired$Indel$comma_removed$coverage_5x_filter_Indel -type f -name "*.vcf") ; 	
  do	
    vcf_filename_with_extn=$(basename $file) ;	
    vcf_base_name="${vcf_filename_with_extn%.*}"	
    awk 'BEGIN { print "chr","\t","start","\t","end","\t","ref_allele","\t","alt_allele"} { print $1,"\t",$2,"\t",$3=length($4)+$2-1,"\t",$4,"\t",$5 }' $file | sed 's/ //g' >> $outdir$GATK$unpaired$Indel$comma_removed$coverage_5x_filter_Indel$chr_start_end_ref_alt_Indel$vcf_base_name".vcf" 	
  done;	
	
}	
	
  #MuTect processing 	
  coverage_5x_filter="coverage_5x_filter""/"	
  chr_start_end_ref_alt="chr_start_end_ref_alt""/"	
 	
	
  mkdir $outdir$MuTect$comma_removed$coverage_5x_filter	
  mkdir $outdir$MuTect$comma_removed$coverage_5x_filter$chr_start_end_ref_alt	
  	
   	
   MuTect_processing()	
{	
   #5x filter for SNP	
	
   for file in $(find $outdir$MuTect$comma_removed -type f -name "*.vcf") ; 	
   do	
   vcf_filename_with_extn=$(basename $file) ;	
   vcf_base_name="${vcf_filename_with_extn%.*}"	
   alt_base_depth=5	
	
	cat $file | while read LINE 	
	do 	
		if echo $LINE | grep -Eq '^#'	
		then	
				continue;	
        else	
					
				echo $LINE | awk -v alt_base_count="$alt_base_depth" -v line="$LINE" '{split($10,a,":");if(a[4]>=alt_base_count) print line;}' >> $outdir$MuTect$comma_removed$coverage_5x_filter$vcf_base_name"_T_"$alt_base_depth"x_filtered.vcf"	
	
		fi	
	done	
	echo "Completed!!! Output File generated as $vcf_base_name"_T-N_"$alt_base_depth"x_filtered.vcf"" >> $outdir$indicator	
	
        done; 	
  	
   		
    #Extracting five fields from filtered file (snp)	
	
    for file in $(find $outdir$MuTect$comma_removed$coverage_5x_filter -type f -name "*.vcf") ; 	
    do	
      vcf_filename_with_extn=$(basename $file) ;	
      vcf_base_name="${vcf_filename_with_extn%.*}"	
      awk 'BEGIN { print "chr","\t","start","\t","end","\t","ref_allele","\t","alt_allele"} { print $1,"\t",$2,"\t",$3=length($4)+$2-1,"\t",$4,"\t",$5 }' $file | sed 's/ //g' >> $outdir$MuTect$comma_removed$coverage_5x_filter$chr_start_end_ref_alt$vcf_base_name".vcf" 	
    done; 	
	
}	
	
	gatk_unpaired_processing	
	MuTect_processing	
 	
	GATK_SNP_Indel_mutect="GATK_SNP_Indel_mutect""/"	
	mkdir $outdir$GATK_SNP_Indel_mutect	
	cp $outdir$GATK$unpaired$SNP$comma_removed$coverage_5x_filter_snp$chr_start_end_ref_alt_snp* $outdir$GATK_SNP_Indel_mutect	
	cp $outdir$GATK$unpaired$Indel$comma_removed$coverage_5x_filter_Indel$chr_start_end_ref_alt_Indel* $outdir$GATK_SNP_Indel_mutect	
	cp $outdir$MuTect$comma_removed$coverage_5x_filter$chr_start_end_ref_alt* $outdir$GATK_SNP_Indel_mutect	
  	
   	
   #	
   sed -i "1d" $outdir$GATK_SNP_Indel_mutect*
   merged="merged""/"	
   	
   	
   mkdir $outdir$GATK_SNP_Indel_mutect$merged	
   	
   j=0	
   for fn1 in ${uniq_file[*]};	
   do	
        a4=$(echo $fn1 | cut -d_ -f1)	
	FILE_L[$j]=$a4	
  j=$((j+1))	
   done	
	
   uniq_file_L=($(echo ${FILE_L[@]} | tr ' ' '\n' | sort -u | tr '\n' ' '))	
  	
   echo ${uniq_file_L[*]}	
  	
   for fn1 in ${uniq_file_L[*]};	
   do	
   	sort -u $outdir$GATK_SNP_Indel_mutect$fn1* -o $outdir$GATK_SNP_Indel_mutect$merged$fn1".txt"	
   done;	
  	
  #	
  	
   file_key="file_key""/"	
   mkdir $outdir$GATK_SNP_Indel_mutect$merged$file_key	
  	
   for file in $(find $outdir$GATK_SNP_Indel_mutect$merged* -type f -name "*.txt") ; 	
   do	
   file_name=$(basename $file) ;	
   file_without_extension="${file_name%.txt}";	
   awk '{print $1"_"$2"_"$3"_"$4"_"$5}' $outdir$GATK_SNP_Indel_mutect$merged$file_name >> $outdir$GATK_SNP_Indel_mutect$merged$file_key$file_without_extension".txt"	
		
   done;	
	
  	
  #	
  	
   sed -i 's/chr//g' $outdir$GATK_SNP_Indel_mutect$merged$file_key*.*	
	
  #	
   path=`pwd`	
   cd $outdir$GATK_SNP_Indel_mutect$merged$file_key	
   for f in *.*; do sed -i "s/$/\t$f/" $f; done	
   sed -i 's/\.txt//g' $outdir$GATK_SNP_Indel_mutect$merged$file_key*
   #sed -i '1d' $outdir$GATK_SNP_Indel_mutect$merged$file_key*	
   cd $path	
   echo "./wexome_third.sh --$config --$outdir --$GATK_SNP_Indel_mutect --$merged --$file_key" >> $outdir$indicator	

./wexome_third.sh $config $outdir $GATK_SNP_Indel_mutect $merged $file_key $indicator 	
	

   
   
