# MRC-DICOM-to-BIDS
Convert DICOM data collected at MRC to BIDS. Designed to extract all sequences in the [CIR-protocol.](https://github.com/k-CIR/CIR_wiki/wiki/CIR-MR%E2%80%90Protocol)

Require [dcm2bids](https://unfmontreal.github.io/Dcm2Bids/3.2.0/) and [GNU parallel](https://www.gnu.org/software/parallel/) in your environment.

Note that the SWI sequence is currently **not** defined in BIDS (but there is a [proposal](https://bids-specification.readthedocs.io/en/v1.2.1/06-extensions.html)). SWI sequences are converted separately to BIDS/derivatives.

## Context
Data collected at MRC should be pushed to the server **FoU** (Forskning och Utveckling) after each completed session. A unique ID is created for each session during scanning. Under the hood, data is stored under that ID and the time of scanning, in folders numbered according to MR-sequence.

If a subject was scanned with three sequences at 2024-12-01, 13:45:15 and given the ID: 12345, their raw DICOM data would be located in:

12345_20241201_134515/ <br>
├── 00000001 <br>
├── 00000002 <br>
└── 00000003 <br>

### <ins>Importantly: Note what ID gets created and assigned at each session.</ins>

## Input

- One [CSV-file that](https://github.com/k-CIR/MRC-DICOM-to-BIDS/blob/d176610a6e9b8444720afda6b6a6670b03352345/RunDcm2bids.sh#L4) specify the subjects and sessions that should be BIDSified.
- One config file for BIDS data and one config file with sequences to write to BIDS/derivatives (if any).

This repository contain a [config file](https://github.com/k-CIR/MRC-DICOM-to-BIDS/blob/main/cir_config.json) designed to run with the [CIR-protocol](https://k-cir.github.io/cir-wiki/mrc/mrc-cir-protocol/) recommended at MRC and _subject_template.csv_ as an example of the subject/session CSV:

subject | session
--- | ---
001 | 01 
001 | 02 
002 | 01 
003 | 01 
003 | 02 

## The config file
See [dcm2bids documentation](https://unfmontreal.github.io/Dcm2Bids/3.1.1/how-to/create-config-file/).

## File description

### .gitignore
By default output is written to ./data - this folder is specified to be ignored by git. Even better is if you specify where you want your output [here](https://github.com/k-CIR/MRC-DICOM-to-BIDS/blob/cd2da4bec596dfb3f2f9deb8b4cb9bbd2f8890c8/RunDcm2bids.sh#L12).

### README.md
The file you are reading right now.

### RunDcm2bids.sh
Convert all DICOM-files to nifti using [dcm2bids](https://unfmontreal.github.io/Dcm2Bids/3.2.0/). Requires a config file that specify what criteria are required for a MR-sequencesto be identified and how to rename it. This script run dcm2bids twice to convert the CIR-protocol sequences and SWI sequences separately.

Run as: ``bash ./RunDcm2bids.sh`` to run all subjects and sessions in the CSV or as ``bash ./RunDcm2bids.sh 2`` to run the first 2 (or any other number) of lines in your CSV.

### swi_config.json
Specify how to match SWI sequences and how to rename them.

### cir_config.json
The config file to match all other sequences in the [CIR-protocol](https://k-cir.github.io/cir-wiki/mrc/mrc-cir-protocol/) and rename them.

### subject_template.csv
A CSV file that contain made up IDs but can be used as a template. It is recommended to use a three integer number (001-999) for BIDS subject.
