#bwa_human_alignment module	
bwa_human_alignment()	
{	
	echo -e "\n\n" >> $outdir$indicator	
	echo "Alignment Initialised. Generating files in $outdir for $1" >> $outdir$indicator	
	$bwa_path aln -t $threads -f $1$sai1 $human_bwa_index"hg19_all.fasta" $read1path &>> $outdir$logfile	
	$bwa_path aln -t $threads -f $1$sai2 $human_bwa_index"hg19_all.fasta" $read2path &>> $outdir$logfile	
	$bwa_path sampe -f $1$samfile -r "@RG\tID:CAN-NOXXXX\tPL:ILLUMINA\tLB:LIB-EXO\tSM:UNKNOWN\tPI:200" $human_bwa_index"hg19_all.fasta" $1$sai1 $1$sai2 $read1path $read2path &>> $outdir$logfile	
}	

#picard_part_processing module	
picard_part_processing()	
{	
	   echo -e "\n\n" >> $outdir$indicator	
	   echo "Picard Processing Started for $1" >> $outdir$indicator	
	   echo "Now processing FixMateInformation.jar for $1" >> $outdir$indicator	
   	
	   java -Xmx10G -jar $picard"FixMateInformation.jar" I= $1$samfile o= $1$samfile_fxd VALIDATION_STRINGENCY=SILENT TMP_DIR=tmp/ &>> $outdir$logfile	
   	
	   echo -e "\n\n" >> $outdir$indicator	
	   echo "Now processing SamFormatConverter.jar for $1" >> $outdir$indicator	
	   java -Xmx10G -jar $picard"SamFormatConverter.jar" I= $1$samfile o= $1$bamfile VALIDATION_STRINGENCY=SILENT TMP_DIR=tmp/ &>> $outdir$logfile	
   	
	   echo -e "\n\n" >> $outdir$indicator	
	   echo "Now processing SamFormatConverter.jar for $1" >> $outdir$indicator	
	   java -Xmx10G -jar $picard"SamFormatConverter.jar" I= $1$samfile_fxd o= $1$bamfile_fxd VALIDATION_STRINGENCY=SILENT &>> $outdir$logfile	
   	
	   echo -e "\n\n" >> $outdir$indicator	
	   echo "Mow processing SortSam.jar for $1" >> $outdir$indicator	
	   java -Xmx10G -Djava.io.tmpdir=`pwd`/tmp -jar $picard"SortSam.jar" I= $1$bamfile_fxd o= $1$bamfile_fxd_sorted SORT_ORDER=coordinate VALIDATION_STRINGENCY=SILENT &>> $outdir$logfile	
   	
	   echo -e "\n\n" >> $outdir$indicator	
	   echo "Now processing MarkDuplicates.jar for $1" >> $outdir$indicator	
	   java -Xmx10G -Djava.io.tmpdir=`pwd`/tmp -jar $picard"MarkDuplicates.jar" I= $1$bamfile_fxd_sorted o= $1$bamfile_fxd_sorted_DupRm METRICS_FILE= $1$bamfile_fxd_sorted_DupRm_info REMOVE_DUPLICATES=true ASSUME_SORTED=true VALIDATION_STRINGENCY=SILENT &>> $outdir$logfile	
   	
	   echo -e "\n\n" >> $outdir$indicator	
	   echo "Now processing BuildBamIndex.jar for $1" >> $outdir$indicator	
	   java -Xmx10G -Djava.io.tmpdir=`pwd`/tmp -jar $picard"BuildBamIndex.jar" I= $1$bamfile_fxd_sorted_DupRm o= $1$baifile_fxd_sorted_DupRm VALIDATION_STRINGENCY=SILENT &>> $outdir$logfile	
}	

#gatk part processing module	
gatk_part_processing()	
{	
	  echo -e "\n\n" >> $outdir$indicator	
	  echo "GATK processing Started for $1"  >> $outdir$indicator	
	  echo "Now processing RealignerTargetCreator for $1" >> $outdir$indicator	
  	
	  java -Xmx10G -jar $GATK -T RealignerTargetCreator -R $human_bwa_index"hg19_all.fasta" -I $1$bamfile_fxd_sorted_DupRm -o $1$bamfile_fxd_sorted_DupRm_IndelRealigner &>> $outdir$logfile	
  	
	  echo -e "\n\n" >> $outdir$indicator	
	  echo "Now processing IndelRealigner for $1" >> $outdir$indicator	
	  java -Xmx10G -jar $GATK -T IndelRealigner -R $human_bwa_index"hg19_all.fasta" -I $1$bamfile_fxd_sorted_DupRm -targetIntervals $1$bamfile_fxd_sorted_DupRm_IndelRealigner -o $1$bamfile_fxd_sorted_DupRm_realn -log $1$bamfile_fxd_sorted_DupRm_realn_log &>> $outdir$logfile	
  	
	  echo -e "\n\n" >> $outdir$indicator	
	  echo "Now processing BaseRecalibrator for $1" >> $outdir$indicator	
	  java -Xmx10G -jar $GATK -T BaseRecalibrator -R $human_bwa_index"hg19_all.fasta" -knownSites:dbsnp,VCF /opt/databases/2.3_resources/hg19/dbsnp_137.hg19.vcf -I $1$bamfile_fxd_sorted_DupRm_realn -o $1$bamfile_fxd_sorted_DupRm_realn_recal_grp -cov ReadGroupCovariate -cov QualityScoreCovariate -cov CycleCovariate -cov ContextCovariate &>> $outdir$logfile	
  	
	  echo -e "\n\n" >> $outdir$indicator	
	  echo "Now processing PrintReads for $1" >> $outdir$indicator	
	  java -Xmx10G -jar $GATK -T PrintReads -R $human_bwa_index"hg19_all.fasta" -BQSR $1$bamfile_fxd_sorted_DupRm_realn_recal_grp -I $1$bamfile_fxd_sorted_DupRm_realn -o $1$bamfile_fxd_sorted_DupRm_realn_recal -baq RECALCULATE &>> $outdir$logfile	
  	
	  echo -e "\n\n" >> $outdir$indicator	
	  echo "Now processing UnifiedGenotyper for $1" >> $outdir$indicator	
	  java -Djava.io.tmpdir=./tmp -jar $GATK -T UnifiedGenotyper -R $human_bwa_index"hg19_all.fasta" -I $1$bamfile_fxd_sorted_DupRm_realn_recal -o $1$vcf_fxd_sorted_DupRm_realn_recal_SNP --genotype_likelihoods_model SNP --annotateNDA -l INFO -log $1$vcf_fxd_sorted_DupRm_realn_recal_SNP_log &>> $outdir$logfile	
  	
	  echo -e "\n\n" >> $outdir$indicator	
	  echo "Now processing UnifiedGenotyper for $1" >> $outdir$indicator	
	  java -Djava.io.tmpdir=./tmp -jar $GATK -T UnifiedGenotyper -R $human_bwa_index"hg19_all.fasta" -I $1$bamfile_fxd_sorted_DupRm_realn_recal -o $1$vcf_fxd_sorted_DupRm_realn_recal_INDEL --genotype_likelihoods_model INDEL --annotateNDA -l INFO -log $1$vcf_fxd_sorted_DupRm_realn_recal_INDEL_log &>> $outdir$logfile	
  	
	  echo -e "\n\n" >> $outdir$indicator	
	  echo "Now processing VariantRecalibrator for $1" >> $outdir$indicator	
	  java -Djava.io.tmpdir=./tmp -jar $GATK -T VariantRecalibrator -R $human_bwa_index"hg19_all.fasta" --input $1$vcf_fxd_sorted_DupRm_realn_recal_SNP -resource:hapmap,known=false,training=true,truth=true,prior=15.0 /opt/databases/2.3_resources/hg19/hapmap_3.3.hg19.vcf -resource:omni,known=false,training=true,truth=false,prior=1.0 /opt/databases/2.3_resources/hg19/1000G_omni2.5.hg19.vcf -resource:dbsnp,known=true,training=false,truth=false,prior=6.0 /opt/databases/2.3_resources/hg19/dbsnp_137.hg19.vcf -an QD -an FS -an DP -an HaplotypeScore -an MQRankSum -an ReadPosRankSum -an MQ -mode SNP -recalFile $1$vcf_fxd_sorted_DupRm_realn_recal_SNP_recal -tranchesFile $1$vcf_fxd_sorted_DupRm_realn_recal_SNP_tranches -rscriptFile $1$vcf_fxd_sorted_DupRm_realn_recal_SNP_recal_plots_r &>> $outdir$logfile	
  	
	  echo -e "\n\n" >> $outdir$indicator	
	  echo "Now processing ApplyRecalibration for $1" >> $outdir$indicator	
	  java -Djava.io.tmpdir=./tmp -jar $GATK -T ApplyRecalibration -R $human_bwa_index"hg19_all.fasta" --input $1$vcf_fxd_sorted_DupRm_realn_recal_SNP -tranchesFile $1$vcf_fxd_sorted_DupRm_realn_recal_SNP_tranches -recalFile $1$vcf_fxd_sorted_DupRm_realn_recal_SNP_recal -mode SNP -o $1$vcf_fxd_sorted_DupRm_realn_recal_SNP_recal_vcf &>> $outdir$logfile	
  	
	  echo -e "\n\n" >> $outdir$indicator	
	  echo "Now processing VariantAnnotator for $1" >> $outdir$indicator	
	  java -Xmx20G -Djava.io.tmpdir=`pwd`/tmp -jar $GATK -T VariantAnnotator -R $human_bwa_index"hg19_all.fasta" -I $1$bamfile_fxd_sorted_DupRm_realn_recal --alwaysAppendDbsnpId -o $1$vcf_fxd_sorted_DupRm_realn_recal_variantannotator_SNP_vcf --variant $1$vcf_fxd_sorted_DupRm_realn_recal_SNP -A Coverage --dbsnp /opt/databases/2.3_resources/hg19/dbsnp_137.hg19.vcf &>> $outdir$logfile	
}	

rename()	
{	
	  for file in $(find $1 -type f -name "*");	
	  do	
	     mv "$file" "`echo $file | sed s/$2"_R1.fastq"$2"_R2.fastq"/$2/`"; #renaming the files	
	  done	
}	
	
mutect_analysis()	
{	
	  echo -e "\n\n" >> $outdir$indicator	
	  echo "MuTect analysis for paired sample is started for $1" >> $outdir$indicator	
	  java -jar $Mutect -T MuTect -R $human_bwa_index"hg19_all.fasta" --cosmic /opt/databases/2.3_resources/hg19/cosmicV65_coding_hg19.vcf --dbsnp /opt/databases/2.3_resources/hg19/dbsnp_137.hg19.vcf --input_file:normal $1$3"_fxd_sorted_DupRm_realn_recal.bam" --input_file:tumor $2$4"_fxd_sorted_DupRm_realn_recal.bam" -vcf $2$4"_fxd_sorted_DupRm_realn_recal.mutect.vcf" &>> $outdir$logfile	
}	
	
unpair_mutect_analysis()	
{	
	 echo -e "\n\n" >> $outdir$indicator	
	 echo "MuTect analysis for unpaired sample is started for $1" >> $outdir$indicator	
	 java -jar $Mutect -T MuTect -R $human_bwa_index"hg19_all.fasta" --cosmic /opt/databases/2.3_resources/hg19/cosmicV65_coding_hg19.vcf --dbsnp /opt/databases/2.3_resources/hg19/dbsnp_137.hg19.vcf --input_file:tumor $1$2"_fxd_sorted_DupRm_realn_recal.bam" -vcf $1$2"_fxd_sorted_DupRm_realn_recal.mutect.vcf" &>> $outdir$logfile	
}	






#WATERHOSE script starts here
#getopt take input parameter and parse


OPTS=`getopt -o :c:i:o:h -l "conf:,input_directory:,output_directory:,help" -n "ex3.sh" -- "$@"`

#usage() function show the help message 

function usage() {
	cat << EOF
	Program: WATERHOSE EXOME ANALYSIS
	Version: 0.0.1v
	Contact: The Dutt Lab(ACTREC)

	Usage: WATERHOSE_EXOME [-h] [-c <config.txt>] [-i <input_directory>] [-o <output_directory>]

  	POSITIONAL ARGUMENTS:

		-h HELP, --help HELP 
		-c CONFIG FILE, --conf CONFIG FILE      
						Path of the config file
			                        	ex: config.txt
		-i INPUT DIRECTORY, --input_directory INPUT DIRECTORY
						Path of input directory where all the raw files are stored.
							ex: /WATERHOSE/RAW_FASTQ/
		-o OUTPUT DIRECTORY, --output_directory OUTPUT DIRECTORY
						Path of output directory where all the processed files are stored.
							ex: /WATERHOSE/OUTPUT_FOLDER/

	Note: To use WATERHOSE_EXOME, you need to first install all third party tools like BWA, Picard, GATK, MuTect
	      etc. All third party tools are provided with the package.
EOF
}


if [ $# -eq 0 ]; then
	usage              # usage function, called when you don't provide a parameter
	exit 1
fi

eval set -- "$OPTS"


while true; do             # while loop is used for collecting the option and choosing them
	case "$1" in       # case for selecting options provided by the users
                -h|--help)	            
				usage
				break;
			        ;;
		-c|--conf)
			shift;
			if [ -n "$1" ]; then
				echo "-c used: $1";
				config=$1
				shift;
			fi
			;;
		-i|--input_directory)
			shift;
			if [ -n "$1" ]; then
				echo "-i used: $1"
				input=$1
				shift;
			fi
			;;
		-o|--output_directory)
			shift;
			if [ -n "$1" ]; then
				echo "-o used: $1" 
				output=$1
				shift;
			fi
			;;
		*)
			break;
			shift;
			;;
	
	esac
done


#checking where actually files and folders provided by the user are correct.

if [ -f "$config" ]; then
	echo "$config file is found" 
else 
	echo "$config file is not found. Please specify the path."
	exit
fi

if [ -d "$input" ]; then
	echo "$input folder is found" 
else
	echo "$input folder is not found. Please specify the path." 
	exit
fi

if [ -d "$output" ]; then
	echo "$output folder is found" 
else 
	echo "$output folder is not found. Please specify the path." 
	exit
fi

#Adding "/" to the folder path. Because when you use GUI "/" is missed.

if [[ "$input" =~ .*/$ ]]; then
	indir=$input
else
	indir=$input"/"
fi

if [[ "$output" =~ .*/$ ]]; then
	outdir=$output
else
	outdir=$output"/"
fi


indicator="Waterhose"`date +%Y-%m-%d`"indicator.txt"
logfile="Waterhose"`date +%Y-%m-%d`".log"
#for loop collecting all files from input folder 


i=0
for file in $(find $indir* -type f \( -name "*.gz" -o -name "*.fastq" \));

do 
	file_name=$(basename $file);
	file_with_out_extension="${file_name%.fastq}";

	part1=$(echo $file_with_out_extension | cut -d_ -f1)
	part2=$(echo $file_with_out_extension | cut -d_ -f2)
  
	FILE[$i]=$part1"_"$part2

	i=$((i+1))
done;

#Unique file name getting from FILE[] array

	uniq_file=($(echo ${FILE[@]} | tr ' ' '\n' | sort -u | tr '\n' ' '))

#Retriving the file name from config file
	 echo -e "\n\n"
         bwa_path=$(egrep '^bwa' $config |cut -f 2 -d "=")
         human_bwa_index=$(egrep '^human_bwa_index' $config |cut -f 2 -d "=")
         threads=$(egrep '^threads' $config |cut -f 2 -d "=")
         picard=$(egrep '^picard' $config |cut -f 2 -d "=")
         GATK=$(egrep '^GATK' $config |cut -f 2 -d "=")
         Mutect=$(egrep '^Mutect' $config |cut -f 2 -d "=")
         oncotator=$(egrep '^oncotator' $config |cut -f 2 -d "=")
         qualimap=$(egrep '^Qualimap' $config |cut -f 2 -d "=")

#Displaying the software path

	echo -e "\n\n"
	echo "Path of BWA=$bwa_path"
	echo "Human index=$human_bwa_index"
	echo "Threads=$threads"
  	echo "Picard=$picard"
	echo "GATK=$GATK"
        echo "Oncotator=$oncotator"
	echo "MuTect=$Mutect"
	
	echo -e "\n\n"
 	echo "Congratulations WATERHOSE STARTED processing" >> $outdir$indicator
	echo "............................................" >> $outdir$indicator

#Renaming files and calling functions

for fn in ${uniq_file[*]};
  do
    	mkdir $outdir$fn
	echo -e "\n" >> $outdir$indicator
	echo "Created Directory for the sample:$fn" >> $outdir$indicator
	output_new=$outdir$fn"/"
	read1path=$indir$fn"_R1.fastq.gz"
        read2path=$indir$fn"_R2.fastq.gz"
    	read1_filename=$(basename "$read1path")
 	read1_base_name="${read1_filename%.*}"
	read2_filename=$(basename "$read2path")
	read2_base_name="${read2_filename%.*}"
	sai1=$read1_base_name".sai"
	sai2=$read2_base_name".sai"
 	sam_base_name="$read1_base_name$read2_base_name"
	samfile=$read1_base_name$read2_base_name".sam"
	samfile_fxd=$read1_base_name$read2_base_name"_fxd.sam"
	bamfile=$read1_base_name$read2_base_name".bam"
	bamfile_fxd=$read1_base_name$read2_base_name"_fxd.bam"
	bamfile_fxd_sorted=$read1_base_name$read2_base_name"_fxd_sorted.bam"
	bamfile_fxd_sorted_DupRm=$read1_base_name$read2_base_name"_fxd_sorted_DupRm.bam"
  	bamfile_fxd_sorted_DupRm_info=$read1_base_name$read2_base_name"_fxd_sorted_DupRm_info.txt"
  	baifile_fxd_sorted_DupRm=$read1_base_name$read2_base_name"_fxd_sorted_DupRm.bai"
  	bamfile_fxd_sorted_DupRm_IndelRealigner=$read1_base_name$read2_base_name"_fxd_sorted_DupRm_IndelRealigner.intervals"
  	bamfile_fxd_sorted_DupRm_realn=$read1_base_name$read2_base_name"_fxd_sorted_DupRm_realn.bam"
  	bamfile_fxd_sorted_DupRm_realn_log=$read1_base_name$read2_base_name"_fxd_sorted_DupRm_realn.bam.log"
  	bamfile_fxd_sorted_DupRm_realn_recal_grp=$read1_base_name$read2_base_name"_fxd_sorted_DupRm_realn_recal.grp"
  	bamfile_fxd_sorted_DupRm_realn_recal=$read1_base_name$read2_base_name"_fxd_sorted_DupRm_realn_recal.bam"
  	vcf_fxd_sorted_DupRm_realn_recal_SNP=$read1_base_name$read2_base_name"_fxd_sorted_DupRm_realn_recal_SNP.vcf"
  	vcf_fxd_sorted_DupRm_realn_recal_SNP_log=$read1_base_name$read2_base_name"_fxd_sorted_DupRm_realn_recal_SNP.log"
  	vcf_fxd_sorted_DupRm_realn_recal_INDEL=$read1_base_name$read2_base_name"_fxd_sorted_DupRm_realn_recal_INDEL.vcf"
  	vcf_fxd_sorted_DupRm_realn_recal_INDEL_log=$read1_base_name$read2_base_name"_fxd_sorted_DupRm_realn_recal_INDEL.log"
  	vcf_fxd_sorted_DupRm_realn_recal_SNP_recal=$read1_base_name$read2_base_name"_fxd_sorted_DupRm_realn_recal_SNP.recal"
  	vcf_fxd_sorted_DupRm_realn_recal_SNP_tranches=$read1_base_name$read2_base_name"_fxd_sorted_DupRm_realn_recal_SNP.tranches"
  	vcf_fxd_sorted_DupRm_realn_recal_SNP_recal_plots_r=$read1_base_name$read2_base_name"_fxd_sorted_DupRm_realn_recal_SNP_recal.plots.R"
	vcf_fxd_sorted_DupRm_realn_recal_SNP_recal_vcf=$read1_base_name$read2_base_name"_fxd_sorted_DupRm_realn_recal_SNP_recal.vcf"
  	vcf_fxd_sorted_DupRm_realn_recal_variantannotator_SNP_vcf=$read1_base_name$read2_base_name"_fxd_sorted_DupRm_realn_recal_variantannotator_SNP.vcf"
  
   
   	bwa_human_alignment "$output_new"
  	picard_part_processing "$output_new"
        gatk_part_processing "$output_new"
        rename "$output_new" "$fn"
        
   done

#Sepating Tumor files and Normal files
   echo -e "\n" >> $outdir$indicator
   echo "You have Samples total no of samples equal to  ${#uniq_file[@]}, they are: ${uniq_file[@]}" >> $outdir$indicator
   

   for i in "${uniq_file[@]}"
   do
     if [[ $i == *"N"* ]]  #if file name contain "N" goes to array named "normal"
     then
      normal+=($i)
     fi

     if [[ $i == *"T"* ]] #if file name contain "T" goes to array named "tumor"
     then
      tumor+=($i)
     fi
  done

   echo -e "\n\n" >> $outdir$indicator
   echo "You have no of Normal files equal to ${#normal[@]}, they are:${normal[@]}" >> $outdir$indicator
   echo "You have no of Tumor files equal to ${#tumor[@]}, they are :${tumor[@]}" >> $outdir$indicator

  for i in "${normal[@]}"
  do
    n_no=$(echo "$i" | cut -d_ -f2 | tr -dc '0-9') # Extracting the no of normal sample
    for j in "${tumor[@]}"
    do
     t_no=$(echo "$j" | cut -d_ -f2 | tr -dc '0-9') #Extracting the no of tumor sample
     if [[ $n_no == $t_no ]]
     then
        pair_n+=($i) # pair_n is a array which contain the all pair normal sample 
        pair_t+=($j) # pair_t is a array which contain the all pair tumor sample
        pair+=($i","$j) #pair is a array which contain the name of tumor and normal in a single cell
     fi
    done

  done
   
   echo -e "\n\n" >> $outdir$indicator
   echo "You have no of pair samples equal to ${#pair[@]}, they are :${pair[@]}" >> $outdir$indicator
   echo "You have no of normal sample from pair equal to ${#pair_n[@]}, they are:${pair_n[@]}" >> $outdir$indicator
   echo "You have no of tumor sample from pair equal to ${#pair_t[@]}, they are:${pair_t[@]}" >> $outdir$indicator




   unpair_t="${tumor[*]}"
   for item in ${pair_t[@]}; do
   	unpair_t=${unpair_t/${item}/} # Removing pair_t data from tumor data
   done

   unpair_n="${normal[*]}"
   for item in ${pair_n[@]}; do

	unpair_n=${unpair_n/${item}/} #Removing pair_n data from normal data
   done
	
	echo -e "\n\n" >> $outdir$indicator
	echo "You have unpair tumor samples:${unpair_t[@]}" >> $outdir$indicator
	echo "You have unpair normal samples:${unpair_n[@]}" >> $outdir$indicator


	echo -e "\n\n" >> $outdir$indicator
	echo "Creating folder variables:" >> $outdir$indicator
	   GATK="GATK_VCF_FOLDER""/" 
	   paired="paired""/"
	   unpaired="unpaired""/"
	   Indel="Indel""/"
	   SNP="SNP""/"
	   NORMAL="Normal""/"
	   MuTect="MuTect""/"
	   Mutect_p="MuTect_p""/"
	   Mutect_up="MuTect_up""/"
 
   echo -e "\n\n" >> $outdir$indicator
   echo "Now creating Directories for the Downstream analysis:" >> $outdir$indicator
   mkdir $outdir$GATK
   mkdir $outdir$GATK$paired
   mkdir $outdir$GATK$paired$Indel
   mkdir $outdir$GATK$paired$SNP
   mkdir $outdir$GATK$unpaired
   mkdir $outdir$GATK$unpaired$Indel
   mkdir $outdir$GATK$unpaired$SNP
   mkdir $outdir$GATK$unpaired$NORMAL
   mkdir $outdir$GATK$unpaired$NORMAL$Indel
   mkdir $outdir$GATK$unpaired$NORMAL$SNP
   mkdir $outdir$MuTect

   echo -e "\n" >> $outdir$indicator
   echo "Displaying the Path of the folder created:" >> $outdir$indicator
   echo -e "\n\n" >> $outdir$indicator

   echo "Directory Created:$outdir$GATK" >> $outdir$indicator
   echo "Directory Created:$outdir$GATK$paired" >> $outdir$indicator
   echo "Directory Created:$outdir$GATK$paired$Indel" >> $outdir$indicator
   echo "Directory Created:$outdir$GATK$paired$SNP" >> $outdir$indicator
   echo "Directory Created:$outdir$GATK$unpaired" >> $outdir$indicator
   echo "Directory Created:$outdir$GATK$unpaired$Indel" >> $outdir$indicator
   echo "Directory Created:$outdir$GATK$unpaired$SNP" >> $outdir$indicator
   echo "Directory Created:$outdir$GATK$unpaired$NORMAL" >> $outdir$indicator
   echo "Directory Created:$outdir$GATK$unpaired$NORMAL$Indel" >> $outdir$indicator
   echo "Directory Created:$outdir$GATK$unpaired$NORMAL$SNP" >> $outdir$indicator
   echo "Directory Created:$outdir$MuTect" >> $outdir$indicator

   echo "Spliting the pair data to separate normal and tumor files:" >> $outdir$indicator

   for pa in ${pair[*]};
   do
	    pa_n=$(echo $pa | cut -d, -f1)
	    pa_t=$(echo $pa | cut -d, -f2)
            output_pa_n=$outdir$pa_n"/"
            output_pa_t=$outdir$pa_t"/"
               mutect_analysis "$output_pa_n" "$output_pa_t" "$pa_n" "$pa_t" #Calling mutect analysis function for pair samples
            pan+=($pa_n)
            pat+=($pa_t)
  done

  for up in ${unpair_t[@]};
  do
	     output_up=$outdir$up"/"
	     unpair_mutect_analysis "$output_up" "$up" #Calling mutect analysis function for unpair samples 
  done

  echo -e "\n" >> $outdir$indicator
  echo "Displaying all pair Normal:${pan[@]}" >> $outdir$indicator
  echo "Displaying all pair Tumor:${pat[@]}" >> $outdir$indicator
  
  
  for i in ${pan[@]};
	   do
	    file=$(find $outdir$i"/" -type f -name "*_realn_recal_INDEL.vcf")
	    cp "$file" "$outdir$GATK$paired$Indel"
 	   done

  for i in ${pat[@]};
	   do
	    file=$(find $outdir$i"/" -type f -name "*_realn_recal_INDEL.vcf")
	    cp $file $outdir$GATK$paired$Indel
	   done
  
  for i in ${pat[@]};
	   do
	    file=$(find $outdir$i"/" -type f -name "*_fxd_sorted_DupRm_realn_recal.mutect.vcf")
	    cp $file $outdir$MuTect
	   done


  for i in ${pan[@]};
	  do
	    file=$(find $outdir$i"/" -type f -name "*_realn_recal_variantannotator_SNP.vcf")
	    cp $file $outdir$GATK$paired$SNP
	  done

  for i in ${pat[@]}; 
	  do
	    file=$(find $outdir$i"/" -type f -name "*_realn_recal_variantannotator_SNP.vcf")
	    cp $file $outdir$GATK$paired$SNP
	  done

  for i in ${normal[@]};
	  do
	    file=$(find $outdir$i"/" -type f -name "*_realn_recal_INDEL.vcf")
	    cp $file $outdir$GATK$unpaired$NORMAL$Indel
	  done

  for i in ${normal[@]};
	  do
	    file=$(find $outdir$i"/" -type f -name "*_realn_recal_variantannotator_SNP.vcf")
	    cp $file $outdir$GATK$unpaired$NORMAL$SNP
	  done


  for i in ${unpair_t[@]};
	  do
	    file=$(find $outdir$i"/" -type f -name "*_realn_recal_INDEL.vcf")
	    cp $file $outdir$GATK$unpaired$Indel
	  done

  for i in ${unpair_t[@]};
	  do
	    file=$(find $outdir$i"/" -type f -name "*_realn_recal_variantannotator_SNP.vcf")
	    cp $file $outdir$GATK$unpaired$SNP
	  done
  
  for i in ${unpair_t[@]};
	  do
	    file=$(find $outdir$i"/" -type f -name "*_fxd_sorted_DupRm_realn_recal.mutect.vcf")
	    cp $file $outdir$MuTect
	  done

  echo -e "\n\n" >> $outdir$indicator
  echo "Transferring data of \"$outdir\" to next module" >> $outdir$indicator
  echo "Transferring data of \"$GATK\" to next module" >> $outdir$indicator
  echo "Transferring data of \"$paired\" to next module" >> $outdir$indicator
  echo "Transferring data of \"$unpaired\" to next module" >> $outdir$indicator
  echo "Transferring data of \"$NORMAL\" to next module" >> $outdir$indicator
  echo "Transferring data of \"$Indel\" to next module" >> $outdir$indicator
  echo "Transferring data of \"$SNP\" to next module" >> $outdir$indicator
  echo "transferring data of \"$MuTect\" to next module" >> $outdir$indicator

echo -e "Second module with the command" >> $outdir$indicator


if [ ${#normal[@]} -eq 0 ]; then
  echo -e "\n" >> $outdir$indicator
	echo "Your sample set has normal" >> $outdir$indicator
  echo -e "Second module with the command" >> $outdir$indicator
  echo "./karan_second_up.sh --$config --$outdir --$GATK --$paired --$unpaired --$NORMAL --$Indel --$SNP --$MuTect --$indicator --$uniq_files" >> $outdir$indicator
  
  ./wexome_second_up.sh $config $outdir $GATK $paired $unpaired $NORMAL $Indel $SNP $MuTect $indicator "${uniq_file[@]}"
  
else
	echo -e "\n" >> $outdir$indicator
	echo "Your sample set has normal" >> $outdir$indicator
  echo -e "Second module with the command" >> $outdir$indicator
  echo "./karan_second.sh --$config --$outdir --$GATK --$paired --$unpaired --$NORMAL --$Indel --$SNP --$MuTect --$indicator --$uniq_files" >> $outdir$indicator
  
  ./wexome_second.sh $config $outdir $GATK $paired $unpaired $NORMAL $Indel $SNP $MuTect $indicator "${uniq_file[@]}"	
fi

