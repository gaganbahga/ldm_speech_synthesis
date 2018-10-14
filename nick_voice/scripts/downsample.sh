#!/bin/bash

# used to change sampling rate and resolution of the audio files
# here converts to 16 bit at 16kHz
wav_dir=wav
record_dir=recordings

for file in $record_dir/*.wav
do
    filename="${file##*/}"
    echo "converting file ${filename}"
    sox $record_dir/$filename -b 16 -r 16000 $wav_dir/$filename 
    
done
    
echo All finished

