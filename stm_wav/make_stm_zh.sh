
#!/bin/bash
# get all filename in specified path

path1=/project/iwslt2014c/EN/student_projects/yzhu/data/aidatatang_200zh/corpus/train/
files1=$(ls $path1)

rm  bigfilenames.train.txt  smallfilenames.train.txt  train.stm

echo "~~~~~~~~~start~~~~~~~~~~~~~"
for bigfile in $files1
do
    echo $bigfile >> bigfilenames.train.txt
    path2=$path1$bigfile
    bigfiles=$(ls $path2/*trn)
    for smallfile in $bigfiles
    do
        echo $smallfile  >> smallfilenames.train.txt
        echo $smallfile | awk -F/ '{print $NF}' | sed 's/\.trn$//g' | tr "\n" " "  >> train.stm
        echo $smallfile | awk -F/ '{print $NF}' | sed 's/\.trn$//g' | tr "\n" " "  >> train.stm
        echo "0.0 0.0"  | tr "\n" " "  >> train.stm
        echo $(cat  $smallfile)  >>  train.stm

    done
    echo "finishing files in $bigfile"
    
done
echo "~~~~~~~~~done~~~~~~~~~~~~~"
