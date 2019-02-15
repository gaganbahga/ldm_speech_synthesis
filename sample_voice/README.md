There are two types of features which need to be prepared: text features which form the input features during generation and acoustic features which are the features generated at output during generation. We familiarize with all the end-features and some of the intermediate representations using one example from nick hurricane voice. As all the steps are using Merlins frontend, we do not list the steps, rather just the end products of some of the steps.
As a side note, we observed that the speech in the nick hurricane was surrounded by lots of silence in the beginning and ending of the audio files so we trimmed those silences to a reasonable amount. 

### Input features : Festival phonetic transcriptions

Merlin under the hood uses Festival's front end to create the phonetic transcriptions. We need to use an appropriate dictionary according to the accent of the voice to create phonetic transcriptions. We used unilex dictionary with rpx phoneset in training with nick voice.

We start off with the text transcription of the utterances. An example is in `data/text/utts.data`. They are stored in this format:
```
(file_name_1 "An example utterance.")
(file_name_2 "Another sentence of dataset.")
```
In order to get festival to transcribe these, they listed out in terms of commands to festival. An example is in `data/text/utts.scm` 
The file is of the form:
```
(utt.save (utt.synth (Utterance Text "An example utterance." )) "./data/text/prompt-utt/file_id.utt")
```
After further processing, we get mono and full phonetic transcriptions of each the files. The examples are in `alignment/mono/001.lab` and `alignment/full/001.lab` respectively.

HMMs are used to align the phonetic labels with the time stamps for each of the phones. First, MFCCs are extracted using SPTK on which HMMs are trained. An example is `alignment/mfcc/001.mfcc` generated from `data/trim/001.wav`. After training the HMMs and transfering the time stamps, we obtain subphone phone states (HMM states) aligned with time stamps. Example is in `label_state_align/001.lab`.

### Output features : World analysis

The output features generated using World analysis are mel-generalized coefficients (MGCs), band-aperiodicity coefficients (BAPs) and log-fundamental frequency (lf0). These are present in `data/mgc`, `data/bap` and `data/lf0` respectively.
