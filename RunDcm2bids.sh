#!/bin/bash

#Script runs dcm2bids twice. Once to convert to proper BIDS and once to convert ASL and SWI sequences, using separate config file, to pseudo-BIDS in derivatives.

# Config file for BIDS
config_file="cir_config.json"
# Config file for ASL and SWI (not defined in BIDS)
config_other="asl_swi_config.json"

# Output directory for BIDS
outputdir="./data/BIDS"
# Otuput directory for derivatives
outputdir_der="./data/BIDS/derivatives"

#Create output folders if the don't already exist
mkdir -p "$outputdir"
mkdir -p "$outputdir_der"

# Specify the path to where subjects are gathered
subject_folder_base="./data/dicoms/"

# Export variables to make them available for "parallel"
export outputdir outputdir_der config_file config_other subject_folder_base

# Find all session folders and process them in parallel to BIDS
find ${subject_folder_base}sub-* -mindepth 1 -maxdepth 1 -type d | parallel --verbose --jobs 16 '
    subject_folder=$(dirname {})
    session_folder={}

    # Extract the subject ID from the folder name
    subjectID=$(basename $subject_folder)

    # Extract the session number from the folder name
    sessionnum=$(basename $session_folder)

    # Print subject and session information
    echo "Processing Subject: $subjectID, Session: $sessionnum"

    # Run dcm2bids command
    dcm2bids -d $session_folder -p $subjectID -s $sessionnum -o $outputdir -c $config_file
'

# Find and remove unnecessary .bval files for fmri
find ${outputdir}/sub-*/ses-*/func -type f -name '*_bold.bval' -exec rm -v {} \;

# Find and remove unnecessary .bvec files for fmri
find ${outputdir}/sub-*/ses-*/func -type f -name '*_bold.bvec' -exec rm -v {} \;

echo "All _bold.bval and _bold.bvec files removed from sub/ses/func/."


# Find seesion folders for non-BIDS sequences (ASL and SWI)
find ${subject_folder_base}sub-* -mindepth 1 -maxdepth 1 -type d | parallel --verbose --jobs 8 '
    subject_folder=$(dirname {})
    session_folder={}

    # Extract the subject ID from the folder name
    subjectID=$(basename $subject_folder)

    # Extract the session number from the folder name
    sessionnum=$(basename $session_folder)

    # Print subject and session information
    echo "Processing Subject: $subjectID, Session: $sessionnum"

    # Run dcm2bids command
    dcm2bids -d $session_folder -p $subjectID -s $sessionnum -o $outputdir_der -c $config_other
'
