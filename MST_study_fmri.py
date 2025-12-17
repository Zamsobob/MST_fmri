# MST - STUDY PHASE

from psychopy.gui import DlgFromDict
from psychopy.visual import Window, TextStim, ImageStim
from psychopy.core import Clock, quit, wait
from psychopy.hardware.keyboard import Keyboard
from psychopy import data
import pandas as pd
import os
import random

# --- Participant info dialog ---
exp_info = {'participant': '001'}
dlg = DlgFromDict(exp_info)
if not dlg.OK:
    quit()

# --- Experiment handler for saving data ---
data_dir = "data"
os.makedirs(data_dir, exist_ok=True)

exp = data.ExperimentHandler(
    name='MST',
    version='1.0',
    extraInfo=exp_info,
    savePickle=True,
    saveWideText=True,
    dataFileName=os.path.join(data_dir, f"MST_study_{exp_info['participant']}")
)

# --- Load condition files ---
# Main experiment stimuli (e.g. Sets 1 and 2)
cond_df = pd.read_excel("MST_stimuli_final.xlsx")

# Filter only old_1 and old_2 for the main study loop
study_df = cond_df[cond_df["cond"].isin(["old_1", "old_2"])].sample(n=20) # Set to 20 or so for piloting with coworkers? Delete for actual testing

# TrialHandler for main experiment (created once) 
study_trials = data.TrialHandler(
    trialList=study_df.to_dict('records'), 
    nReps=1,
    method='random',
    name='main'
)

# --- Window and input devices ---
win = Window(fullscr=True, color='white', monitor='laptop', units='height') # Set fullscr=True when actually testing
clock = Clock()
kb = Keyboard()

# Wait for scanner text
wait_for_scanner_txt = TextStim(
    win,
    text='Vänligen vänta',
    font='Calibri',
    color="black",
    height=0.05
)

# Judgment question text (static)
judge_txt = "Inomhus eller utomhus?"
stim_txt = TextStim(win, text=judge_txt, pos=(
    0, 0.4), height=0.07, color='black')

# Fixation cross (reuse same object)
fix_target = TextStim(win, text='+', height=0.07, color='black')

# Image stimulus (we only change image each trial)
stim_img = ImageStim(win, image=None)

# --- Timings ---
t_fix_options = [0.5, 1.0, 1.5]  # fixation cross duration options (ISI jitter)
DEBUG = True  # set to False when done testing


# Wait for scanner trigger (testing: simulate with '5')
kb.clearEvents()
wait_for_scanner_txt.draw()
win.flip()
kb.waitKeys(keyList=['5'])  # simulate scanner trigger

# Reset clock so onsets are relative to scanner start
clock.reset()

for trial in study_trials:
        # trial is now a dict with the same columns as your dataframe
        idx = study_trials.thisN  # 0,1,2,... current trial number
    
        # Path to current image
        image_path = os.path.join(f"Set_{int(trial['set'])}", trial['stim'])

        # Update the ImageStim
        stim_img.image = image_path

        # Response variables
        resp_key = None
        resp_rt = None

        # Timing
        t_fix = random.choice(t_fix_options)   # 0.5–1.5 s fixation
        # stimulus duration (change if you want)
        stim_dur = 3.0
        total_dur = t_fix + stim_dur           # total trial time

        if DEBUG:
            print("\n=== NEW TRIAL ===")
            print("response:", resp_key)
            print("idx:", idx)
            print("trial dict:", trial)
            print("trial duration", trial.get(total_dur))
            print("stim:", trial.get("stim"))
            print("cond:", trial.get("cond"))
            print("set:", trial.get("set", "NA"))
            print("lure_bin:", trial.get("lure_bin", "NA"))
            print("image_path:", image_path)

        # Clear keyboard events and start trial clock
        kb.clearEvents()
        kb.clock.reset()
        trial_clock = Clock()

        # --- Single loop controlling fixation + stimulus ---
        while True:
            t = trial_clock.getTime()

            if t < t_fix:
                # Fixation period
                fix_target.draw()
            elif t < t_fix + stim_dur:
                # Stimulus period
                stim_img.draw()
                stim_txt.draw()
            else:
                # Trial is over
                break

            win.flip()

            # Collect response *only* during stimulus period
            if t >= t_fix and t < t_fix + stim_dur and resp_key is None:
                keys = kb.getKeys(keyList=['1', '2', 'escape'], # Set keys according to fMRI needs?
                                  waitRelease=False,
                                  clear=False)
                if keys:
                    key = keys[0]
                    if key.name == 'escape':
                        win.close()
                        quit()
                    resp_key = key.name
                    resp_rt = key.rt  # time since last clearEvents()

        # ---- LOG TRIAL DATA ----
        exp.addData('trial_index', idx + 1)  # 1-based indexing
        exp.addData('stim', trial.get('stim'))
        exp.addData('cond', trial.get('cond'))
        exp.addData('set', trial.get('set', 'NA'))
        exp.addData('response', resp_key or 'NA')
        exp.addData('rt', resp_rt or 'NA')
        exp.nextEntry()
        
# Data is saved automatically when the ExperimentHandler closes
win.close()
quit()
