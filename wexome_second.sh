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
 
  
   
   T_N_SNP="T-N_SNP""/"
   T_N_Indel="T-N_Indel""/"
   coverage_5x_filter_snp="coverage_5x_filter_snp""/"
   coverage_5x_filter_Indel="coverage_5x_filter_Indel""/"
   chr_start_end_ref_alt_snp="chr_start_end_ref_alt_snp""/"
   chr_start_end_ref_alt_Indel="chr_start_end_ref_alt_Indel""/"

   echo -e "\n" >> $outdir$indicator
   mkdir $outdir$GATK$paired$Indel$comma_removed$T_N_Indel
   mkdir $outdir$GATK$paired$SNP$comma_removed$T_N_SNP
   mkdir $outdir$GATK$paired$Indel$comma_removed$T_N_Indel$coverage_5x_filter_Indel
   mkdir $outdir$GATK$paired$SNP$comma_removed$T_N_SNP$coverage_5x_filter_snp
   mkdir $outdir$GATK$paired$Indel$comma_removed$T_N_Indel$coverage_5x_filter_Indel$chr_start_end_ref_alt_Indel
   mkdir $outdir$GATK$paired$SNP$comma_removed$T_N_SNP$coverage_5x_filter_snp$chr_start_end_ref_alt_snp

gatk_paired_processing() 
{
   echo "Extracting 4 fields for SNP from vcf file" >> $outdir$indicator

   for file in $(find $outdir$GATK$paired$SNP$comma_removed -type f -name "*T_fxd_sorted_DupRm_realn_recal_variantannotator_SNP.vcf"); 
   do
	vcf_filename_with_extn=$(basename $file);
	vcf_filename_without_extn="${vcf_filename_with_extn%T_fxd_sorted_DupRm_realn_recal_variantannotator_SNP*}";

	awk 'NR==FNR {Ar[$1$2$4$5] ++ ; next} ! (($1$2$4$5) in Ar)' <(cat $outdir$GATK$paired$SNP$comma_removed$vcf_filename_without_extn"N_fxd_sorted_DupRm_realn_recal_variantannotator_SNP.vcf") $file >>  $outdir$GATK$paired$SNP$comma_removed$T_N_SNP$vcf_filename_without_extn"_T-N.vcf";
   done;  

   echo "Extracting 4 fields for Indel from vcf file" >> $outdir$indicator

   for file in $(find $outdir$GATK$paired$Indel$comma_removed -type f -name "*N_fxd_sorted_DupRm_realn_recal_INDEL.vcf") ; 
   do
	vcf_filename_with_extn=$(basename $file) ;
	vcf_filename_without_extn="${vcf_filename_with_extn%N_fxd_sorted_DupRm_realn_recal_INDEL.vcf}" ;
	
	awk 'NR==FNR {Ar[$1$2$4$5] ++ ; next} ! (($1$2$4$5) in Ar)' <(cat $outdir$GATK$paired$Indel$comma_removed$vcf_filename_without_extn"N_fxd_sorted_DupRm_realn_recal_INDEL.vcf") $outdir$GATK$paired$Indel$comma_removed$vcf_filename_without_extn"T_fxd_sorted_DupRm_realn_recal_INDEL.vcf" >>  $outdir$GATK$paired$Indel$comma_removed$T_N_Indel$vcf_filename_without_extn"_T-N.vcf" ;
   done;
   
   echo "Doing 5x filter for SNP" >> $outdir$indicator

   for file in $(find $outdir$GATK$paired$SNP$comma_removed$T_N_SNP -type f -name "*.vcf") ; 
   do
   vcf_filename_with_extn=$(basename $file) ;
   vcf_base_name="${vcf_filename_with_extn%_T-N*}"
   alt_base_depth=5

	cat $file | while read LINE 
	do 
		if echo $LINE | grep -Eq '^#'
		then
				continue;
        else
				
				echo $LINE | awk -v alt_base_count="$alt_base_depth" -v line="$LINE" '{split($10,a,":|,");if(a[3]>=alt_base_count) print line;}' >> $outdir$GATK$paired$SNP$comma_removed$T_N_SNP$coverage_5x_filter_snp$vcf_base_name"_T-N_"$alt_base_depth"x_filtered.vcf"

		fi
	done
	echo "Completed!!! Output File generated as $vcf_base_name"_T-N_"$alt_base_depth"x_filtered.vcf"" >> $outdir$indicator

        done; 
  
    echo "Doing 5x filter for Indel" >> $outdir$indicator
 
     
   for file in $(find $outdir$GATK$paired$Indel$comma_removed$T_N_Indel -type f -name "*.vcf") ; 
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
				
				echo $LINE | awk -v alt_base_count="$alt_base_depth" -v line="$LINE" '{split($10,a,":|,");if(a[3]>=alt_base_count) print line;}' >> $outdir$GATK$paired$Indel$comma_removed$T_N_Indel$coverage_5x_filter_Indel$vcf_base_name"_"$alt_base_depth"x_filtered.vcf"

	fi
	done
	echo "Completed!!! Output File generated as $vcf_base_name"_"$alt_base_depth"x_filtered.vcf"" >> $outdir$indicator

        done;
		
    echo "Extracting five fields from filtered file (snp)" >> $outdir$indicator

    for file in $(find $outdir$GATK$paired$SNP$comma_removed$T_N_SNP$coverage_5x_filter_snp -type f -name "*.vcf") ; 
    do
      vcf_filename_with_extn=$(basename $file) ;
      vcf_base_name="${vcf_filename_with_extn%.*}"
      awk 'BEGIN { print "chr","\t","start","\t","end","\t","ref_allele","\t","alt_allele"} { print $1,"\t",$2,"\t",$3=length($4)+$2-1,"\t",$4,"\t",$5 }' $file | sed 's/ //g' >> $outdir$GATK$paired$SNP$comma_removed$T_N_SNP$coverage_5x_filter_snp$chr_start_end_ref_alt_snp$vcf_base_name".vcf" 
    done; 

    echo "Extracting five fields from filtered file (Indel)" >> $outdir$indicator

    for file in $(find $outdir$GATK$paired$Indel$comma_removed$T_N_Indel$coverage_5x_filter_Indel -type f -name "*.vcf") ; 
    do
      vcf_filename_with_extn=$(basename $file) ;
      vcf_base_name="${vcf_filename_with_extn%.*}"
      awk 'BEGIN { print "chr","\t","start","\t","end","\t","ref_allele","\t","alt_allele"} { print $1,"\t",$2,"\t",$3=length($4)+$2-1,"\t",$4,"\t",$5 }' $file | sed 's/ //g' >> $outdir$GATK$paired$Indel$comma_removed$T_N_Indel$coverage_5x_filter_Indel$chr_start_end_ref_alt_Indel$vcf_base_name".vcf" 
   done; 
}  
   
  #Unpaired sample processing part
   
  mkdir $outdir$GATK$unpaired$Indel$comma_removed$T_N_Indel
  mkdir $outdir$GATK$unpaired$SNP$comma_removed$T_N_SNP
  mkdir $outdir$GATK$unpaired$Indel$comma_removed$T_N_Indel$coverage_5x_filter_Indel
  mkdir $outdir$GATK$unpaired$SNP$comma_removed$T_N_SNP$coverage_5x_filter_snp
  mkdir $outdir$GATK$unpaired$Indel$comma_removed$T_N_Indel$coverage_5x_filter_Indel$chr_start_end_ref_alt_Indel
  mkdir $outdir$GATK$unpaired$SNP$comma_removed$T_N_SNP$coverage_5x_filter_snp$chr_start_end_ref_alt_snp
  
gatk_unpaired_processing()
{
  #Indel Normal processing

  echo "Normal file processing started" >> $outdir$indicator
  
  cat $outdir$GATK$unpaired$NORMAL$Indel$comma_removed*.vcf >> $outdir$GATK$unpaired$NORMAL$Indel$comma_removed"merge_all.txt"
  m1="merge_all.txt"

  egrep -v '#' $outdir$GATK$unpaired$NORMAL$Indel$comma_removed$m1 >> $outdir$GATK$unpaired$NORMAL$Indel$comma_removed"merge_all_no_hash.txt"
  m2="merge_all_no_hash.txt"

  cut -f 1,2,3,4,5 $outdir$GATK$unpaired$NORMAL$Indel$comma_removed$m2 >> $outdir$GATK$unpaired$NORMAL$Indel$comma_removed"merge_all_no_hash_5_columns_selected.txt" 
  m3="merge_all_no_hash_5_columns_selected.txt"

  sed 's/\t/_/g' $outdir$GATK$unpaired$NORMAL$Indel$comma_removed$m3 >> $outdir$GATK$unpaired$NORMAL$Indel$comma_removed"merge_all_no_hash_5_columns_selected_tab_to_underscore.txt"
  m4="merge_all_no_hash_5_columns_selected_tab_to_underscore.txt"

  sort $outdir$GATK$unpaired$NORMAL$Indel$comma_removed$m4 | uniq >> $outdir$GATK$unpaired$NORMAL$Indel$comma_removed"merge_all_no_hash_5_columns_selected_tab_to_underscore_sort_uniq.txt"
  m5="merge_all_no_hash_5_columns_selected_tab_to_underscore_sort_uniq.txt"  

  sed 's/_/\t/g' $outdir$GATK$unpaired$NORMAL$Indel$comma_removed$m5 >> $outdir$GATK$unpaired$NORMAL$Indel$comma_removed"merge_all_no_hash_5_columns_selected_tab_to_underscore_sort_uniq_again_underscore_tab.txt"

  
  #SNP Normal processing

  cat $outdir$GATK$unpaired$NORMAL$SNP$comma_removed*.vcf >> $outdir$GATK$unpaired$NORMAL$SNP$comma_removed"merge_all.txt"
  m1="merge_all.txt"

  egrep -v '#' $outdir$GATK$unpaired$NORMAL$SNP$comma_removed$m1 >> $outdir$GATK$unpaired$NORMAL$SNP$comma_removed"merge_all_no_hash.txt"
  m2="merge_all_no_hash.txt"

  cut -f 1,2,3,4,5 $outdir$GATK$unpaired$NORMAL$SNP$comma_removed$m2 >> $outdir$GATK$unpaired$NORMAL$SNP$comma_removed"merge_all_no_hash_5_columns_selected.txt" 
  m3="merge_all_no_hash_5_columns_selected.txt"

  sed 's/\t/_/g' $outdir$GATK$unpaired$NORMAL$SNP$comma_removed$m3 >> $outdir$GATK$unpaired$NORMAL$SNP$comma_removed"merge_all_no_hash_5_columns_selected_tab_to_underscore.txt"
  m4="merge_all_no_hash_5_columns_selected_tab_to_underscore.txt"

  sort $outdir$GATK$unpaired$NORMAL$SNP$comma_removed$m4 | uniq >> $outdir$GATK$unpaired$NORMAL$SNP$comma_removed"merge_all_no_hash_5_columns_selected_tab_to_underscore_sort_uniq.txt"
  m5="merge_all_no_hash_5_columns_selected_tab_to_underscore_sort_uniq.txt"  

  sed 's/_/\t/g' $outdir$GATK$unpaired$NORMAL$SNP$comma_removed$m5 >> $outdir$GATK$unpaired$NORMAL$SNP$comma_removed"merge_all_no_hash_5_columns_selected_tab_to_underscore_sort_uniq_again_underscore_tab.txt"

  echo "Normal processes stopped" >> $outdir$indicator
  
  #Filtering based on 4 fields for SNPs
 
  echo "T-N process started for SNPs for unpaired samples" >> $outdir$indicator
  m_all="merge_all_no_hash_5_columns_selected_tab_to_underscore_sort_uniq_again_underscore_tab.txt"
  for file in $(find $outdir$GATK$unpaired$SNP$comma_removed -type f -name "*T_fxd_sorted_DupRm_realn_recal_variantannotator_SNP.vcf") ; 
  do
	vcf_filename_with_extn=$(basename $file) ;
	vcf_filename_without_extn="${vcf_filename_with_extn%T_fxd_sorted_DupRm_realn_recal_variantannotator_SNP*}" ;
	
	awk 'NR==FNR {Ar[$1$2$4$5] ++ ; next} ! (($1$2$4$5) in Ar)' <(cat $outdir$GATK$unpaired$NORMAL$SNP$comma_removed$m_all) $file >>  $outdir$GATK$unpaired$SNP$comma_removed$T_N_SNP$vcf_filename_without_extn"_T-N.vcf" ;
  done;
  echo "T-N process stopped for SNPs for unpaired samples" >> $outdir$indicator


  #Filtering based on 4 fields for Indel

  m_all1="merge_all_no_hash_5_columns_selected_tab_to_underscore_sort_uniq_again_underscore_tab.txt"
  
  echo "T-N process started for Indels for unpaired samples"
  for file in $(find $outdir$GATK$unpaired$Indel$comma_removed -type f -name "*T_fxd_sorted_DupRm_realn_recal_INDEL.vcf") ; 
  do
	vcf_filename_with_extn=$(basename $file) ;
	vcf_filename_without_extn="${vcf_filename_with_extn%T_fxd_sorted_DupRm_realn_recal_INDEL.vcf}" ;
	
	awk 'NR==FNR {Ar[$1$2$4$5] ++ ; next} ! (($1$2$4$5) in Ar)' <(cat $outdir$GATK$unpaired$NORMAL$Indel$comma_removed$m_all1) $outdir$GATK$unpaired$Indel$comma_removed$vcf_filename_without_extn"T_fxd_sorted_DupRm_realn_recal_INDEL.vcf" >>  $outdir$GATK$unpaired$Indel$comma_removed$T_N_Indel$vcf_filename_without_extn"_T-N.vcf" ;
  done;
  echo "T-N process stopped for Indels for unpaired samples" >> $outdir$indicator

  #5X filter for SNP

  
  for file in $(find $outdir$GATK$unpaired$SNP$comma_removed$T_N_SNP -type f -name "*.vcf") ; 
  do
    vcf_filename_with_extn=$(basename $file);
    vcf_base_name="${vcf_filename_with_extn%_T-N*}"
    alt_base_depth=5

	cat $file | while read LINE 
	do 
		if echo $LINE | grep -Eq '^#'
		then
				continue;

		else
				
				echo $LINE | awk -v alt_base_count="$alt_base_depth" -v line="$LINE" '{split($10,a,":|,");if(a[3]>=alt_base_count) print line;}' >> $outdir$GATK$unpaired$SNP$comma_removed$T_N_SNP$coverage_5x_filter_snp$vcf_base_name"_T-N_"$alt_base_depth"x_filtered.vcf"

		fi
	done
	echo "Completed!!! Output File generated as $vcf_base_name"_T-N_"$alt_base_depth"x_filtered.vcf"" >> $outdir$indicator

  done;


  #5X filter for Indel

  for file in $(find $outdir$GATK$unpaired$Indel$comma_removed$T_N_Indel -type f -name "*.vcf") ; 
  do
   vcf_filename_with_extn=$(basename $file) ;
   vcf_filename=$(basename "$1")
   vcf_base_name="${vcf_filename_with_extn%.*}"
   alt_base_depth=5

  cat $file | while read LINE 
	do 
		if echo $LINE | grep -Eq '^#'
		then
				continue;
       
		else
				
				echo $LINE | awk -v alt_base_count="$alt_base_depth" -v line="$LINE" '{split($10,a,":|,");if(a[3]>=alt_base_count) print line;}' >> $outdir$GATK$unpaired$Indel$comma_removed$T_N_Indel$coverage_5x_filter_Indel$vcf_base_name"_"$alt_base_depth"x_filtered.vcf"

	fi
	done
	echo "Completed!!! Output File generated as $vcf_base_name"_"$alt_base_depth"x_filtered.vcf"" >> $outdir$indicator

  done;

  echo "Analysis of filtering completed!!!!!" >> $outdir$indicator


  #Extracting 5 fields from filtered file (chr_start_end_ref_alt) for SNP

  for file in $(find $outdir$GATK$unpaired$SNP$comma_removed$T_N_SNP$coverage_5x_filter_snp -type f -name "*.vcf") ; 
  do
    vcf_filename_with_extn=$(basename $file) ;
    vcf_base_name="${vcf_filename_with_extn%.*}"
    awk 'BEGIN { print "chr","\t","start","\t","end","\t","ref_allele","\t","alt_allele"} { print $1,"\t",$2,"\t",$3=length($4)+$2-1,"\t",$4,"\t",$5 }' $file | sed 's/ //g' >> $outdir$GATK$unpaired$SNP$comma_removed$T_N_SNP$coverage_5x_filter_snp$chr_start_end_ref_alt_snp$vcf_base_name".vcf" 
  done;

  #Extracting 5 fields from filtered file (chr_start_end_ref_alt) for INDEL

  for file in $(find $outdir$GATK$unpaired$Indel$comma_removed$T_N_Indel$coverage_5x_filter_Indel -type f -name "*.vcf") ; 
  do
    vcf_filename_with_extn=$(basename $file) ;
    vcf_base_name="${vcf_filename_with_extn%.*}"
    awk 'BEGIN { print "chr","\t","start","\t","end","\t","ref_allele","\t","alt_allele"} { print $1,"\t",$2,"\t",$3=length($4)+$2-1,"\t",$4,"\t",$5 }' $file | sed 's/ //g' >> $outdir$GATK$unpaired$Indel$comma_removed$T_N_Indel$coverage_5x_filter_Indel$chr_start_end_ref_alt_Indel$vcf_base_name".vcf" 
  done;



}
  # MuTect processing 
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
   vcf_base_name="${vcf_filename_with_extn%_T-N*}"
   alt_base_depth=5

	cat $file | while read LINE 
	do 
		if echo $LINE | grep -Eq '^#'
		then
				continue;
        else
				
				echo $LINE | awk -v alt_base_count="$alt_base_depth" -v line="$LINE" '{split($10,a,":");if(a[4]>=alt_base_count) print line;}' >> $outdir$MuTect$comma_removed$coverage_5x_filter$vcf_base_name"_T-N_"$alt_base_depth"x_filtered.vcf"

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

	gatk_paired_processing  
	gatk_unpaired_processing
	MuTect_processing
   
   
   	GATK_SNP_Indel_mutect="GATK_SNP_Indel_mutect""/"
	mkdir $outdir$GATK_SNP_Indel_mutect
	cp $outdir$GATK$paired$SNP$comma_removed$T_N_SNP$coverage_5x_filter_snp$chr_start_end_ref_alt_snp* $outdir$GATK_SNP_Indel_mutect
	cp $outdir$GATK$paired$Indel$comma_removed$T_N_Indel$coverage_5x_filter_Indel$chr_start_end_ref_alt_Indel* $outdir$GATK_SNP_Indel_mutect
	cp $outdir$GATK$unpaired$SNP$comma_removed$T_N_SNP$coverage_5x_filter_snp$chr_start_end_ref_alt_snp* $outdir$GATK_SNP_Indel_mutect
	cp $outdir$GATK$unpaired$Indel$comma_removed$T_N_Indel$coverage_5x_filter_Indel$chr_start_end_ref_alt_Indel* $outdir$GATK_SNP_Indel_mutect
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
   done
  
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
   cd $path
echo "./wexome_third.sh --$config --$outdir --$GATK_SNP_Indel_mutect --$merged --$file_key --$indicator" >> $outdir$indicator


./wexome_third.sh $config $outdir $GATK_SNP_Indel_mutect $merged $file_key $indicator  

