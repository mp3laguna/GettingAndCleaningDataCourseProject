Getting And Cleaning Data Course Project
===================================

This file  explains how all of the scripts work and how they are connected in Geting and Cleaning Data Course Project. The script run_analysis.R does the following:

  
1.- Merges the training and the test sets to create one data set.   
2.- Extracts only the measurements on the mean and standard deviation for each measurement.    
3.- Uses descriptive activity names to name the activities in the data set.   
4.- Appropriately labels the data set with descriptive variable names.    
5.- From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.    


All of the points have been coded in one script so there is no need to explain relations between scripts.


First of all it checks if the data is present. This has been included although the text specifies that the code "can be run as long as the Samsung data is in your working directory" to avoid problems with directory names.

The code for this is as follows:

        #  if "UCI HAR Dataset" directory doesn't exists, assume data is not present and download it
        if(!file.exists("UCI HAR Dataset")){
                #  file url
                fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
                #  download file
                download.file(fileUrl,"dataset.zip")
                #  unzip data
                unzip("dataset.zip")
                #remove zipped file
                file.remove("dataset.zip")
                #  remove fileUrl variable from environment
                remove(fileUrl)
        }
        

After downloading and extracting data, file locations for different data files are defined, in order to locate in only one part of the code all of this text file names.


        ## file locations
        features.file <- ".\\UCI HAR Dataset\\features.txt"
        train.dataset.file <- ".\\UCI HAR Dataset\\train\\X_train.txt"
        test.dataset.file <- ".\\UCI HAR Dataset\\test\\X_test.txt"
        train.activities.file <- ".\\UCI HAR Dataset\\train\\y_train.txt"
        test.activities.file <- ".\\UCI HAR Dataset\\test\\y_test.txt"
        activity.labels.file <- ".\\UCI HAR Dataset\\activity_labels.txt"
        train.subject.file <- ".\\UCI HAR Dataset\\train\\subject_train.txt"
        test.subject.file <- ".\\UCI HAR Dataset\\test\\subject_test.txt"


As two main tables are needed (train and test datasets) and same operations are going to be done on both, a function called getDataTable is included. This function gets as inputs the next variables:  

**data.file.-** data file to be read (X_train.txt or X_test.txt)   
**activities.file.-** data file with activities (laying, sitting, ...) for each record in data set (y_train.txt or y_test.txt files)   
**subjects.file.-** data file name with subjects for each record in data set (in this case subject 1 to 30)   
**activity.labels.-** data file name of activities names. This data frame is used to bind activities in activities.file (that contains and activity index) with the activity name.   
**col.names.-** vector containing all of the column names in data set. This information is previously obtained from features.txt file.   
**col.classes.-** this vector is used to only read the columns needed form data set. It contains the character value "NULL"" in the columns that are not going to be read and the value "numeric" in the columns needed (the ones containing mean and standar deviation values)   


         
       
        #  As many operations that must be done on X_train.txt and Y_train.txt
        #  are exacctly the same a function called getDataTable() will be
        #  generated in this  script not to make work twice
        getDataTable <- function(data.file,activities.file,subjects.file,activity.labels,col.names,col.classes){
                #  read dataset
                dataset <- read.table( data.file , col.names = col.names , colClasses = col.classes )
                #  load subjects data set
                activities <- read.table(activities.file )
                #  load  activities data set
                subjects <- read.table(subjects.file , col.names="sujeto")
                #  add activity label column and subject label to dataset
                dataset <- cbind (activities , subjects , dataset)
                #  replace activities index with activities labels
                dataset$V1 <- activity.labels[dataset$V1, 2]
                #  return dataset
                dataset
        }
        

Before calling the function defined the variables needed are createdd and populated. First of all the feature names in both data sets (X_train.txt and X_test.txt) are read from file features.txt


        #  read feature names table in data.table with string not as factors
        features <- read.table(features.file , stringsAsFactors = FALSE)


Then features needed are extracted form all features vector and insertd in a data frame called features.to.read. This features are the one containing "mean()" or "std()" strings in its name.


        #  select features to be read form features list. Only features incluiding
        #  mean() or std() in its description are going to be included
        features.to.read <- features[grep("mean\\(\\)|std\\(\\)", features$V2), ]
        

A col.classes vector is generated including character "NULL" value for columns not to be read and character "numeric" value in the columns that are going to be read from data files.
        

        #  generate a colClasess vector with length fueatures length filled with "NULL" value
        col.classes <- rep("NULL",nrow(features))
        #  vector of the features index numbers to be read
        col.to.read <- as.vector(features.to.read$V1)
        #  change colClasses vector from "NULL" to "numeric" in the indexes where mean() and std() features values are
        col.classes[col.to.read] <- "numeric"
        

A vector with all column names is generatedd as needed to be used with read.table command. The values are taken from features data frame.
        

        #  create vector of column names from all features
        #  needed to read the table
        col.names <- as.vector(features$V2)
        

Activities names are loaded in activity.labels data frame.
        

        #  load activities labels
        activity.labels  <- read.table(activity.labels.file,stringsAsFactors=FALSE)
        

train and test data frames are loaded using getDataTable function. First column includes activity for each record labeled, second column is subject number and the rest of the columns are the columns asked to include in data set, that is, columns incuding "mean()" or "std()" string in its name.
        

        #  get train set
        train <- getDataTable(train.dataset.file,train.activities.file,train.subject.file,activity.labels,col.names,col.classes)
        #  get test set
        test  <- getDataTable(test.dataset.file,test.activities.file,test.subject.file,activity.labels,col.names,col.classes)
        

Both data frames are binded in one data frame called tidy1.


        #  row bind both tables
        tidy1 <- rbind(train,test)
        

After populating tidy1 data set the correct columns names are generated and changed into the data frame. For this, the first to columns are named "activity" and "subject" and the rest are obtained form features.to.read variable. Then the non alphanumeric characters are extracted and upper case letters turned into lower case. Names of columns in data set are changed using colnames command. 


        #  appropiately label columns  with descriptive variable names, the appropiate column names begins with "activity" and 
        #  "subject" labels, followed by features.to.read
        app.col.names <- c("activity","subject", features.to.read$V2)
        #  extract from names non alphanumeric values and apply tolower so all column names are in lower case
        app.col.names <- tolower(gsub("[^[:alpha:]]", "", app.col.names))
        #  change data set col names to approppiate names
        colnames(tidy1) <- app.col.names


Global environment memory is cleaned.


        #  remove data from environment
        remove(train)
        remove(test)
        remove(features.to.read)
        remove(col.names)
        remove(col.classes)
        remove(features)
        remove(features.file)
        remove(activity.labels)
        remove(train.dataset.file) 
        remove(test.dataset.file) 
        remove(train.activities.file) 
        remove(test.activities.file) 
        remove(activity.labels.file)
        remove(train.subject.file)
        remove(test.subject.file)
        remove(col.to.read)
        remove(getDataTable)
        remove(app.col.names)


Once this data set is created, second data set is obtained from it. Aggregate funtion is used for this. The aggregation is made with activity and subject columns from tidy1 data set on columns form third to last.


        #  aggregate function will be used. Data set to aggregate goes form 3 to last columns
        #  aggregated by tidy1$activity and tidys1$subject with names for column names to be set 
        #  for these two values the aggregation function is set to mean 
        tidy2 <- aggregate(x=tidy1[,3:length(tidy1)],by=list(activity=tidy1$activity,subject=tidy1$subject),FUN=mean)


Finally the data set is stored in "tidy2.txt" file.


        #  write tidy2 dataset to file
        write.table (tidy2, "tidy2.txt", row.names=F, col.names=F, quote=FALSE)


