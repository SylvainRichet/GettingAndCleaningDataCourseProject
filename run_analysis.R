# *****************************************************************************
# R script responsible for getting, cleaning and providing "tidy data set".
#
# Author : Sylvain RICHET
#
# *****************************************************************************

# ... libraries will be used

# Directories
rawDataDir =  paste(getwd(), "raw-data", sep = "/")
tidyDataDir =  paste(getwd(), "tidy-data", sep = "/")


# Download Raw data zip file
rawDataZipFile <- file.path(rawDataDir, "rawdata.zip")
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url, rawDataZipFile)

# unzip file
unzip(zipfile = rawDataZipFile, exdir = rawDataDir )

