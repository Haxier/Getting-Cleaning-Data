README
========

In this repository you will find:
* ./README.md : explaination about the repository contents and how to execute the run_analysis.R script
* ./data : folder containing the data used to do the analysis.
* ./Codebook.md : explaination about the data used for the analysis, variables and data transformation
* ./run_analysis.R : source code of the R script in the analize() function

How run_analysis.R script works.
* First, unzip the data from https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip and rename the folder with "data".
* Make sure the folder "data" and the run_analysis.R script are both in the current working directory.
* Second, use source("run_analysis.R") command in RStudio and then execute the "analize()" function. 
* Third, you will find the output file generated in the current working directory:
  - data_with_means.txt: it contains a data set with the average of each variable for each activity and each subject.
