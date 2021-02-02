#!/bin/bash
source activate latest

teddir=/project/student_projects2/dhe/BERT/cleaned-data/all-data
dictdir=roberta_vocab_file
robert_codedir=/home/dhe/hiwi/Exercises/Pretrained_Models_NMT



src=en
tgt=zh

# step1
# roberta 不能识别部分中文标点。为了减少”UNK“， 我们替换为英文标点 
echo "------------start copying data and replacing punctions----------"
for item in ted.train ted.valid ted.tst2015 ted.tst2014  ted.tst2013  ted.tst2012  ted.tst2011  ted.tst2010 
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

# step2 roberta 的英文字典中本来就是<s> 和</s>,中文字典需要处理
cp /project/student_projects2/dhe/BERT/experiments/pytorch_pretrained_models/roberta-base-layer12-en/roberta-base-vocab.txt  roberta-base-vocab-en.txt 
cp /project/student_projects2/dhe/BERT/experiments/pytorch_pretrained_models/roberta-base-layer12-zh/bert-base-chinese-vocab.txt  roberta-base-vocab-zh.txt 


echo "-----------------start building the dictionary------------"
python -u $robert_codedir/pretrain_module/roberta_dict.py    -roberta_src_vocab roberta-base-vocab-en.txt \
                                    -src_lang $src \
                                    -roberta_tgt_vocab  roberta-base-vocab-zh.txt \
                                    -tgt_lang $tgt
 
echo "-----------------finish building the dictionary------------"
 
echo "-----------------start replacing special words in the dictionaries------------------"
# --------英文中已经是<s> </s> 不需要再处理-------
 
 cat roberta_word2idx.zh |sed "s/\[CLS\]/<s>/" | sed "s/\[SEP\]/<\/s>/" > my_roberta_word2idx.zh
 cat roberta_idx2word.zh |sed "s/\[CLS\]/<s>/" | sed "s/\[SEP\]/<\/s>/" > my_roberta_idx2word.zh

# en的处理unk pad, 让中英文保持一致
 cat roberta_word2idx.en |sed "s/<unk>/[UNK]/" |sed "s/<pad>/[PAD]/"   > my_roberta_word2idx.en
 cat roberta_idx2word.en |sed "s/<unk>/[UNK]/" | sed "s/<pad>/[PAD]/"  > my_roberta_idx2word.en
echo "-----------------finishing replacing special words in the dictionaries------------------"



# step3 用en roberta 对en data 做tokenization
echo $'\n'
echo "-----------------start tokenizing data -----------"
for item in ted.train ted.valid ted.tst2015 ted.tst2014 ted.tst2013 ted.tst2012 ted.tst2011 ted.tst2010
do
python -u $robert_codedir/pretrain_module/tokenizeData.py    -src_data $item.en \
                                                            -tgt_data $item.zh 

done
echo "-----------------finish tokenizing data -----------"


# step4  用中文的roberta 对zh data 做 tokenization 



#step5 搬移到experiment目录
echo $'\n'
echo "-----------------start coping data -----------"
exdir=/project/student_projects2/dhe/BERT/experiments/roberta_inienc_experient/roberta_inienc_ted

for lang in $src $tgt
do
cp my_roberta_idx2word.$lang $exdir/saves
cp my_roberta_word2idx.$lang $exdir/saves
done


for lang in $src $tgt
do
for item in ted.train ted.valid 
do
cp $item.$lang.roberta.tok  $exdir/data
done 
cp ted.tst* $exdir/data/test
done
echo "-----------------finish coping data -----------"

