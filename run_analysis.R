###################################################################
#  run_analysis R file for Getting and Cleaning Data course project
#  Miguel Pintor Sepúlveda october 2014
###################################################################

#  The script works on data collected from the accelorometers in the Samsung Galaxy S smartphone
#  and does the following:
#
#       1. merges the training and the test sets to create one data set
#       2. extracts only the measurements on the mean and standard deviation for each measurement
#       3. uses descriptive activity names to name the activities in the data set
#       4. appropiately labels the data set with descriptive variable names
#       5. from the data set in step 4, creates a second, independent tidy data set with the average
#          of each vaiable for each activity and each subject

#  Data will be downloaded and unzipped in the directory where this script is if it is not already present

#  results will be stored in active directory, in a fil called "tidy2.txt"


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


## file locations
features.file <- ".\\UCI HAR Dataset\\features.txt"
train.dataset.file <- ".\\UCI HAR Dataset\\train\\X_train.txt"
test.dataset.file <- ".\\UCI HAR Dataset\\test\\X_test.txt"
train.activities.file <- ".\\UCI HAR Dataset\\train\\y_train.txt"
test.activities.file <- ".\\UCI HAR Dataset\\test\\y_test.txt"
activity.labels.file <- ".\\UCI HAR Dataset\\activity_labels.txt"
train.subject.file <- ".\\UCI HAR Dataset\\train\\subject_train.txt"
test.subject.file <- ".\\UCI HAR Dataset\\test\\subject_test.txt"


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

#  select the columns to be read from train and test file using features.txt containing features wich
#  names includes "mean()" or "std()" strings in it. This way it wont be necessary to 
#  load all the tables to select columns later

#  read feature names table in data.table with string not as factors
features <- read.table(features.file , stringsAsFactors = FALSE)

#  select features to be read form features list. Only features incluiding
#  mean() or std() in its description are going to be included
features.to.read <- features[grep("mean\\(\\)|std\\(\\)", features$V2), ]

# to select which rows to be read, colClasses in read.table is going to be used
# assigning a "NULL" value in columns not to be read, and "numeric" in columns included
# in features.to.read

#  generate a colClasess vector with length fueatures length filled with "NULL" value
col.classes <- rep("NULL",nrow(features))

#  vector of the features row numbers to be read
col.to.read <- as.vector(features.to.read$V1)

#  change colClasses vector from "NULL" to "numeric" in the indexes where mean() and std() features values are
col.classes[col.to.read] <- "numeric"

#  create vector of column names from all features
#  needed to read the table
col.names <- as.vector(features$V2)

#  load activities labels
activity.labels  <- read.table(activity.labels.file,stringsAsFactors=FALSE)

#  get train set
train <- getDataTable(train.dataset.file,train.activities.file,train.subject.file,activity.labels,col.names,col.classes)

#  get test set
test  <- getDataTable(test.dataset.file,test.activities.file,test.subject.file,activity.labels,col.names,col.classes)

#  row bind both tables
tidy1 <- rbind(train,test)

#  appropiately label columns  with descriptive variable names, the appropiate column names begins with "activity" and 
#  "subject" labels, followed by features.to.read
app.col.names <- c("activity","subject", features.to.read$V2)

#  extract from names non alphanumeric values and apply tolower so all column names are in lower case
app.col.names <- tolower(gsub("[^[:alpha:]]", "", app.col.names))

#  change data set col names to approppiate names
colnames(tidy1) <- app.col.names


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


#  create second data set with the average
#  of each vaiable for each activity and each subject

#  aggregate function will be used. Data set to aggregate goes form 3 to last columns
#  aggregated by tidy1$activity and tidys1$subject with names for column names to be set 
#  for these two values the aggregation function is set to mean 

tidy2 <- aggregate(x=tidy1[,3:length(tidy1)],by=list(activity=tidy1$activity,subject=tidy1$subject),FUN=mean)

#  write tidy2 dataset to file
write.table (tidy2, "tidy2.txt", row.names=F, col.names=F, quote=FALSE)


