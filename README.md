A Boring Project
========

This is repository of my graduation paper for my bachelor degree. Here are the raw data, tidy data and my code.

### Something about the paper

Title: Busy Board, Scale Effect and Firm Performance: Evidence from China

### rawData:

This folder consists all the raw data needed in this paper, which are downloaded from CSMAR. They're all Excel file(xls, xlsx) compressed in zip file. 
Be carefull to unzip them!! Some files have the same name and you should rename them.

### tidyData:

This folder consists the tidy data, which you can do some analysis on it. I get the tidy data after manipulation for the raw data. You can check the steps in my code `busyBoard.do`. The `spec.dta` consist some variables needed in the regression analysis, which are generated from `tidy.dta`.

### busyBoard.do

This is my Stata code to import the raw data, manipulate them to get the tidy data and do regression. You can check all the information about the steps in this code. The environment is Windows 7 and Stata 12 SE.