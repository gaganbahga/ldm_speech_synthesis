# LDM speech synthesis

Speech synthesis using Linear Dynamical Models (LDMs).

The task is broken down into two components:
1. Preparing the dataset: Given a dataset which consists of audio utterances along with their transcriptions, we process the data to be used for training our speech synthesis models. [Merlin](https://github.com/CSTR-Edinburgh/merlin)'s front end is a great tool for preprocessing the data.
2. Training the LDMs using the processed data.

### Tools required
We used [Nick corpus](http://www.cstr.ed.ac.uk/projects/hurricane/1/index.html) for Hurricane Challenge as our dataset. In order to use this dataset, you need to accept the [license](http://www.cstr.ed.ac.uk/projects/hurricane/1/license.html) and obtain a password first. We use the 'plain' (not lombard) news sentences (named herald_xxx) and the 'plain' Harvard sentences (hvd_xx) of this corpus. However, there are other open-source datasets available which can be used here as well. If you want a dataset without any license issues, [CMU SLT arctic dataset](http://www.festvox.org/cmu_arctic/dbs_slt.html) would be good starting point. It is however a relatively small dataset. [LJ speech](https://keithito.com/LJ-Speech-Dataset/) is a pretty large dataset for TTS.
To prepare the dataset the following tools are used:
1. Festival with unilex lexicon : We use [festival](http://www.cstr.ed.ac.uk/projects/festival/) as a front-end to get phonetic transcriptions from text. Since the speaker for the dataset is an English speaker, we use unilex [lexcion](http://www.cstr.ed.ac.uk/projects/unisyn/) to transcribe rather than the default CMU lexicon. This lexicon is again available only after a [license](http://www.cstr.ed.ac.uk/projects/unisyn/license.html).
2. [HMM Toolkit (HTK)](http://htk.eng.cam.ac.uk/download.shtml) : We use HTK to align the phonetic transcriptions with their position in the audio utterance. You might encounter a [bug](https://github.com/JoFrhwld/FAVE/wiki/HTK-3.4.1) in the source code that needs to be fixed.
3. [speech signal processing toolkit (SPTK)](http://sp-tk.sourceforge.net/) : We use SPTK for signal processing of audio data.
4. [World vocoder](https://github.com/mmorise/World): We use World vocoder to create the output acoustic features. In order to do analysis and synthesis of utterances, we use the [binaries compiled in Merlin](https://github.com/CSTR-Edinburgh/merlin/tree/master/tools/WORLD). After compiling the code provided there, we end up with two binaries analysis and synth which perform those two tasks respectively.

The LDMs are trained using Matlab

The front-end preprocessing can be done using Merlin, so we do not duplicate that here. The steps to preprocessing can be understood using this [tutorial](http://www.speech.zone/exercises/build-your-own-dnn-voice/). The sample_voice directory contains one example file from nick voice which has been processed to extract all the required features so that you may have a fair idea what do all the features look like. The LDM-TTS code is in ldm_tts directory. Please refer their individual README.md files in both the subdirectories..

To evalute the the generated speech, we use [PESQ measure](https://www.itu.int/rec/T-REC-P.862/en).

### Author

*Gagandeep Singh* 
