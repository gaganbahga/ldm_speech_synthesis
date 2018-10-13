## Running the TTS

We use the voice created in ../nick_voice to train the LDM based TTS.
ldm_tts contains all the scripts to run the parameter genertion using LDMs.
The master script that calls all the functions is trainldmtts.m
All the parameters are set in getparameters.m
After training the models, the generated output features are stored ../nick_voice/synthesis

nick_voice contains the input linguistic features as well as output acoustic features
label_state_align contains the alignment files which include the full state labels as well as the durations for each utterance. data contains the output features for each utterance.

In order to generate the speech waveform from the output acoutic features, 
```bash
cd nick_voice/synthesis
scripts/synthesize.sh mcep_directory wav_directory [f0_directory bap_directory]
```

To find the raw PESQ scores: 
```bash
scripts/score_pesq.sh wav_directory
```
This will generate a file with name : wav_directory.txt which conatins the PESQ scores for all the utterances
```bash
python3 scripts/mean_pesq.py wav_directory.txt
```
will provide the mean pesq score 

You might have to change some paths in the whole process, especially in the voice preparation or waveform generation. LDM training should be okay more or less.

Some of the scripts start with the comment `% rough script` which means they are not a part of the regular source code
