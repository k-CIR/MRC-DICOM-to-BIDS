#!/bin/bash

# Path to CSV of subjects
subs_file="subject_template.csv"

# Path to the data directory - here specified for MRC "Alvik"
datas_dir="/data/dicom"

# Check if the subject file exists
if [ ! -f "$subs_file" ]; then
    echo "The file $subs_file does not exist."
    exit 1
fi

# Path to copy data to
moved_dir="/data/capsi/dicoms"

# Skip the header row of the CSV and process each subject
tail -n +2 "$subs_file" | while IFS=',' read -r subject mrcid1 mrcid2 mrcid3 || [ -n "$subject" ]; do
    echo "Processing MR-IDs for ID: $subject"

    subfolder="$moved_dir/sub-$subject"
    mkdir -p "$subfolder"

    # Loop through mrcid1, mrcid2, and mrcid3
    for i in {1..3}; do
        mrcid=$(eval "echo \$mrcid$i" | tr -d '[:space:]' | tr -d '[:cntrl:]')

        # Check that mrcid exist and set name for session-folder
        if [ -n "$mrcid" ]; then
            ses_folder="$subfolder/ses-$(printf "%02d" $i)"

            # Create session-folder
            if [ ! -d "$ses_folder" ]; then
                mkdir -p "$ses_folder"

                # Construct copy commands and store
                copy_commands=()
                for dir in "$datas_dir/$mrcid"*/*; do
                    if [ -d "$dir" ]; then
                        folder_name=$(basename "$dir")
                        copy_commands+=("cp -r \"$dir\" \"$ses_folder/$folder_name\"")
                    fi
                done

                # Export necessary variables
                export ses_folder

                # Use GNU Parallel to run copy commands in parallel
                printf "%s\n" "${copy_commands[@]}" | parallel -j 8
            else
                echo "ses_folder already exists for mrcid: $mrcid"
            fi
        fi
    done
done
