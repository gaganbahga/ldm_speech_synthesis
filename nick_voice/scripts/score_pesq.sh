degraded_wav_dir=$2
orig_wav_dir=$1
pesq_bin=/w/153/LDM/nick_voice/ITU-T_pesq/bin/pesq

model=$(basename $degraded_wav_dir)

for file in $degraded_wav_dir*.wav
do
	filename=$(basename $file) 
    filename=${filename%.*}
    ref_file=$orig_wav_dir/${filename}.wav
    deg_file=$degraded_wav_dir${filename}.wav

	$pesq_bin +16000 ${ref_file} ${deg_file}
done

#mv ./pesq_results.txt ~/ldm/nick_voice/synthesis/${model}.txt
echo All finished