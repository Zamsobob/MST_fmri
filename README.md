<h1>MST fMRI Study-Test</h1>

This is the repository for the MST study-test phase which will be performed in the fMRI machine. 

<h3>Stimuli</h3>

*Folder Set_1* and *Set_2* contain the images that will be "studied" by as well as the foils and lures that will be shown in MST_test1 and MST_test2. 
Folder Set_4 contains images for the testing phase (MST_study_fmri_practice.py).

*MST_practice_stimuli.xlsx* contain the paths to the practice-stimuli images (Set_4). 

*MST_stimuli_final.xlsx* contain the paths to the stimuli used by MST_study_fmri.py

*MST_stimuli_lurebins2345.xlsx* contains the lure-bins (i.e. difficulty of the lures, 1 being the hardest) for the trial-stimuli. Lure bin 1 is excluded here since those lures are almost indistinguishable from the targets.  

*Stimulus change reasoning.txt* is a text-document explaining why we changed some of the stimulus (arachnophobia and cultural relevance)

*create_MST_stimuli.R* is a script that creates the MST_stimuli_lurebins2345.xlsx file.


*Data/* folder contains save-data from MST_study_fmri.py. These are then moved to the mst_r_scripts repo for actual analysis (seperate since the analysis handles study-test, test1, and test2 data).

**Programs**

*fixation_cross_only.py* is a program that only shows a fixation cross to be used during resting-state fMRI before and after the encoding (study-test) phase. 

*MST_study_fmri_practice.py* contains the practice version of the full MST_study_fmri.py, which is basically a shorter version of the full test. This is to be ran before the full test to give the participants a feel for what they are in for. 


*MST_study_fmri.py* is the actual program the participants will view while in the MRI machine
Right now the stim_dur is set to 3.0s and the fixation-cross varies from 0.5, 1.0, and 1.5s.
