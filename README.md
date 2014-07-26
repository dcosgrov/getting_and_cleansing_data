README.md
==========================

This repository contains the following files:
==============================================================================================
1) CodeBook.md: explains how data was collected and transformed as well as provides
                information regarding the specific variables/units that are captured
                in the output of the run_analysis.R script described below.

==============================================================================================
2) run_analysis.R : 

This script is capable of reading input files related to training and test data captured
in the following dataset for Human Activity Recognition Using Smartphones Data Set: 

https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 

The specific details for this data set can be found here:
http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

In order to run the run_analysis.R script, the following 6 input files must be placed in the 
current working directory when executing the script:

i) X_train.txt - this file contains core training data

ii) y_train.txt - this file contains activity codes for training data captured in X_train.txt

iii) subject_train.txt - this file contains subject codes for training data captured in X_train.txt

iv) X_test.txt - this file contains core test data

v) y_text.txt - this file contains activity codes for test data captured in X_test.txt

vi) subject_test.txt - this file contains subject codes for test data captured in X_test.txt


The run_analysis.R script is capable of reading the aforementioned input files and produces
the following file output to the designated current working directory:

summary_data.txt

The summary_data.txt file contains average calculations of the underlying 68 mean and
standard deviation metrics contained within the X_train.txt and X_test.txt data files
for each unique activity/subject combination.

==============================================================================================
3) means.txt : a file containing mean column numbers and associated column names
4) stddev.txt: a file containing standard deviation column numbers and associated column names
5) means_and_stddevs.txt: a file that represents the combination of means.txt and stddev.txt 
                          used to determine the master list of mean and standard deviation 
                          column numbers and names.
==============================================================================================
