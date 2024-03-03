  echo -e "\n\n"
  echo "Congratulation You are now started third module of waterhose"
  echo "............................................................"

  config=$1
  outdir=$2
  GATK_SNP_Indel_mutect=$3
  merged=$4
  file_key=$5
  indicator=$6

  echo $outdir
  echo $GATK_SNP_Indel_mutect
  echo $merged
  echo $file_key
  echo $outdir$GATK_SNP_Indel_mutect$merged$file_key
  
  perl reccurence.pl $outdir$GATK_SNP_Indel_mutect$merged$file_key
  perl database_annotation.pl $outdir$GATK_SNP_Indel_mutect$merged$file_key
  
  recurrent_database_annotation="recurrent_database_annotation"
  recurrent_database_annotation_maf="recurrent_database_annotation.maf"
  corrected_recurrent_database_annotation_maf="corrected_recurrent_database_annotation.maf"
  
  statistics="statistics""/"
  onco="oncotator""/"
  mutsigcv="mutsigcv""/"
  alldatabases="alldatabases""/"
  novelandcosmic="novelandcosmic""/"
  onlynovel="onlynovel""/"
   
  mkdir $outdir$statistics
  mkdir $outdir$statistics$onco
  mkdir $outdir$statistics$mutsigcv
  mkdir $outdir$statistics$alldatabases
  mkdir $outdir$statistics$novelandcosmic
  mkdir $outdir$statistics$onlynovel
  
  echo -e "\n\n"
  oncotator=$(egrep '^oncotator' $config |cut -f 2 -d "=")
  candra=$(egrep '^candra' $config |cut -f 2 -d "=")
  dbNSFP=$(egrep '^dbNSFP' $config |cut -f 2 -d "=")
  
  echo "$oncotator"
  echo  "python oncotator -v --input_format MAFLITE --db-dir /opt/ngs_softwares/oncotator-1.8.0.0/oncotator_v1_ds_Jan262014/ --output_format=TCGAMAF $outdir$statistics$onco$recurrent_database_annotation $outdir$statistics$onco$recurrent_database_annotation_maf hg19"
 
  oncotator -v --input_format MAFLITE --db-dir /opt/ngs_softwares/oncotator-1.8.0.0/oncotator_v1_ds_Jan262014/ --output_format=TCGAMAF $outdir$GATK_SNP_Indel_mutect$merged$file_key$recurrent_database_annotation $outdir$statistics$onco$recurrent_database_annotation_maf hg19
  
  perl -pe 's/\t(?=\t|$)/\tNULLL/g' $outdir$statistics$onco$recurrent_database_annotation_maf > $outdir$statistics$onco$corrected_recurrent_database_annotation_maf

  sed -i 's/ /_/g' $outdir$statistics$onco$corrected_recurrent_database_annotation_maf



#reports
  reports="reports""/"
  mkdir $outdir$reports
  
# Extracting individual tumor data from recurrent file


  sample_list=($(cat $outdir$statistics$onco$corrected_recurrent_database_annotation_maf | cut -f 194 | egrep -v '\,' |sort |uniq))
  echo "${sample_list[@]}"
  for i in ${sample_list[*]}
   
  do
    while IFS=$'\t' read -r -a element
    do
      chr=${element[193]}

     if [ "$chr" == "$i" ] || [[ "$chr" =~ .*\,"$i"\,.* ]] || [[ "$chr" =~ ^"$i"\,.* ]] || [[ "$chr" =~ .*\,"$i"$ ]]; then
         ( IFS=$'\t'; echo ${element[@]} >> $outdir$statistics$alldatabases$i".txt")
     fi
    done < $outdir$statistics$onco$corrected_recurrent_database_annotation_maf
  done

  sed -i 's/ /\t/g' $outdir$statistics$alldatabases*.txt

# Counting cosmic, dbsnp, cosmic+dbsnp, novel entries for individual tumor
   COSMIC_DBSNP_INFO="COSMIC_DBSNP_INFO.info"

   for f in $(find $outdir$statistics$alldatabases* -name "*.txt" -type f ); 
   do
      sample=$(basename $f);
	    sample_name="${sample%.*}"
      awk -v file="$sample_name" -F'\t' 'BEGIN{novel=0; cosmic=0; dbsnp=0; mylab=0; cosdb=0; cosmy=0; dbmy=0; cosdbmy=0} 
         {if($123 ~ /-/ && $281 ~ /-/ && $192 ~ /-/) novel++;
          else if($123 !~ /-/ && $281 ~ /-/ && $192 ~ /-/) cosmic++; 
          else if($123 ~ /-/ && $281 !~ /-/ && $192 ~ /-/) dbsnp++;
          else if($123 ~ /-/ && $281 ~ /-/ && $192 !~ /-/) mylab++;
          else if($123 !~ /-/ && $281 !~ /-/ && $192 ~ /-/) cosdb++;
          else if($123 !~ /-/ && $281 ~ /-/ && $192 !~ /-/) cosmy++;
          else if($123 ~ /-/ && $281 !~ /-/ && $192 !~ /-/) dbmy++;
          else if($123 !~ /-/ && $281 !~ /-/ && $192 !~ /-/) cosdbmy++;}
    
    END{print "Sample Name=""\t"file
        print "Total number of variants=""\t"novel+cosmic+dbsnp+mylab+cosdb+cosmy+dbmy+cosdbmy;
        print "Novel entries=""\t"novel;
        print "Exclusive Cosmic entries=""\t"cosmic;
        print "Exclusive DBsnp entries=""\t"dbsnp;
        print "Exclusive MyLAB entries=""\t"mylab;
        print "Cosmic+DBsnp common entries=""\t"cosdb;
        print "Cosmic+MyLAB common entries=""\t"cosmy;
        print "DBsnp+MyLAB common entries=""\t"dbmy;
        print "Cosmic+DBsnp+MyLAB common entries=""\t"cosdbmy;
        print "Total Cosmic entries=""\t"cosmic+cosdb+cosmy+cosdbmy"\n";
       }' < $f >> $outdir$statistics$alldatabases$COSMIC_DBSNP_INFO
   done


###################################### all types of mutations calculations
   
  alldatabases_statistics="alldatabases_statistics"
  perl statistics.pl $outdir$statistics$alldatabases $outdir$reports$alldatabases_statistics 
   
## Extracting Cosmic and novel information for individual tumor
 
  for f in $(find $outdir$statistics$alldatabases* -name "*.txt" -type f ); 
  do
    sample=$(basename $f);
	  sample_name="${sample%.*}"
    awk -F'\t'  '{if($123 ~ /-/ && $281 ~ /-/ && $192 ~ /-/) print $0; 
              else if($123 !~ /-/ && $281 ~ /-/ && $192 ~ /-/) print $0;
              else if($123 !~ /-/ && $281 !~ /-/ && $192 ~ /-/) print $0;
              else if($123 !~ /-/ && $281 ~ /-/ && $192 !~ /-/) print $0;
              else if($123 !~ /-/ && $281 !~ /-/ && $192 !~ /-/) print $0;
             }' < $f >> $outdir$statistics$novelandcosmic$sample_name"_novel_cosmic.txt"
  done


###################################### Into cosmic and novel we make table of all types of mutations calculations
  
  novelandcosmic_statistics="novelandcosmic_statistics"
  perl statistics.pl $outdir$statistics$novelandcosmic $outdir$reports$novelandcosmic_statistics


## Extracting Cosmic and novel information for individual tumor

for f in $(find $outdir$statistics$alldatabases* -name "*.txt" -type f ); 
do
  sample=$(basename $f);
	sample_name="${sample%.*}"
awk -F'\t'  '{if($123 ~ /-/ && $281 ~ /-/ && $192 ~ /-/) print $0; 
              else if($123 !~ /-/ && $281 ~ /-/ && $192 ~ /-/) print $0;
              else if($123 !~ /-/ && $281 !~ /-/ && $192 ~ /-/) print $0;
              else if($123 !~ /-/ && $281 ~ /-/ && $192 !~ /-/) print $0;
              #else if($123 !~ /-/ && $281 !~ /-/ && $168 !~ /-/) print $0;
             }' < $f >> $outdir$statistics$onlynovel$sample_name"_novel_cosmic.txt"
done


###################################### Into cosmic and novel we make table of all types of mutations calculations
  
  onlynovel_statistics="onlynovel_statistics"
  perl statistics.pl $outdir$statistics$onlynovel $outdir$reports$onlynovel_statistics
  transition_transversion="transition_transversion"
  perl tran_tranvs.pl $outdir$statistics$novelandcosmic $outdir$reports$transition_transversion 

  #prioritisation folder created 
  prioritisation="prioritisation""/"
  dbNSFP_f="dbNSFP""/"
  candra_f="candra""/"
    
  mkdir $outdir$prioritisation
  mkdir $outdir$prioritisation$dbNSFP_f
  mkdir $outdir$prioritisation$candra_f
  
  
  perl simple_maf.pl $outdir$statistics$onco $outdir$prioritisation
  perl dbNSFP_input.pl $outdir$statistics$onco $outdir$prioritisation$dbNSFP_f
  perl candra_input.pl $outdir$statistics$onco $outdir$prioritisation$candra_f
  
  #run candra
  candra_input="candra_input"
  candra_output="candra_output"
  path=`pwd`
  cd $candra
  perl open_candra.pl GENERAL $outdir$prioritisation$candra_f$candra_input > $outdir$prioritisation$candra_f$candra_output
  cd $path

  #run dbNSFP
  dbNSFP_input="dbNSFP_input"
  dbNSFP_output="dbNSFP_output"
  path1=`pwd`
  cd $dbNSFP
  java search_dbNSFP24 -i $outdir$prioritisation$dbNSFP_f$dbNSFP_input -o $outdir$prioritisation$dbNSFP_f$dbNSFP_output
  cd $path1     
  
  perl dbNSFP_parser.pl $outdir$prioritisation$dbNSFP_f
  
  prediction_score_specific="prediction_score_specific"
  simple_maf="simple_maf"
  merged_new="merged_new"
  
  #reports
  #reports="reports""/"
  #mkdir $outdir$reports
  
  join -1 2 -2 1 -a 1 -e 0 -o 1.1,1.2,1.3,1.4,1.5,1.6,1.7,1.8,1.9,1.10,1.11,1.12,1.13,1.14,2.2 <(sort -k2,2 <(nl -ba -nrz $outdir$prioritisation$simple_maf)) <(sort -k1,1 $outdir$prioritisation$dbNSFP_f$prediction_score_specific) | sort -k1,1n | cut -d\  -f2- | sed 's/ /\t/g' > $outdir$reports$merged_new

  
  perl heat_waterhose.pl $outdir$reports  
  perl gene_heat_map.pl $outdir$reports

