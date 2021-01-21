#!/bin/bash
# get all filename in specified path

path0=/project/iwslt2014c/MT/user/yshibata/data/ASR/TRN/Form1/
cp -r $path0/core $path0/core_hd

path1=/project/iwslt2014c/MT/user/yshibata/data/ASR/TRN/Form1/core_hd/
files1=$(ls $path1)



echo "~~~~~~~~~start~~~~~~~~~~~~~"
for trn_file in $files1
do
    
iconv -f SHIFT-JIS -t UTF-8  $path1/$trn_file > test1.txt
sed -e "s/[ ]*\r//g" test1.txt > test2.txt
sed -i '/^%講演ID:/d' test2.txt
sed -i '/^%$/d' test2.txt
sed -i '/^%<SOT>$/d' test2.txt
sed -i '/^%<EOT>$/d' test2.txt
sed -i '/^[0-9]/! s/[ ]*&[ ].*//g' test2.txt
awk 'BEGIN{ORS="";} NR==1 { print; next; } /^[[:digit:]]/ { print "\n"; print; next; } { print; }' test2.txt > test3.txt

rm test1.txt test2.txt
mv test3.txt  $trn_file 


done
echo "~~~~~~~~~done~~~~~~~~~~~~~"


## move the files

path_new=/project/iwslt2014c/MT/user/yshibata/data/ASR/TRN/Form1/core_new/
mkdir -p $path_new
mv  *.trn $path_new/

rm -r $path1

