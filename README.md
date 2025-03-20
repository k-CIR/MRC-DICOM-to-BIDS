# MRC-DICOM-to-BIDS
Gather DICOM data collected at MRC and convert to BIDS compliant naming and format. Designed to extract all sequences in the [CIR-protocol.](https://github.com/k-CIR/CIR_wiki/wiki/CIR-MR%E2%80%90Protocol)

Require [dcm2bids](https://unfmontreal.github.io/Dcm2Bids/3.2.0/) and [GNU parallel](https://www.gnu.org/software/parallel/) in your environment.

Note that ASL and SWI sequences are currently not defined in BIDS. These are still converted separately and copied to BIDS-derivatives.

## Context
Data collected at MRC should be pushed to FOU1/Alvik after each completed session. A unique ID is created for each session and data is stored under that ID and the time of scanning, in folders numbered according to MR-sequence. 

If a subject was scanned with three sequences at 2024-12-01, 13:45:15 and given the ID: 12345, their raw DICOM data would be located in:

12345_20241201_134515/ <br>
├── 00000001 <br>
├── 00000002 <br>
└── 00000003 <br>

It is therefore important to note what ID gets created and assigned at each session.

## Input
A CSV-file is used to specify what IDs assigned during scanning at MRC should be gathered. Up to three sessions are collected per subject and renamed to an ID you specify for your study. This repository contain _subject_template.csv_ with nonsense IDs as an example. This template file contain three sessions for subject '001', each with a unique ID assigned during scanning, only session 1 & 3 for subject '002' and only session 2 for subject '003'

subject | mrcid1 | mrcid2 | mrcid3
--- | --- | --- | ---
001 | 12345 | 23456 | 34567
002 | 45678 |  | 56789
003 |  | 67890 | 

## Overview
![CIR-MR](https://github.com/user-attachments/assets/d6411ef3-1698-4612-8fd6-ae42dd86a814)

## File description

### .gitignore
By default output is written to ./data - this folder is specified to be ignored by git. Even better is if you specify where you want your output [here](https://github.com/k-CIR/MRC-DICOM-to-BIDS/blob/dfc1740590513d1a329d0b9e551b6b5097a1b87b/GatherDicoms.sh#L16), [here](https://github.com/k-CIR/MRC-DICOM-to-BIDS/blob/dfc1740590513d1a329d0b9e551b6b5097a1b87b/RunDcm2bids.sh#L11) and [here](https://github.com/k-CIR/MRC-DICOM-to-BIDS/blob/dfc1740590513d1a329d0b9e551b6b5097a1b87b/RunDcm2bids.sh#L13).

### GatherDicoms.sh
Run this shell-script to gather dicoms for IDs specified in _subject_template.csv_ rename them to an ID you specify for your study and arrange the raw DICOM data in a pseudo-BIDS folder structure. If a session folder already exist at the destination - it will be skipped and not copied again.

### README.md
The file you are reading right now.

### RunDcm2bids.sh
Run this shell-script after "GatherDicoms.sh" to convert all DICOM-files to nifti using [dcm2bids](https://unfmontreal.github.io/Dcm2Bids/3.2.0/). Requires a config file that specify what criteria are required for a MR-sequencesto be identified and how to rename it. This script run dcm2bids twice to convert the CIR-protocol sequences and ASL and SWI sequences separately.

### asl_swi_config.json
The config file to match ASL and SWI sequences and how to rename them.

### cir_config.json
The config file to match all other sequences in the [CIR-protocol](https://k-cir.github.io/cir-wiki/mrc/mrc-cir-protocol/).

### subject_template.csv
A CSV file that contain random, nonsense IDs but can be used as a template for your study. The first column "subject" are specified by you - it is recommended to use a three integer number (001-999) for BIDS. The mrcid1, mrcid2 and mrcid3 are generated during scanning and should be noted at the time. This script is designed to use with up to three sessions but also work with fewer sessions. If you only scan each subject once - only use the second column "mrcid1" and leave the others blank.
