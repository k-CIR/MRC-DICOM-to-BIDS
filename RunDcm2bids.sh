#!/bin/bash

# Script runs dcm2bids twice. Once to convert to proper BIDS and once to convert SWI sequences, using separate config file, to pseudo-BIDS in derivatives.
csv_file="/data/users/nikedv/MRC-DICOM-to-BIDS/redcap_subjects.csv"

# Config file for BIDS
config_file="cir_config.json"
# Config file for SWI (not defined in BIDS)
config_other="swi_config.json"

# Output directory for BIDS
outputdir="/data/projects/capsi/BIDS"
# Output directory for derivatives (based on outputdir)
outputdir_der="${outputdir}/derivatives"

# Create output folders if they don't already exist
mkdir -p "$outputdir"
mkdir -p "$outputdir_der"

# Specify the path to where subjects are gathered
subject_folder_base="/data/projects/capsi/raw/mri/"

# Export variables to make them available for "parallel"
export outputdir outputdir_der config_file config_other subject_folder_base

# Number of rows to process (default: all)
num_rows="${1:-all}"

# Function to generate awk command for limiting rows
get_awk_cmd() {
    # First, determine the column positions for required fields
    local patientid_col=$(head -1 "$csv_file" | tr ',' '\n' | grep -n "^patientid$" | cut -d: -f1)
    local session_col=$(head -1 "$csv_file" | tr ',' '\n' | grep -n "^session$" | cut -d: -f1)
    local mrc_id_col=$(head -1 "$csv_file" | tr ',' '\n' | grep -n "^mrc_id$" | cut -d: -f1)
    
    # Check if required columns were found
    if [[ -z "$patientid_col" ]]; then
        echo "ERROR: 'patientid' column not found in CSV header" >&2
        exit 1
    fi
    if [[ -z "$session_col" ]]; then
        echo "ERROR: 'session' column not found in CSV header" >&2
        exit 1
    fi
    if [[ -z "$mrc_id_col" ]]; then
        echo "ERROR: 'mrc_id' column not found in CSV header" >&2
        exit 1
    fi
    
    # Generate awk command with validation and zero-padding
    local validation_condition="\$$patientid_col != \"\" && \$$session_col != \"\" && \$$mrc_id_col != \"\""
    
    if [[ "$num_rows" == "all" ]]; then
        echo "awk -F, 'NR>1 && $validation_condition {printf \"%03d,%02d\\n\", \$$patientid_col, \$$session_col}' \"$csv_file\""
    else
        echo "awk -F, 'NR>1 && NR<=1+$num_rows && $validation_condition {printf \"%03d,%02d\\n\", \$$patientid_col, \$$session_col}' \"$csv_file\""
    fi
}

# Process BIDS
eval "$(get_awk_cmd)" | parallel --colsep ',' --jobs 16 --verbose '
    subjectID={1}  # padded patientid from CSV
    sessionnum={2} # padded session from CSV
    
    session_folder="${subject_folder_base}sub-${subjectID}/ses-${sessionnum}"

    if [ -d "$session_folder" ]; then
        echo "Processing Subject: $subjectID, Session: $sessionnum"
        dcm2bids -d "$session_folder" -p "$subjectID" -s "$sessionnum" -o "$outputdir" -c "$config_file"
    else
        echo "WARNING: Folder $session_folder does not exist, skipping."
    fi
'

# Find and remove unnecessary .bval files for fmri
find ${outputdir}/sub-*/ses-*/func -type f -name '*_bold.bval' -exec rm -v {} \;

# Find and remove unnecessary .bvec files for fmri
find ${outputdir}/sub-*/ses-*/func -type f -name '*_bold.bvec' -exec rm -v {} \;

echo "All _bold.bval and _bold.bvec files removed from sub/ses/func/."

# Process SWI (non-BIDS) sequences using the same subject/session pairs
eval "$(get_awk_cmd)" | parallel --colsep ',' --jobs 8 --verbose '
    subjectID={1}  # padded patientid from CSV
    sessionnum={2} # padded session from CSV
    
    session_folder="${subject_folder_base}sub-${subjectID}/ses-${sessionnum}"

    if [ -d "$session_folder" ]; then
        echo "Processing SWI for Subject: $subjectID, Session: $sessionnum"
        dcm2bids -d "$session_folder" -p "$subjectID" -s "$sessionnum" -o "$outputdir_der" -c "$config_other"
    else
        echo "WARNING: Folder $session_folder does not exist, skipping."
    fi
        echo "Processing SWI for Subject: $subjectID, Session: $sessionnum"
        dcm2bids -d "$session_folder" -p "$subjectID" -s "$sessionnum" -o "$outputdir_der" -c "$config_other"
    else
        echo "WARNING: Folder $session_folder does not exist, skipping."
    fi
'
