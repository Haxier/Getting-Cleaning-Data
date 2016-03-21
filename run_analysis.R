# helper function to grep a regular expression
grepthis <- function(regex) {
    grepl(regex, dt$feature)
}
# helper function to read tables
fileToDataTable <- function(f) {
    df <- read.table(f)
    dt <- data.table(df)
}
# Get and Clean the Data
analyze <- function(){
    library(reshape2)
    library(data.table)
    # read the data
    X_test <- fread("./data/test/X_test.txt")
    dtSubjectTrain <- fread(file.path("./data/train", "subject_train.txt"))
    dtSubjectTest <- fread(file.path("./data/test", "subject_test.txt"))
    dtActivityTrain <- fread(file.path("./data/train", "Y_train.txt"))
    dtActivityTest <- fread(file.path("./data/test", "Y_test.txt"))
    dtTrain <- fileToDataTable(file.path("./data/train", "X_train.txt"))
    dtTest <- fileToDataTable(file.path("./data/test", "X_test.txt"))
    # combine train and test data and set exaplainatory names
    dtSubjects <- rbind(dtSubjectTrain, dtSubjectTest)
    setnames(dtSubjects, "V1", "subject")
    dtActivity <- rbind(dtActivityTrain, dtActivityTest)
    setnames(dtActivity, "V1", "activity")
    setnames(dtActivity, "activity", "activityNum")
    dt <- rbind(dtTrain, dtTest)
    
    dtSubjects <- cbind(dtSubjects, dtActivity)
    dt <- cbind(dtSubjects, dt)
    setkey(dt, subject, activityNum)
    dtFeatures <- fread("./data/features.txt")
    setnames(dtFeatures, names(dtFeatures), c("featureNum", "featureName"))
    # subset mean and std values
    dtFeatures <- dtFeatures[grepl("mean\\(\\)|std\\(\\)", featureName)]
    dtFeatures$featureCode <- dtFeatures[, paste0("V", featureNum)]
    
    select <- c(key(dt), dtFeatures$featureCode)
    dt <- dt[, select, with = FALSE]
    
    dtActivityNames <- fread(file.path("./data/activity_labels.txt"))
    setnames(dtActivityNames, names(dtActivityNames), c("activityNum", "activityName"))
    # use descriptive activity names
    dt <- merge(dt, dtActivityNames, by = "activityNum", all.x = TRUE)
    setkey(dt, subject, activityNum, activityName)
    dt <- data.table(melt(dt, key(dt), variable.name = "featureCode"))
    dt <- merge(dt, dtFeatures[, list(featureNum, featureCode, featureName)], by = "featureCode", all.x = TRUE)
    
    dt$activity <- factor(dt$activityName)
    dt$feature <- factor(dt$featureName)
    #Separate features from featureName using the helper function
    n <- 2
    y <- matrix(seq(1, n), nrow = n)
    x <- matrix(c(grepthis("^t"), grepthis("^f")), ncol = nrow(y))
    dt$featDomain <- factor(x %*% y, labels = c("Time", "Freq"))
    x <- matrix(c(grepthis("Acc"), grepthis("Gyro")), ncol = nrow(y))
    dt$featInstrument <- factor(x %*% y, labels = c("Accelerometer", "Gyroscope"))
    x <- matrix(c(grepthis("BodyAcc"), grepthis("GravityAcc")), ncol = nrow(y))
    dt$featAcceleration <- factor(x %*% y, labels = c(NA, "Body", "Gravity"))
    x <- matrix(c(grepthis("mean()"), grepthis("std()")), ncol = nrow(y))
    dt$featVariable <- factor(x %*% y, labels = c("Mean", "SD"))
    
    dt$featJerk <- factor(grepthis("Jerk"), labels = c(NA, "Jerk"))
    dt$featMagnitude <- factor(grepthis("Mag"), labels = c(NA, "Magnitude"))
    
    n <- 3
    y <- matrix(seq(1, n), nrow = n)
    x <- matrix(c(grepthis("-X"), grepthis("-Y"), grepthis("-Z")), ncol = nrow(y))
    dt$featAxis <- factor(x %*% y, labels = c(NA, "X", "Y", "Z"))
    
    #Create a data set with the average of each variable for each activity and each subject
    setkey(dt, subject, activity, featDomain, featAcceleration, featInstrument, featJerk, featMagnitude, featVariable, featAxis)
    dtTidy <- dt[, list(count = .N, average = mean(value)), by = key(dt)]
    write.table(dtTidy, "data_with_means.txt")
}
