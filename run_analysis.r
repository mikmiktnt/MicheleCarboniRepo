#1.Check Packages Existance and Install Missing Packages
list.of.packages <- c("downloader", "plyr", "dplyr", "reshape2", "tidyr")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages>0)) install.packages(new.packages)
remove(list.of.packages, new.packages)

#2.Call Library
library(downloader)
library(plyr)
library(dplyr)
library(reshape2)
library(tidyr)


#3get the working directory
wd<-getwd()


#4.check the existance of the folder. If not download the dataset
if (!file.exists("./UCI HAR Dataset")){
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download(url, paste(wd,"dataset.zip", sep="/"), mode="wb")
unzip("dataset.zip")
unlink("dataset.zip")
remove(url)
}

#5.read the features and the activity_lables file
features<-read.table("./UCI HAR Dataset/features.txt",sep="",  
                     stringsAsFactors = FALSE)
activity<-read.table("./UCI HAR Dataset/activity_labels.txt",sep="",  
                     stringsAsFactors = FALSE)


#6.read the test data set
X_test<-read.table("./UCI HAR Dataset/test/X_test.txt",sep="")
Y_test<-read.table("./UCI HAR Dataset/test/y_test.txt")
Subject_test<-read.table("./UCI HAR Dataset/test/subject_test.txt")
Final_test<-cbind(Subject_test, Y_test, X_test)


#7.read the training data set
X_train<-read.table("./UCI HAR Dataset/train/X_train.txt",sep="")
Y_train<-read.table("./UCI HAR Dataset/train/y_train.txt")
Subject_train<-read.table("./UCI HAR Dataset/train/subject_train.txt")
Final_train<-cbind(Subject_train, Y_train, X_train)


#8.create the final merge set
Merged<-tbl_df(rbind(Final_train, Final_test))
colnames(Merged)<-make.unique(c("Subject", "Test", features[,2]))

#9.remove all colums but mean() and std()
Merged<-select(Merged, Subject, Test ,contains("mean()"), contains("std()")) 
    
#10.remap the Test Column and melt the Merged df
Merged$Test<-mapvalues(Merged$Test, c(1,2,3,4,5,6), tolower(activity[,2]))
Merged<- melt(Merged, id.vars=c("Subject", "Test")) 


#11.Calculate the mean for each  values and rename the variable col
MergedFinal<-Merged %>% ddply(c("Subject", "Test", "variable"), summarise,mean=mean(value)) %>%
             #rename variable col
             rename(Measurement=variable)

#12.spread the MergedFinal df after combine Test and Measurement (into Measurement)
# and remove the Test Variable. The df is then exported as a tab space separeted
MergedFinal<-MergedFinal %>% mutate(Measurement=paste(Measurement, Test, sep="_")) %>%
             select(-Test) %>%   
             spread(Measurement, mean) 

write.table(MergedFinal, file="./UCI HAR Dataset/FinalData.txt", row.names=F,
            sep="\t")

#13.remove the temp df for a cleaner output
remove(X_train, Y_train, Subject_train, X_test, Y_test, Subject_test,
       Final_train, Final_test, wd, activity, features, Merged)

