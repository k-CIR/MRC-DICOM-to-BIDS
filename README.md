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

## File description
