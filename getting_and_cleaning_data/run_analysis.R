## This document is a submission for the final assignment for Coursera courses: Getting and Clean Data
## For additional information, see README.MD in Github repository: https://github.com/pdashk/datasciencecoursera/tree/master/getting_and_cleaning_data
## Submitted by: Phi Nguyen
## Submission Date: 1/8/2017

## Make sure working directory is set to data folder
path <- "C:/Users/Phi/Desktop/Coursera/getting and cleaning/getdata%2Fprojectfiles%2FUCI HAR Dataset (1)/UCI HAR Dataset"
setwd(path)

## Load relevant libraries
library(dplyr)
library(tidyr)

## Pre-Task: Load files
activity_labels <- read.table("activity_labels.txt")
features <- read.table("features.txt")
subject_test <- read.table("test/subject_test.txt")
X_test <- read.table("test/X_test.txt")
y_test <- read.table("test/y_test.txt")
subject_train <- read.table("train/subject_train.txt")
X_train <- read.table("train/X_train.txt")
y_train <- read.table("train/y_train.txt")

## Task 1: Merge up files & label
subject <- rbind(subject_train, subject_test)
x <- rbind(X_train, X_test)
y <- rbind(y_train, y_test)

names(subject) <- "Subject" 
names(y) <- "Activity" 
names(x) <- paste(features[,1],features[,2]) #some column names are identical, which causes problems for dplyr. this merges column name with its ID to make unique

master <- cbind(subject, y, x) %>% tbl_df #table dataframe format for dplyr package

## Task 2: Extract means and standard deviations
master <- select(master, Subject, Activity, matches("mean\\(\\)|std\\(\\)"))

## Task 3: Name activities
master[["Activity"]] <- activity_labels[match(master[["Activity"]], activity_labels[["V1"]]) , "V2"]

## Task 4: Descriptive variables
names(master) <- gsub("[0-9]","",names(master)) %>% #algorithm to alter column names to make it easier to separate later on
  gsub(" t", "time",.) %>%
  gsub(" f", "frequency",.) %>%
  gsub("BodyBody", "Body",.) %>% #this appears to be a mistake in the data, so corrected
  gsub("Body", "-Body-",.) %>% 
  gsub("Gravity", "-Gravity-",.) %>%
  gsub("\\(\\)", "",.) %>%
  gsub("Mag-std","-std-Magnitude",.) %>%
  gsub("Mag-mean","-mean-Magnitude",.) %>%
  gsub("Acc-","Accelerometer Acceleration ",.) %>%
  gsub("Gyro-","Gyroscope Acceleration ",.) %>%
  gsub("Jerk"," Jerk ",.) %>%
  gsub("-"," ",.)

master$row <- 1:nrow(master) #unique observation ID
master <- gather(master, key = to_sep, value = value, -Subject, -Activity, -row) %>% 
  separate(to_sep, c("Domain","Source","Sensor","Type","Measure","Component")) %>%
  spread(Measure, value) %>%
  select(-row)

## Task 5: Average by variable and subject
master_final <- group_by(master, Subject, Activity, Domain, Source, Sensor, Type, Component) %>%
  summarize(mean(mean),mean(std)) %>%
