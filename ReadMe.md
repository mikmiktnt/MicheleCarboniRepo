---
title: "run.analysis Script ReadMe"
author: "Michele Carboni"
date: "Thursday, December 18, 2014"
output: html_document
---

run.analysis read the data from the data collected from the accelerometers from the Samsung Galaxy S smartphone collected from Jorge L. Reyes-Ortiz, Davide Anguita, Alessandro Ghio and Luca Oneto, Università degli Studi di Genova.

The data set is available at 

https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 

## Script description 

The script does the following:

1.Check Packages Existance and Install Missing Packages

```
list.of.packages <- c("downloader", "plyr", "dplyr", "reshape2")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages>0)) install.packages(new.packages)
remove(list.of.packages, new.packages)

```
2.Call Library
```
library(downloader)
library(plyr)
library(dplyr)
library(reshape2)
```
3get the working directory
```
wd<-getwd()
```
4.check the existance of the folder. If not download the dataset
```
if (!file.exists("./UCI HAR Dataset")){
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download(url, paste(wd,"dataset.zip", sep="/"), mode="wb")
unzip("dataset.zip")
unlink("dataset.zip")
remove(url)
}
```
5.read the features and the activity_lables file
```
features<-read.table("./UCI HAR Dataset/features.txt",sep="",  
                     stringsAsFactors = FALSE)
activity<-read.table("./UCI HAR Dataset/activity_labels.txt",sep="",  
                     stringsAsFactors = FALSE)
```
6.read the test data set files and create a Final_test data frame
```

X_test<-read.table("./UCI HAR Dataset/test/X_test.txt",sep="")
Y_test<-read.table("./UCI HAR Dataset/test/y_test.txt")
Subject_test<-read.table("./UCI HAR Dataset/test/subject_test.txt")
Final_test<-cbind(Subject_test, Y_test, X_test)
```
7.read the training data set and create a Final_Test data frame
```
X_train<-read.table("./UCI HAR Dataset/train/X_train.txt",sep="")
Y_train<-read.table("./UCI HAR Dataset/train/y_train.txt")
Subject_train<-read.table("./UCI HAR Dataset/train/subject_train.txt")
Final_train<-cbind(Subject_train, Y_train, X_train)
```

8.create the final Merged data frame
```
Merged<-tbl_df(rbind(Final_train, Final_test))
colnames(Merged)<-make.unique(c("Subject", "Test", features[,2]))
```
9.remove all colums but the ones containing "mean()" and "std()"
```
Merged<-select(Merged, Subject, Test ,contains("mean()"), contains("std()")) 
```
10.Remap the Test Column with the activity names and melt the Merged df
```
Merged$Test<-mapvalues(Merged$Test, c(1,2,3,4,5,6), tolower(activity[,2]))
Merged<- melt(Merged, id.vars=c("Subject", "Test")) 
```
11.Calculate the mean for each combination of Subject, Test and Variable and rename the variable col
```
MergedFinal<-Merged %>% ddply(c("Subject", "Test", "variable"), summarise,mean=mean(value)) %>%
             #rename variable col
             rename(Measurement=variable)
```
12.spread the MergedFinal df after combine Test and Measurement (into Measurement)
and remove the Test Variable. The df is spread (Key=Measurement, Values=mean) then exported as a tab space separeted
```
MergedFinal<-MergedFinal %>% mutate(Measurement=paste(Measurement, Test, sep="_")) %>%
             select(-Test) %>%   
             spread(Measurement, mean) 
```
13.remove the temporary dataframe for a cleaner output
```
remove(X_train, Y_train, Subject_train, X_test, Y_test, Subject_test,
       Final_train, Final_test, url, wd, activity, features)

```
The two output is MergedFinal. Temporary output can be collected as well by removing their name by remove() in code chunk 13
