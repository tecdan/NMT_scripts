#!/bin/bash
source activate latest

src=en
tgt=zh

echo "this is to replace &amp; with only &"
echo "--------------------start-----------------------------------------"
for lang in $src $tgt
do

for item in ted.train.$lang ted.valid.$lang ted.tst2010.$lang ted.tst2011.$lang ted.tst2012.$lang ted.tst2013.$lang ted.tst2014.$lang ted.tst2015.$lang
do
sed -i "s/&amp;/\&/g" $item
done
rm ted.tst.10-15
cat ted.tst2010.$lang ted.tst2011.$lang ted.tst2012.$lang ted.tst2013.$lang ted.tst2014.$lang ted.tst2015.$lang >> ted.tst.10-15.$lang

done

echo "--------------------done-----------------------------------------"
