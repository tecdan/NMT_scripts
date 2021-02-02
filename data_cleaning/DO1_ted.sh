#!/bin/bash
source activate latest

src=en
tgt=zh
basedir=/project/student_projects2/dhe/BERT/cleaned-data/
rm output.txt

echo "cp data" | tee -a output.txt
for lang in $src $tgt
do
for item in ted.train ted.valid ted.tst2010 ted.tst2011 ted.tst2012 ted.tst2013 ted.tst2014 ted.tst2015 
do
cp $basedir/ted/$item.$lang  $basedir/all-data/
done
done
echo "cp data done" | tee -a output.txt
echo $'\n'| tee -a output.txt


for item in ted.train ted.valid ted.tst2010 ted.tst2011 ted.tst2012 ted.tst2013 ted.tst2014 ted.tst2015 
do
for lang in $src $tgt
do
# 英文中文的反括号 在句首
sed -i "s/^）/ /g" $item.$lang
sed -i "s/^)/ /g" $item.$lang
sed -i "s/^]/ /g" $item.$lang
sed -i "s/^】/ /g" $item.$lang
sed -i "s/^?/ /g" $item.$lang
sed -i "s/^？/ /g" $item.$lang
done
done



#for item in ted.train ted.valid ted.test um.train um.valid cwmt news opensub general un
for item in ted.train ted.valid ted.tst2010 ted.tst2011 ted.tst2012 ted.tst2013 ted.tst2014 ted.tst2015 
do
echo "-------------start to process data $item -----------" | tee -a output.txt

echo "step1 process lines in zh which havhe no zh characters" | tee -a output.txt
cat $item.zh | grep -n "^[^$(echo -en '\u4e00')-$(echo -en '\u9fa5')]*$" > non_zh_lines
cat non_zh_lines |sed "s/:/ : /g" > non_zh_lines_with_space
cat non_zh_lines_with_space| awk '{print $1}' > non_zh_nums


tac non_zh_nums > inverse_nums
echo "the num of lines we need to process:"
echo $(wc -l inverse_nums)
m=0


while [ -s inverse_nums ] 
do
        num_batch=$(head -10000 inverse_nums | tr '\n' ' ' | sed 's/ /d;/g')
        sed -i "$num_batch" $item.zh
        sed -i "$num_batch" $item.en
        sed -i "1,10000d" inverse_nums
        m=$((m + 1))
        echo "the $m batch done"  | tee -a output.txt

done
rm non_zh_lines
rm non_zh_lines_with_space
rm non_zh_nums
rm inverse_nums
echo $'\n' | tee -a output.txt


echo "step2 process lines in en indcling only non en characters" | tee -a output.txt
cat $item.en | grep -n "^[^a-zA-Z0-9]*$" > non_en_lines
cat non_en_lines |sed "s/:/ : /g" > non_en_lines_with_space
cat non_en_lines_with_space| awk '{print $1}' > non_en_nums


tac non_en_nums > inverse_nums
echo "the num of lines we need to process:"  | tee -a output.txt
echo $(wc -l inverse_nums)   | tee -a output.txt

m=0
while [ -s inverse_nums ] 
do
        num_batch=$(head -10000 inverse_nums | tr '\n' ' ' | sed 's/ /d;/g')
        sed -i "$num_batch" $item.zh
        sed -i "$num_batch" $item.en
        sed -i "1,10000d" inverse_nums
        m=$((m + 1))
        echo "the $m batch done"
done
rm non_en_lines
rm non_en_lines_with_space
rm non_en_nums
rm inverse_nums
echo $'\n' | tee -a output.txt


sed -i "s/[ ][ ]*/ /g" $item.zh
sed -i "s/^[ ][ ]*//g" $item.zh
sed -i "s/[ ][ ]*$//g" $item.zh

sed -i "s/[ ][ ]*/ /g" $item.en
sed -i "s/^[ ][ ]*//g" $item.en
sed -i "s/[ ][ ]*$//g" $item.en

echo "step3  delete empty lines in zh " | tee -a output.txt
cat $item.zh | grep -n "^[ ]*$" > empty_zh_lines
cat empty_zh_lines |sed "s/:/ : /g" > empty_zh_lines_with_space
cat empty_zh_lines_with_space| awk '{print $1}' > empty_zh_nums

tac empty_zh_nums > inverse_nums
echo "the num of lines we need to process:" | tee -a output.txt

echo $(wc -l inverse_nums) | tee -a output.txt
m=0
while [ -s inverse_nums ] 
do
        num_batch=$(head -10000 inverse_nums | tr '\n' ' ' | sed 's/ /d;/g')
        sed -i "$num_batch" $item.zh
        sed -i "$num_batch" $item.en
        sed -i "1,10000d" inverse_nums
        m=$((m + 1))
        echo "the $m batch done"  | tee -a output.txt
done
rm empty_zh_lines
rm empty_zh_lines_with_space
rm empty_zh_nums
rm inverse_nums
echo $'\n' | tee -a output.txt


echo "step4  delete empty lines in en " | tee -a output.txt
cat $item.en | grep -n "^[ ]*$" > empty_en_lines
cat empty_en_lines |sed "s/:/ : /g" > empty_en_lines_with_space
cat empty_en_lines_with_space| awk '{print $1}' > empty_en_nums

tac empty_en_nums > inverse_nums
echo "the num of lines we need to process:" | tee -a output.txt

echo $(wc -l inverse_nums) | tee -a output.txt
m=0
while [ -s inverse_nums ] 
do
        num_batch=$(head -10000 inverse_nums | tr '\n' ' ' | sed 's/ /d;/g')
        sed -i "$num_batch" $item.zh
        sed -i "$num_batch" $item.en
        sed -i "1,10000d" inverse_nums
        m=$((m + 1))
        echo "the $m batch done"  | tee -a output.txt

done
rm empty_en_lines
rm empty_en_lines_with_space
rm empty_en_nums
rm inverse_nums
echo $'\n' | tee -a output.txt



echo "step5 delete lines in zh including only one character and its not zh" | tee -a output.txt
cat $item.zh | grep -n "^[^$(echo -en '\u4e00')-$(echo -en '\u9fa5')]$"  > one_char_zh_lines
cat one_char_zh_lines |sed "s/:/ : /g" > one_char_zh_lines_with_space
cat one_char_zh_lines_with_space| awk '{print $1}' > one_char_zh_nums

tac one_char_zh_nums > inverse_nums
echo "the num of lines we need to process:" | tee -a output.txt

echo $(wc -l inverse_nums) | tee -a output.txt
m=0
while [ -s inverse_nums ] 
do
        num_batch=$(head -10000 inverse_nums | tr '\n' ' ' | sed 's/ /d;/g')
        sed -i "$num_batch" $item.zh
        sed -i "$num_batch" $item.en
        sed -i "1,10000d" inverse_nums
        m=$((m + 1))
        echo "the $m batch done"  | tee -a output.txt
done
rm one_char_zh_lines
rm one_char_zh_lines_with_space
rm one_char_zh_nums
rm inverse_nums
echo $'\n' | tee -a output.txt


echo "step6 delete lines in en including only one character" | tee -a output.txt
cat $item.en | grep -n "^.$" > one_char_en_lines
cat one_char_en_lines |sed "s/:/ : /g" > one_char_en_lines_with_space
cat one_char_en_lines_with_space| awk '{print $1}' > one_char_en_nums

tac one_char_en_nums > inverse_nums
echo "the num of lines we need to process:" | tee -a output.txt

echo $(wc -l inverse_nums) | tee -a output.txt
m=0
while [ -s inverse_nums ] 
do
        num_batch=$(head -10000 inverse_nums | tr '\n' ' ' | sed 's/ /d;/g')
        sed -i "$num_batch" $item.zh
        sed -i "$num_batch" $item.en
        sed -i "1,10000d" inverse_nums
        m=$((m + 1))
        echo "the $m batch done"  | tee -a output.txt
done
rm one_char_en_lines
rm one_char_en_lines_with_space
rm one_char_en_nums
rm inverse_nums
echo $'\n' | tee -a output.txt

echo "step7 replace &amp; with &" | tee -a output.txt
sed -i "s/&amp;/\&/g" $item.zh
sed -i "s/&amp;/\&/g" $item.en

echo "-------------process data $item done-----------" | tee -a output.txt
echo $'\n' | tee -a output.txt
done

for lang in $src $tgt
do
if [ -f "ted.tst.10_15.$lang" ];then
echo "ted.tst.10_15.$lang already exits, we delete it before merging"
rm ted.tst.10_15.$lang
else
echo "ted.tst.10_15.$lang doesn't exit"
fi

for tst in  ted.tst2010 ted.tst2011 ted.tst2012 ted.tst2013 ted.tst2014 ted.tst2015 
do
cat $tst.$lang >> ted.tst.10_15.$lang
done
for item in ted.train ted.valid ted.tst2010 ted.tst2011 ted.tst2012 ted.tst2013 ted.tst2014 ted.tst2015 ted.tst.10_15
do
cp $item.$lang $basedir/ted/$item.$lang.clean
done
done
