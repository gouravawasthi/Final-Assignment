library(reshape2)
#-------------------------------------------------------------------------------------------
# Start Fresh by deleting other variables in R workspace
#-------------------------------------------------------------------------------------------
rm(list =ls())

#-------------------------------------------------------------------------------------------
# Download data-set and unzip
#-------------------------------------------------------------------------------------------
filename <- "dataset.zip"
if (!file.exists(filename)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
  download.file(fileURL, filename, method="curl")
}  
if (!file.exists("UCI HAR Dataset")) { 
  unzip(filename) 
}

#-------------------------------------------------------------------------------------------
# Read Activity Lablels and Features
#-------------------------------------------------------------------------------------------
activity_Labels <- read.table("UCI HAR Dataset/activity_labels.txt",stringsAsFactors = FALSE)
features <- read.table("UCI HAR Dataset/features.txt",stringsAsFactors = FALSE)
#-------------------------------------------------------------------------------------------
# Pick only those Features which are on mean or standard deviation
#-------------------------------------------------------------------------------------------

featuresIndices <- grep(".*mean.*|.*std.*", features[,2])
featuresnames <- features[featuresIndices,2]
featuresnames <- gsub('[-()]', '', featuresnames)
featuresnames <- substring(featuresnames,2)
#-------------------------------------------------------------------------------------------
# Read the datasets for train and test . Merge and summarize
#-------------------------------------------------------------------------------------------

train <- read.table("UCI HAR Dataset/train/X_train.txt")[featuresIndices]
trainactivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainsubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(trainsubjects, trainactivities, train)

test <- read.table("UCI HAR Dataset/test/X_test.txt")[featuresIndices]
testactivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
testsubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testsubjects, testactivities, test)
rm(testactivities,trainactivities,trainsubjects,testsubjects)
allData <- rbind(train, test)
colnames(allData) <- c("subject", "activity", featuresnames)
allData$activity <- factor(allData$activity, levels = activity_Labels[,1], labels = activity_Labels[,2])
allData$subject <- as.factor(allData$subject)
allData.melted <- melt(allData, id = c("subject", "activity"))
allData.mean <- dcast(allData.melted, subject + activity ~ variable, mean)
#-------------------------------------------------------------------------------------------
# Write data to file
#-------------------------------------------------------------------------------------------

write.table(allData.mean, "tidy.txt", row.names = FALSE, quote = FALSE)