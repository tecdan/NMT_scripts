#!/bin/bash
source activate latest

teddir=/project/student_projects2/dhe/BERT/cleaned-data/all-data
dictdir=bert_vocab_file
bertdir=/home/dhe/hiwi/Exercises/Pretrained_Models_NMT


src=en
tgt=zh

# step1
# bert 不能识别部分中文标点。为了减少”UNK“， 我们替换为英文标点 
echo "------------start copying data and replacing punctions----------"
for item in ted.train ted.valid ted.tst2015 ted.tst2014 ted.tst2013 ted.tst2012 ted.tst2011 ted.tst2010
do
for lang in $src $tgt
do
cat $teddir/$item.$lang > $item.$lang
sed -i "s/$(echo -en '\u2013')/-/g"  $item.$lang
sed -i "s/$(echo -en '\u2014')/-/g"  $item.$lang
sed -i "s/$(echo -en '\u2015')/-/g"  $item.$lang
sed -i "s/$(echo -en '\u2026')/.../g"  $item.$lang
# 双引号
sed -i 's#\“#\"#g' $item.$lang
sed -i 's#\”#\"#g' $item.$lang
# 单引号不能转译 外面用"
sed -i "s/‘/'/g" $item.$lang
sed -i "s/’/'/g" $item.$lang

done
done
echo "------------finish copying data and replacing punctions----------"


#step2
echo $'\n'
echo "-----------------start building the dictionary------------"

python -u $bertdir/pretrain_module/make_plm_dict.py    -plm_src_vocab $dictdir/bert-base-uncased-vocab.txt \
                                   -src_lang $src \
                                   -plm_tgt_vocab  $dictdir/bert-base-chinese-vocab.txt \
                                   -tgt_lang $tgt 

echo "-----------------finish building the dictionary------------"

echo "--------repace cls and sep with bos and eos to avoid confusing in target dictionary-------"

cat bert_word2idx.zh |sed "s/\[CLS\]/<s>/" | sed "s/\[SEP\]/<\/s>/" > my_bert_word2idx.zh
cat bert_word2idx.en |sed "s/\[CLS\]/<s>/" | sed "s/\[SEP\]/<\/s>/" > my_bert_word2idx.en

cat bert_idx2word.zh |sed "s/\[CLS\]/<s>/" | sed "s/\[SEP\]/<\/s>/" > my_bert_idx2word.zh
cat bert_idx2word.en |sed "s/\[CLS\]/<s>/" | sed "s/\[SEP\]/<\/s>/" > my_bert_idx2word.en
echo "-----------------finishing replacing------------------"

# step3
echo $'\n'
echo "-----------------start tokenizing data -----------"
for item in ted.train ted.valid ted.tst2015 ted.tst2014 ted.tst2013 ted.tst2012 ted.tst2011 ted.tst2010
do
python -u $bertdir/pretrain_module/bert_tokenization.py    -src_data $item.en \
                                                           -tgt_data $item.zh
done
echo "-----------------finish tokenizing data -----------"


# step4 因为我们不能在tokenize的时候换掉“[CLS]”, 我们在这里换，仅对en

for item in ted.train ted.valid ted.tst2015 ted.tst2014 ted.tst2013 ted.tst2012 ted.tst2011 ted.tst2010
do

cat $item.en.bert.tok  |sed "s/^\[CLS\]/<s>/g" | sed "s/\[SEP\]$/<\/s>/" > $item.bert.tok.en
cat $item.zh.bert.tok  > $item.bert.tok.zh
done

#step5 搬移到experiment下
echo $'\n'
echo "-----------------start coping data -----------"
exdir=/project/student_projects2/dhe/BERT/experiments/bert_emb_experiments/bert2bert_ted
for lang in $src $tgt
do
cp bert_idx2word.$lang $exdir/saves
cp my_bert_idx2word.$lang $exdir/saves
cp bert_word2idx.$lang $exdir/saves
cp my_bert_word2idx.$lang $exdir/saves
done

for lang in $src $tgt
do
for item in ted.train ted.valid 
do
cp $item.bert.tok.$lang  $exdir/data
done 
done


for lang in $src $tgt
do
for item in ted.tst2015 ted.tst2014 ted.tst2013 ted.tst2012 ted.tst2011 ted.tst2010
do
cp $item.bert.tok.$lang $exdir/data/test
cp $item.$lang  $exdir/data/test
done
done
echo "-----------------finish coping data -----------"

