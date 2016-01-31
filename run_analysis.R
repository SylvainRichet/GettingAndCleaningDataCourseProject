# *****************************************************************************
# R script responsible for getting, cleaning and providing "tidy data set".
#
# Author : Sylvain RICHET
#
# *****************************************************************************

# these libraries will be used
library(data.table)
library(reshape2)

# Directories
rawDataDir <- file.path(getwd(), "raw-data")
tidyDataDir <- file.path(getwd(), "tidy-data")
rootRawData <- file.path(rawDataDir, "UCI HAR Dataset")


# Download Raw data zip file
#rawDataZipFile <- file.path(rawDataDir, "rawdata.zip")
#url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
#download.file(url, rawDataZipFile)dt <- data.table(melt(dt, key(dt), variable.name="featureCode"))

# unzip file
#unzip(zipfile = rawDataZipFile, exdir = rawDataDir )

# -----------------------------------------------------------------------------
# 1. Merges the training and the test sets to create one data set.
# -----------------------------------------------------------------------------

# Read Subjects for both populations
dtSubjectTrain <- data.table(fread(file.path(rootRawData, "train", "subject_train.txt")))
dtSubjectTest <- data.table(fread(file.path(rootRawData, "test", "subject_test.txt")))

# Read Activities for both populations
dtActivityTrain <- data.table(fread(file.path(rootRawData, "train", "y_train.txt")))
dtActivityTest <- data.table(fread(file.path(rootRawData, "test", "y_test.txt")))

# Finally read main data for both populations
dtTrain <- data.table(fread(file.path(rootRawData, "train", "X_train.txt")))
dtTest <- data.table(fread(file.path(rootRawData, "test", "X_test.txt")))

# Combine all Subjects, Activities and main data
dtSubjects <- rbind(dtSubjectTrain, dtSubjectTest)
colnames(dtSubjects) <- "subject"
dtActivities <- rbind(dtActivityTrain, dtActivityTest)
colnames(dtActivities) <- "activity"
dtDatas <- rbind(dtTrain,dtTest)

# Finally combine all and sort
dtDatas <- cbind(dtSubjects, dtActivities, dtDatas)
setkey(dtDatas, subject, activity)

# -----------------------------------------------------------------------------
# 2. Extracts only the measurements on the mean and standard deviation
# -----------------------------------------------------------------------------

# Now, read features 
dtFeatures <- data.table(fread(file.path(rootRawData, "features.txt")))
colnames(dtFeatures) <- c("featureId", "featureName")

# Filter on mean() and std() feature names
dtFeatures <- dtFeatures[grepl("mean\\(\\)|std\\(\\)", tolower(dtFeatures$featureName))]

# Filter data with help of a dedicated column based on feature matchings
dtFeatures$featureMatch <- dtFeatures[, paste0("V", featureId)]
dtDatas <- dtDatas[, c(key(dtDatas), dtFeatures$featureMatch), with=FALSE]

# -----------------------------------------------------------------------------
# 3. Uses descriptive activity names to name the activities in the data set
# -----------------------------------------------------------------------------

dtActivityLabels <- fread(file.path(rootRawData, "activity_labels.txt"))
colnames(dtActivityLabels) <- c("activity", "activityName")
dtDatas <- merge(dtDatas, dtActivityLabels, by="activity", all.x=TRUE)

# Add featureMatch to data
setkey(dtDatas, subject, activity, activityName)
dtDatas <- data.table(melt(dtDatas, key(dtDatas), variable.name="featureMatch"))
dtDatas <- merge(dtDatas, dtFeatures[, list(featureId, featureMatch, featureName)], by="featureMatch", all.x=TRUE)

# -----------------------------------------------------------------------------
# 4. Appropriately labels the data set with descriptive variable names.
# -----------------------------------------------------------------------------

# Dupplicate activity and feature labels as factors
dtDatas$activity <- factor(dtDatas$activityName)
dtDatas$feature <- factor(dtDatas$featureName)

# Map feature Jerk
dtDatas$Jerk <- factor(grepl("Jerk",dtDatas$feature), labels=c(NA, "Jerk"))

# Map feature Magnitude
dtDatas$Magnitude <- factor(grepl("Mag",dtDatas$feature), labels=c(NA, "Magnitude"))

# Map Variable
m1 <- matrix(seq(1, 2), nrow=2)
m2 <- matrix(c(grepl("mean",dtDatas$feature), grepl("std",dtDatas$feature)), ncol=nrow(m1))
dtDatas$Variable <- factor(m2 %*% m1, labels=c("mean", "std"))

# Map feature Source
m2 <- matrix(c(grepl("Acc",dtDatas$feature), grepl("Gyro",dtDatas$feature)), ncol=nrow(m1))
dtDatas$Source <- factor(m2 %*% m1, labels=c("Accelerometer", "Gyroscope"))

# Map feature Acceleration
m2 <- matrix(c(grepl("BodyAcc",dtDatas$feature), grepl("GravityAcc",dtDatas$feature)), ncol=nrow(m1))
dtDatas$Acceleration <- factor(m2 %*% m1, labels=c(NA, "Body", "Gravity"))

# Map feature Domain
m2 <- matrix(c(grepl("^t",dtDatas$feature), grepl("^f",dtDatas$feature)), ncol=nrow(m1))
dtDatas$Domain <- factor(m2 %*% m1, labels=c("Time", "Freq"))

# Map axis
m1 <- matrix(seq(1, 3), nrow=3)
m2 <- matrix(c(grepl("-X",dtDatas$feature), grepl("-Y",dtDatas$feature), grepl("-Z",dtDatas$feature)), ncol=nrow(m1))
dtDatas$Axis <- factor(m2 %*% m1, labels=c(NA, "X", "Y", "Z"))


# -----------------------------------------------------------------------------
# 4+5. Creates both tidy data sets
# -----------------------------------------------------------------------------

# Finally 
setkey(dtDatas, subject, activity, Jerk, Magnitude, Variable, Source, Acceleration, Domain, Axis)
tidyDatas <- dtDatas[, by=key(dtDatas)]
tidyDatasAvg <- dtDatas[, list(count = .N, average = mean(value)), by=key(dtDatas)]

# Write both tidy data sets into dedicated directory
write.table(tidyDatas, file = paste(tidyDataDir, "tidyData.txt", sep = "/"), row.names = FALSE)
write.table(tidyDatasAvg, file = paste(tidyDataDir, "tidyDataWithAverage.txt", sep = "/"), row.names = FALSE)

