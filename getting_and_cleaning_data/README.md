This document is a submission for the final assignment for Coursera courses: Getting and Clean Data

Before Beginning
Link to data: https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

The R-script will only work if the data files are in working directory. Make sure the path to the files is indicated in the "path" to make this happen!

Example:
path <- "C:/Users/Phi/Coursera/getdata%2Fprojectfiles%2FUCI HAR Dataset/UCI HAR Dataset"

We will use the dplyr and tidyr packages. The script will load both libraries using the libraries() function, but will result in error if these packages are not yet installed. Please make sure they are installed. 

Pre-Task: Loading files
The read.table function is used on relevant .txt files. No separator is required since default works OK. Note that the raw "Intertial Signal" files are not loaded, since they will not be needed for his exercise. The files to be loaded are: 
- activity_labels.txt
- features.txt
- test/subject_test.txt
- test/X_test.txt
- test/y_test.txt
- train/subject_train.txt
- train/X_train.txt
- train/y_train.txt

For a description of the files, see the README.md file in the dataset folder.

Task 1: Merging files
The data sample is split 70% in the 'test' folder and 30% in the 'train' folder. This code will merge these files to construct the complete dataset. Since there are three files, and since rbind() function is used, make sure all datasets are in the same order when the function is called! (i.e. train, then test)

This portion of the script also renames the columns to prepare for future steps. The following columsn are renamed:
- column consisting of subject IDs, as obtained from subject_test.txt, named "Subject"
- column consisting of activity names, as obtained from y_test.txt, named "Activity"
- columns consisting of variables, as obtained from x_test.txt, named by a vector constructed by pasting the first and second columns of features.txt. The pasting was performed since the second columns, which consists of variable names, has duplicates and will not work properly with dplyr. The first column, simple row number, makes each name unique, and will later be dropped.

Lastly, the resulting dataframe is converted to the 'table dataframe' format for using the dplyr package.


Task 2: Extract means and standard deviations
As indicated in the features_info.txt provided with the dataset, the variables corresponding to means and standard deviations labeled with "-mean()" or "-std()", respectively. We use the select() function in the dplyr mackage to select all columns with names that contain "mean()" or "std()". The matches() function is used instead of contains() because the text is embedded in a string of other characters.

Task 3: Name activities
Each activity is provided as a number from 1 to 6. The activity_labels.txt file provides the key for naming the activities with readable values. The match() function is used to assign each "Activity" number a readable value.

Task 4: Descriptive variables
The variable provided in the dataset actually consists of 6 variables that needs to be separated so that the data is tidy!: 
- domain type: time or frequency (denoted by t or f)
- Source: signal portion coming from body or gravity
- Sensor: signal coming from accelerometer or gyroscope
- Type: Acceleration signal or a derrived jerk signal
- Component: and x-, y-, or z-componenet of the signal, or the overall magnitude
- Measure: whether the value the mean or standard deviation.

Unfortunately, the variable that is provided comes in the form that is not trivially separated. There are many ways to separate. This script uses the gsub() function to get the provided variable into a format (delineated by space) that is easily separable. It also names each variable that is not labeled as a jerk signal as an acceleration signal.

Example:
Original variable: "tBodyAcc-mean()-X""
Renamed variable: "t Body Accelerometer Acceleration mean X""

Note: the original dataset seemed to name some body signals as "BodyBody". This appears to be a mistake, and so this was simply considered to be a Body measurement.

A Observation ID row was also added, called "row" so that the mean and standard deviation values could remain coupled. Without this, when using the gather() function, the mean and standard deviation values would be decoupled, seeming like they are from different observations. The gather() function from the tidyr package was used on all columns except "Subject", "Activity", and "row".

Since the mean and standard deviations are each variables, the spread() function was used to make columns for each (this is where the row ID is required).

Task 5: Average by variable and subject
The group_by(), summarize() functions from the dplyr package were used to acquire the averages for each variable by "Subject" and "Activity". This results in 5940 rows of averages. One could use this to determine the averages ACROSS all variables simply by grouping only the "Subject" and "Activity". This final table is exported as master_final.txt.
