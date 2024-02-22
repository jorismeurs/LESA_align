# LESA Alignment Tool
Aligment tool for LESA-MS and direct infusion MS data

# Requirements

## ProteoWizard
1. Download ProteoWizard (http://proteowizard.sourceforge.net/download.html)
2. Install ProteoWizard. Make sure the installation folder is C:\ProteoWizard

## File format
For smooth functioning of the GUI. Please convert .RAW files to .mzXML files using ProteoWizard. No filters have to be selected. Make sure to select **32-bit** and **uncheck zlib compression**

**! Make sure you do not use dots as separator within the file name !**

## MATLAB Runtime Compiler
1. Download MATLAB Runtime Compiler
2. Install at default location

## LESA Alignment Tool
1. In the master folder, click release and download the latest version of LESA Alignment Tool
2. Unzip the folder at a desired location

# How to use
1. Open MATLAB
2. Set the current folder so that you can see all .m files (LESA_align/src/)
3. Double click on LESA_align.m
4. Press **Run** to open the GUI
5. Change default parameters if desired
6. Press 'Process data'
7. Select files for processing and wait till finished

# Use output
The output consists of an Excel file with a matrix of peak intensities per polarity. These aligned matrices can then be used for further multvariate analysis with e.g. SIMCA-P or MetaboAnalysts (https://www.metaboanalyst.ca/). Be aware that the first row of each sheet m/z values
