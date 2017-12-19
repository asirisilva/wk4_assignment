library(data.table)
library(dplyr)

setwd("/coursera_datascience/wk4_assignment/")
download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",destfile = "dataset.zip")


#loading train datasets
subject_train = fread("UCI HAR Dataset/train/subject_train.txt",header = FALSE)
x_train = fread("UCI HAR Dataset/train/X_train.txt", header = FALSE)
y_train = fread("UCI HAR Dataset/train/y_train.txt", header = FALSE)

#loading test datasets
subject_test = fread("UCI HAR Dataset/test/subject_test.txt",header = FALSE)
x_test = fread("UCI HAR Dataset/test/X_test.txt", header = FALSE)
y_test = fread("UCI HAR Dataset/test/y_test.txt", header = FALSE)

#loading feature info
feature_info =  fread("UCI HAR Dataset/features.txt",header=FALSE,sep=" ")

#loading activity labels
activity_labels = fread("UCI HAR Dataset/activity_labels.txt", header = FALSE, sep=" ")

#combining train and test 
subject_all  = rbind(subject_train, subject_test)
x_all = rbind(x_train, x_test)
y_all = rbind(y_train, y_test)

#assigning variable names
names(subject_all) = c("subject_id")
names(x_all) = feature_info$V2
names(y_all) = c("activity_id")

#creating one dataset
dataset = cbind(subject_all,x_all,y_all)


#Extract only the measurements on the mean and standard deviation for each measurement.
cols_to_filter  = c("subject_id", "activity_id",names(dataset)[grepl("mean\\(\\)|std\\(\\)",names(dataset))])
filtered_dataset = dataset[,..cols_to_filter]
class(filered_dataset$activity_id)

#Uses descriptive activity names to name the activities in the data set
filtered_dataset$activity_name = factor(filtered_dataset$activity_id, labels = activity_labels$V2)

#Appropriately labels the data set with descriptive variable names.
names(filtered_dataset) = gsub("-","_",names(filtered_dataset))
names(filtered_dataset) = gsub("\\(\\)","",names(filtered_dataset))
names(filtered_dataset) = gsub("Mag","_magnititude",names(filtered_dataset))
names(filtered_dataset) = gsub("Acc","_accelaration_",names(filtered_dataset))
names(filtered_dataset)

#From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
cols_to_filter2 = names(filtered_dataset)[grepl("mean",names(filtered_dataset))]

tidydataset = aggregate(filtered_dataset[,..cols_to_filter2],
                        by=list(filtered_dataset$subject_id,filtered_dataset$activity_name),
                        mean)
tidydataset = rename(tidydataset, subject_id = Group.1, activity_name = Group.2)

#write the tidy dataset to csv
write.csv(tidydataset, file = "tidydataset.csv", row.names=FALSE)
write.table(tidydataset, file = "tidydataset.txt", row.names=FALSE)


