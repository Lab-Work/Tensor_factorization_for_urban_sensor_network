# Tensor_factorization_for_urban_sensor_network
Automatic preprocessing of urban environmental sensor network with tensor factorization
Yue Hu, Yanbing Wang, 
Jun 2019

## Overview
This repository contains the source code and tests developed for robust tensor recovery for urban sensing network data preprocessing. This results are reported in "Automatic preprocessing of urban environmental sensor network with tensor factorization" by Y.Hu et. al (Preprint). 

## Structures
- `/code/` The source code folder.
  - `inexact_alm_rmc21.m` and `inexact_alm_rmc3D.m` are the main algorithms. They solve tensor robust complepetion under fiber-sparse corruption and element-sparse corrution, respectively.
  - `/PROPACK/` Prerequisit packages, including code for efficient PCA and tensor manipulation package - `Tensor Toolbox for MATLAB`.
  - `/test6M_missing.m/` is the test code for 6 month Array of Things (AOT) temperature data recovery. More info on AOT can be found at https://arrayofthings.github.io/.
  -`\noaa_test.m\` is the simulation test code for recoverying the manually corrupted NOAA temperature data.
- `/Data/` Contains dataset for testing. 
  -`/NOAA_6M_pollute_sim.mat/` contains the 6 month original and polluted NOAA data in Chicago of 14 sensors.
  -`/AoT6M_277.mat/` contains the 6 month raw AOT data of 277 sensors.
  -`/Noaa_6M.mat/` contains the NOAA record of the nearest noaa sensor to the AOT nodes at the same time stamps. 
- `/Figure/` Contains figures.

## Usage
The code can be run in Matlab. `code/noaa_test.m` and `test6M_missing.m` are simulation test and Chicago AOT case study, respectively.

## Contact
+ Author: Yue Hu, Yanbing Wang. Institute for Software Integrated Systems, Vanderbilt University
+ Email: {yue.hu; yanbing.wang}(at)vanderbilt.edu
