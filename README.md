# LDM-TTS

Speech synthesis using Linear Dynamical Models (LDMs).

The task is broken down into two components:
1. Preparing the voice
2. Training the LDMs using the voice

### Tools required
We use Nick corpus for Hurricane Challenge http://www.cstr.ed.ac.uk/projects/hurricane/1/index.html as our dataset.
To prepare the voice the following tools are required: 
1. Festival with unilex lexicon : http://www.cstr.ed.ac.uk/projects/festival/ and http://www.cstr.ed.ac.uk/projects/unisyn/
2. HMM Toolkit (HTK) : http://htk.eng.cam.ac.uk/download.shtml which might have a bug in the source code that needs to be fixed https://github.com/JoFrhwld/FAVE/wiki/HTK-3.4.1
3. speech signal processing toolkit (SPTK) : http://sp-tk.sourceforge.net/

We use World vocoder to create the output acoustic features.
The LDMs are trained using Matlab

The voice is provided in nick_voice directory and the LDM-TTS code is in ldm_tts directory. Please refer their individual README.md files.

To evalute the the generated speech, we use PESQ measure. https://www.itu.int/rec/T-REC-P.862/en

## Author

**Gagandeep Singh** 
