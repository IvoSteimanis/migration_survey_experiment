# Replication Package
This repository contains the information videos used in the treatments, as well as the data and code that replicates tables and figures for the following paper: <br>
__Title:__ (Climate) Migrants welcome? Evidence from a Survey-Experiment in Austria<br>
__Authors:__ Karla Henning<sup>1</sup>, Ivo Steimanis<sup>2</sup> & Björn Vollan<sup>2,*</sup> <br>
__Affiliations:__<sup>1</sup> KfW Development bank; <sup>2</sup> Department of Economics, Philipps University Marburg, 35032 Marburg, Germany <br>
__*Correspondence to:__ Björn Vollan bjoern.vollan@wiwi.uni-marburg.de <br>
__ORCID:__ Steimanis: 0000-0002-8550-4675; Vollan: 0000-0002-5592-4185 <br>
__Classification:__ Social Sciences, Economic Sciences <br>
__Keywords:__ survey-experiment, immigration acceptance, environmental degradation, climate change <br>


## License
The data are licensed under a Creative Commons Attribution 4.0 International Public License. The code is licensed under a Modified BSD License. See __LICENSE.txt__ for details.

## Software requirements
All analysis were done in Stata version 16:
- Add-on packages are included in __scripts/libraries/stata__ and do not need to be installed by user. The names, installation sources, and installation dates of these packages are available in __scripts/libraries/stata/stata.trk__.

## Instructions
1.	Save the folder __‘replication_REC’__ to your local drive.
2.	Open the master script __‘run.do’__ and change the global pointing to the working direction (line 20) to the location where you save the folder on your local drive 
3.	Run the master script __‘run.do’__  to replicate the analysis and generate all tables and figures reported in the paper and supplementary online materials

## Datasets
The raw experimental dataset is named ‘migration_survey_experiment.xlsx’

## Descriptions of scripts
__01_clean_data.do__ 
This script processes the raw experimental data from all study sites data and prepares it for analysis.
__02_analysis.do__
This script estimates regression models in Stata, creates figures and tables, saving them to __results/figures__ and __results/tables__
