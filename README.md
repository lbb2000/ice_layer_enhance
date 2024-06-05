# ice_layer_enhance
# Dual-transform domains Layer-Enhancement Package

## Overview
This guide provides step-by-step instructions to process measured ice radar data using the Shearlab 3.0 software package and MATLAB. By following these steps, you will download the necessary data and software, create relevant MATLAB functions based on provided PID code, and execute the main processing script.

## Steps

### Step 1: Download Data and Shearlab 3.0 Software Package
1. **Download Ice Radar Data**: Access and download the real-world ice radar data from the following link:
   - [Ice Radar Data (Version 2)](https://nsidc.org/data/iracc1b/versions/2)
   
2. **Download Shearlab 3.0**: Access and download the Shearlab 3.0 wavelet transform toolkit from the following link:
   - [Shearlab 3.0](http://shearlab.math.lmu.de/)

### Step 2: Read Reference PID Code and Create MATLAB Functions
1. Refer to the provided reference literature that contains PID (Proportional-Integral-Derivative) code.
2. Create corresponding functions in MATLAB based on the PID code from the literature.
   - [PID](https://ieeexplore.ieee.org/document/6820766)
### Step 3: Organize Files and Execute Main Script
1. **Organize Files**:
   - Place the downloaded ice radar data into a folder named `data`.
   - Place the Shearlab 3.0 toolkit and the MATLAB code (including the functions created from the PID code) into a folder named `lib`.
   
2. **Run the Main Script**:
   - Execute the `code20240117_measured_glacier_data.m` script in MATLAB. This script will utilize the data and the Shearlab toolkit to process the ice radar measurements.


## Notes
- Ensure that MATLAB has the necessary toolboxes and permissions to execute the script and access the files.
- The main script `code20240117_measured_glacier_data.m` is expected to be in the `lib` folder along with the required functions and Shearlab toolkit.

By following the above steps, you will be able to process the ice radar data effectively using MATLAB and Shearlab 3.0.
