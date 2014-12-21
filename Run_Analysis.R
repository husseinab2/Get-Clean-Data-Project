# File to download
fileURL <- 'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'

#### Local data file
dataFile <- "./getdata-projectfiles-UCI-HAR-Dataset.zip"

# Directory
dirFile <- "./UCI HAR Dataset"

# Directory and filename of the clean/tidy data:
tidyDataFile <- "./tidy-UCI-HAR-dataset.txt"
# tidyDataFileAVG <- "./tidy-UCI-HAR-dataset-AVG.csv"
# Directory and filename (.txt) of the clean/tidy data
tidyDataFileAVGtxt <- "./tidy-UCI-HAR-dataset-AVG.txt"
# Download the dataset (. ZIP), which does not exist
if (file.exists(dataFile) == FALSE) {
  download.file(fileURL, destfile = dataFile)
}

# Uncompress data file
if (file.exists(dirFile) == FALSE) {
  unzip(dataFile)
}


# read train data
t <- read.table("./UCI HAR Dataset/train/X_train.txt")
dim1 <- dim(t)[[2]]
t[,dim1+1] <- read.table("./UCI HAR Dataset/train/y_train.txt")
t[,dim1+2] <- read.table("./UCI HAR Dataset/train/subject_train.txt")
t[,dim1+3] <- "train"

# read test data
t2 <- read.table("./UCI HAR Dataset/test/X_test.txt")
t2[,dim1+1] <- read.table("./UCI HAR Dataset/test/y_test.txt")
t2[,dim1+2] <- read.table("./UCI HAR Dataset/test/subject_test.txt")
t2[,dim1+3] <- "test"

# combine train/test data
t <- rbind(t,t2)

# retrieve understandable column names from features.txt
# apply to selected columns
features <- read.table("./UCI HAR Dataset/features.txt")
features[,3] <- tolower(features[,2])
features[,3] <- gsub("[(),-]", "_", features[,2])
features[,3] <- gsub("__", "_", features[,3])
features[,3] <- gsub("__", "_", features[,3])
features[,3] <- gsub("_$", "", features[,3])

selectedcols <- grep("(mean)|(std)", features[,3])
t <- t[,c(selectedcols, (dim1+1):(dim1+3))]
colnames(t) <- c(features[c(selectedcols),3], "activity", "subject", "train_test")

# make columns as factor
activitylabels <- read.table("./UCI HAR Dataset/activity_labels.txt")
t[,c("activity")] <- factor(t[,c("activity")], levels = activitylabels$V1, labels = activitylabels$V2)
t[,c("subject")] <- factor(t[,c("subject")], labels = sort(unique(t[,c("subject")])))
t[,c("train_test")] <- factor(t[,c("train_test")], labels = c("train", "test"))



# produce the tidy set

library(data.table)
dim2 <- dim(t)[[2]]
td <- data.table(t[,1:(dim2-1)])
tidy <- td[,lapply(.SD, sd), by=c("activity", "subject")]
write.table(tidy, "./tidy.txt", row.names = F, quote = F )
