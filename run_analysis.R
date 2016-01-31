# *****************************************************************************
# R script responsible for getting, cleaning and providing "tidy data set".
#
# Author : Sylvain RICHET
#
# *****************************************************************************

# these libraries will be used
library(data.table)

# Directories
rawDataDir <- file.path(getwd(), "raw-data")
tidyDataDir <- file.path(getwd(), "tidy-data")
rootRawData <- file.path(rawDataDir, "UCI HAR Dataset")


# Download Raw data zip file
rawDataZipFile <- file.path(rawDataDir, "rawdata.zip")
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url, rawDataZipFile)

# unzip file
unzip(zipfile = rawDataZipFile, exdir = rawDataDir )

# Read Subjects for both populations
dtSubjectTrain <- data.table(fread(file.path(rootRawData, "train", "subject_train.txt")))
dtSubjectTest <- data.table(fread(file.path(rootRawData, "test", "subject_test.txt")))

# Read Activities for both populations
dtActivityTrain <- data.table(fread(file.path(rootRawData, "train", "y_train.txt")))
dtActivityTest <- data.table(fread(file.path(rootRawData, "test", "y_test.txt")))

# Finally read the DATA for both populations
dtTrain <- data.table(fread(file.path(rootRawData, "train", "X_train.txt")))
dtTest <- data.table(fread(file.path(rootRawData, "test", "X_test.txt")))

# Combine all Subjects, Activities and DATA
dtSubjects <- rbind(dtSubjectTrain, dtSubjectTest)
setnames(dtSubjects, "subject")
dtActivities <- rbind(dtActivityTrain, dtActivityTest)
setnames(dtActivities, "activity")
dtDatas <- rbind(dtTrain,dtTest)

# Finally combine all and sort
dtDatas <- cbind(dtSubjects, dtActivities, dtDatas)
setkey(dtDatas, subject, activity)

