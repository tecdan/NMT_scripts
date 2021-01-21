#!/bin/bash
#audio_dir=/project/iwslt2015/EN/namnguyen/multilingual_data/Europarl/EN/wav
audio_dir=/project/mt2020/project/multilingual_data/Europarl/EN/wav/
audio_dir=./waves/

pynndir=/home/namnguyen/PycharmProjects/nam_pynn/pynn/src/  # pointer to pynn

datadir=$(pwd)/outputs
# export environment variables
export PYTHONPATH=$pynndir
export OMP_NUM_THREADS=2

for item in test dev train
do
echo "Use $item.stm to do feature extraction start"

pythonCMD="python -u -W ignore"
$pythonCMD $pynndir/pynn/bin/wav_stm_to_fbank.py --stm-file  $item.stm  --seg-info  --min-len 10 --jobs 10  --wav-path $audio_dir/$item/ --output $datadir/$item/data

echo "Use $item.stm to do feature extraction done"
done

#$pythonCMD $pynndir/pynn/bin/wav_stm_to_fbank.py --stm-file  $1 --seg-info  --min-len 10 --jobs 10  --wav-path $audio_dir --output $datadir/data


