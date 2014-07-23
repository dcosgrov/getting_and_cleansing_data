# Script Name: run_analysis.R
# Author: D.Cosgrove

# libraries to include
library(plyr) # needed for ddply

# build up the TRAINING data including activity
# and subject data.  This requires the merging
# of 3 separate files.
trainingData <- read.table('X_train.txt')
trainingActivities <- read.table('y_train.txt')
trainingActivities$V1 <- factor(trainingActivities$V1,
                                levels = c(1,2,3,4,5,6),
                                labels = c("WALKING","WALKING UPSTAIRS",
                                           "WALKING DOWNSTAIRS",
                                           "SITTING","STANDING","LAYING"))

trainingSubjects <- read.table('subject_train.txt', nrows=testRowCount)


# build up the TEST data including activity
# and subject data.  This requires the merging
# of 3 separate files.
testData <- read.table('X_test.txt', nrows=testRowCount )
testActivities <- read.table('y_test.txt', nrows=testRowCount)
testActivities$V1 <- factor(testActivities$V1,
                                levels = c(1,2,3,4,5,6),
                                labels = c("WALKING","WALKING UPSTAIRS","WALKING DOWNSTAIRS",
                                          "SITTING","STANDING","LAYING"))

testSubjects <- read.table('subject_test.txt', nrows=testRowCount)

############################################################################
# Extract only mean and standard deviation columns/variables numbers.
#
# To determine which column numbers are mean and standard deviation related,
# I built up 2 files by simply grep'ing the features.txt file like below:
#
# Determine mean related column numbers:
# grep -i "mean()" features.txt > means.txt

# Determine standard deviation related column numbers:
# grep -i "std()" features.txt > stddev.txt
#
# Combine the 2 files to get the overall list of relevant mean and
# standard deviation related column numbers:
# cat means.txt stddev.txt > means_and_stddevs.txt 
#
# the means_and_stddevs.txt file contains 2 fields (column number
# and the source variable name)
# the "V" column numbers below represent only those columns which 
# contain mean() or std() as suffixes in their names since this 
# naming conventions conforms with what is outlined in features_info.txt
# The column numbers below were simply copied from means_and_stddevs.txt
# that I demonstrated how I built above.
############################################################################

meansAndStandardDeviationColumns <- c("V1","V2","V3","V41","V42","V43",
                        "V81","V82","V83","V121","V122","V123",
                        "V161","V162","V163","V201","V214","V227",
                        "V240","V253","V266","V267","V268","V345",
                        "V346","V347","V424","V425","V426","V503",
                        "V516","V529","V542",
                        "V4","V5","V6","V44","V45","V46",
                        "V84","V85","V86","V124","V125","V126",
                        "V164","V165","V166","V202","V215","V228",
                        "V241","V254","V269","V270","V271","V348",
                        "V349","V350","V427","V428","V429","V504",
                        "V517","V530","V543")

############################################################################
# Below, I assign more user-facing, tidy names to the dataset
# to improve readability.  The names were built based on a review of
# features_info.txt
#
# The variable name mapping was built using the following conventions:
#
# t = time
# f = frequency
# Acc = Acceleration
# Max = Magnitude
# X = x_axis
# Y = y_axis
# Z = z_axis
# std() = stddev (standard deviation)
#
# I also used underscores "_" to separate components of the variable
# names for improved readability and consistency.
#
# Source column names appears as inline comments next to each 
# new column name so it is clear which underlying source column
# serves as input into each new column name.
#
# For example, the new column named "time_body_acceleration_mean_x_axis"
# is sourced from "tBodyAcc-mean()-X".
#
############################################################################
tidyColumnNames <- c(
"subject", # source data are subject_test.txt and subject_train.txt
"activity", # source data are y_test.txt and y_train.txt
"time_body_acceleration_mean_x_axis", # tBodyAcc-mean()-X
"time_body_acceleration_mean_y_axis", # tBodyAcc-mean()-Y
"time_body_acceleration_mean_z_axis", # tBodyAcc-mean()-Z
"time_gravity_acceleration_mean_x_axis", # tGravityAcc-mean()-X
"time_gravity_acceleration_mean_y_axis", #tGravityAcc-mean()-Y
"time_gravity_acceleration_mean_z_axis", #tGravityAcc-mean()-Z
"time_body_acceleration_jerk_mean_x_axis",  #tBodyAccJerk-mean()-X
"time_body_acceleration_jerk_mean_y_axis",  #tBodyAccJerk-mean()-Y
"time_body_acceleration_jerk_mean_z_axis",  #tBodyAccJerk-mean()-Z
"time_body_gyro_mean_x_axis",  # tBodyGyro-mean()-X
"time_body_gyro_mean_y_axis",  # tBodyGyro-mean()-Y
"time_body_gyro_mean_z_axis",  # tBodyGyro-mean()-Z
"time_body_gyro_jerk_mean_x_axis",  # tBodyGyroJerk-mean()-X
"time_body_gyro_jerk_mean_y_axis",  # tBodyGyroJerk-mean()-Y
"time_body_gyro_jerk_mean_z_axis",  # tBodyGyroJerk-mean()-Z
"time_body_acceleration_magnitude_mean", #tBodyAccMag-mean()
"time_gravity_acceleration_magnitude_mean", #tGravityAccMag-mean()
"time_body_acceleration_jerk_magnitude_mean", #tBodyAccJerkMag-mean()
"time_body_gyro_magnitude_mean", #tBodyGyroMag-mean()
"time_body_gyro_jerk_magnitude_mean", #tBodyGyroJerkMag-mean()
"frequency_body_acceleration_mean_x_axis", #fBodyAcc-mean()-X
"frequency_body_acceleration_mean_y_axis", #fBodyAcc-mean()-Y
"frequency_body_acceleration_mean_z_axis", #fBodyAcc-mean()-Z
"frequency_body_acceleration_jerk_mean_x_axis", #fBodyAccJerk-mean()-X
"frequency_body_acceleration_jerk_mean_y_axis", #fBodyAccJerk-mean()-Y
"frequency_body_acceleration_jerk_mean_z_axis", #fBodyAccJerk-mean()-Z
"frequency_body_gyro_mean_x_axis", #fBodyGyro-mean()-X
"frequency_body_gyro_mean_y_axis", #fBodyGyro-mean()-Y
"frequency_body_gyro_mean_z_axis", #fBodyGyro-mean()-Z
"frequency_body_acceleration_magnitude_mean", #fBodyAccMag-mean()
"frequency_body_acceleration_jerk_magnitude_mean", #fBodyBodyAccJerkMag-mean()
"frequency_body_gyro_magnitude_mean", #fBodyBodyGyroMag-mean()
"frequency_body_gyro_jerk_magnitude_mean", #fBodyBodyGyroJerkMag-mean()
"time_body_acceleration_stddev_x_axis", #tBodyAcc-std()-X
"time_body_acceleration_stddev_y_axis", #tBodyAcc-std()-Y
"time_body_acceleration_stddev_z_axis", #tBodyAcc-std()-Z"
"time_gravity_acceleration_stddev_x_axis", #tGravityAcc-std()-X
"time_gravity_acceleration_stddev_y_axis", #tGravityAcc-std()-Y
"time_gravity_acceleration_stddev_z_axis", #tGravityAcc-std()-Z
"time_body_acceleration_jerk_stddev_x_axis", #tBodyAccJerk-std()-X
"time_body_acceleration_jerk_stddev_y_axis", #tBodyAccJerk-std()-Y
"time_body_acceleration_jerk_stddev_z_axis", #tBodyAccJerk-std()-Z
"time_body_gyro_stddev_x_axis", #tBodyGyro-std()-X
"time_body_gyro_stddev_y_axis", #tBodyGyro-std()-Y
"time_body_gyro_stddev_z_axis", #tBodyGyro-std()-Z
"time_body_gyro_jerk_stddev_x_axis", #tBodyGyroJerk-std()-X
"time_body_gyro_jerk_stddev_y_axis", #tBodyGyroJerk-std()-Y
"time_body_gyro_jerk_stddev_z_axis", #tBodyGyroJerk-std()-Z
"time_body_acceleration_magnitude_stddev", #tBodyAccMag-std()
"time_gravity_acceleration_magnitude_stddev", #tGravityAccMag-std()
"time_body_acceleration_jerk_magnitude_stddev", #tBodyAccJerkMag-std()
"time_body_gyro_magnitude_stddev", #tBodyGyroMag-std()
"time_body_gyro_jerk_magnitude_stddev", #tBodyGyroJerkMag-std()
"frequency_body_acceleration_stddev_x_axis", #fBodyAcc-std()-X
"frequency_body_acceleration_stddev_y_axis", #fBodyAcc-std()-Y
"frequency_body_acceleration_stddev_z_axis", #fBodyAcc-std()-Z
"frequency_body_acceleration_jerk_stddev_x_axis", #fBodyAccJerk-std()-X
"frequency_body_acceleration_jerk_stddev_y_axis", #fBodyAccJerk-std()-Y
"frequency_body_acceleration_jerk_stddev_z_axis", #fBodyAccJerk-std()-Z
"frequency_body_gyro_stddev_x_axis", #fBodyGyro-std()-X
"frequency_body_gyro_stddev_y_axis", #fBodyGyro-std()-Y
"frequency_body_gyro_stddev_z_axis", #fBodyGyro-std()-Z
"frequency_body_acceleration_magnitude_stddev", #fBodyAccMag-std()
"frequency_body_acceleration_jerk_magnitude_stddev", #fBodyBodyAccJerkMag-std()
"frequency_body_gyro_magnitude_stddev", #fBodyBodyGyroMag-std()
"frequency_body_gyro_jerk_magnitude_stddev" #fBodyBodyGyroJerkMag-std()
)

# Combine all TRAINING data tables 
# from sources:
# X_train.txt - raw training data ( only mean() and std() columns )
# y_train.txt - training activity values
# subject_train.txt - training subject values)
trainingData <- trainingData[meansAndStandardDeviationColumns]
combinedTraining <- cbind(trainingSubjects, trainingActivities, trainingData)

# Combine all TEST data tables
# from sources:
# X_test.txt - raw test data ( only mean() and std() columns )
# y_test.txt - test activity values
# subject_test.txt - test subject values)
testData <- testData[meansAndStandardDeviationColumns]
combinedTest <- cbind(testSubjects,testActivities,testData)

# Combine overall TEST and overall TRAINING data into one new dataset
combinedData <- rbind( combinedTraining, combinedTest )

# Assign more meaningful column names to the combined dataset
colnames(combinedData) <- tidyColumnNames

# Remove source data from memory that is no longer needed
remove(testActivities, testData, testSubjects)
remove(trainingActivities, trainingData, trainingSubjects)
remove(combinedTraining, combinedTest)

# Create a new tidy data set containing summary/aggregate data
# that reflects the mean value of every metric in the combinedData
# for each unique activity/subject combination.
summaryData <- ddply(combinedData, .(activity,subject), numcolwise(mean) )

tidySummaryColumnNames <- c(
  "activity", # source data are y_test.txt and y_train.txt
  "subject", # source data are subject_test.txt and subject_train.txt
  "summary_mean_time_body_acceleration_mean_x_axis", # tBodyAcc-mean()-X
  "summary_mean_time_body_acceleration_mean_y_axis", # tBodyAcc-mean()-Y
  "summary_mean_time_body_acceleration_mean_z_axis", # tBodyAcc-mean()-Z
  "summary_mean_time_gravity_acceleration_mean_x_axis", # tGravityAcc-mean()-X
  "summary_mean_time_gravity_acceleration_mean_y_axis", #tGravityAcc-mean()-Y
  "summary_mean_time_gravity_acceleration_mean_z_axis", #tGravityAcc-mean()-Z
  "summary_mean_time_body_acceleration_jerk_mean_x_axis",  #tBodyAccJerk-mean()-X
  "summary_mean_time_body_acceleration_jerk_mean_x_axis",  #tBodyAccJerk-mean()-Y
  "summary_mean_time_body_acceleration_jerk_mean_x_axis",  #tBodyAccJerk-mean()-Z
  "summary_mean_time_body_gyro_mean_x_axis",  # tBodyGyro-mean()-X
  "summary_mean_time_body_gyro_mean_y_axis",  # tBodyGyro-mean()-Y
  "summary_mean_time_body_gyro_mean_z_axis",  # tBodyGyro-mean()-Z
  "summary_mean_time_body_gyro_jerk_mean_x_axis",  # tBodyGyroJerk-mean()-X
  "summary_mean_time_body_gyro_jerk_mean_y_axis",  # tBodyGyroJerk-mean()-Y
  "summary_mean_time_body_gyro_jerk_mean_z_axis",  # tBodyGyroJerk-mean()-Z
  "summary_mean_time_body_acceleration_magnitude_mean", #tBodyAccMag-mean()
  "summary_mean_time_gravity_acceleration_magnitude_mean", #tGravityAccMag-mean()
  "summary_mean_time_body_acceleration_jerk_magnitude_mean", #tBodyAccJerkMag-mean()
  "summary_mean_time_body_gyro_magnitude_mean", #tBodyGyroMag-mean()
  "summary_mean_time_body_gyro_jerk_magnitude_mean", #tBodyGyroJerkMag-mean()
  "summary_mean_frequency_body_acceleration_mean_x_axis", #fBodyAcc-mean()-X
  "summary_mean_frequency_body_acceleration_mean_y_axis", #fBodyAcc-mean()-Y
  "summary_mean_frequency_body_acceleration_mean_z_axis", #fBodyAcc-mean()-Z
  "summary_mean_frequency_body_acceleration_jerk_mean_x_axis", #fBodyAccJerk-mean()-X
  "summary_mean_frequency_body_acceleration_jerk_mean_y_axis", #fBodyAccJerk-mean()-Y
  "summary_mean_frequency_body_acceleration_jerk_mean_z_axis", #fBodyAccJerk-mean()-Z
  "summary_mean_frequency_body_gyro_mean_x_axis", #fBodyGyro-mean()-X
  "summary_mean_frequency_body_gyro_mean_y_axis", #fBodyGyro-mean()-Y
  "summary_mean_frequency_body_gyro_mean_z_axis", #fBodyGyro-mean()-Z
  "summary_mean_frequency_body_acceleration_magnitude_mean", #fBodyAccMag-mean()
  "summary_mean_frequency_body_acceleration_jerk_magnitude_mean", #fBodyBodyAccJerkMag-mean()
  "summary_mean_frequency_body_gyro_magnitude_mean", #fBodyBodyGyroMag-mean()
  "summary_mean_frequency_body_gyro_jerk_magnitude_mean", #fBodyBodyGyroJerkMag-mean()
  "summary_mean_time_body_acceleration_stddev_x_axis", #tBodyAcc-std()-X
  "summary_mean_time_body_acceleration_stddev_y_axis", #tBodyAcc-std()-Y
  "summary_mean_time_body_acceleration_stddev_z_axis", #tBodyAcc-std()-Z"
  "summary_mean_time_gravity_acceleration_stddev_x_axis", #tGravityAcc-std()-X
  "summary_mean_time_gravity_acceleration_stddev_y_axis", #tGravityAcc-std()-Y
  "summary_mean_time_gravity_acceleration_stddev_z_axis", #tGravityAcc-std()-Z
  "summary_mean_time_body_acceleration_jerk_stddev_x_axis", #tBodyAccJerk-std()-X
  "summary_mean_time_body_acceleration_jerk_stddev_y_axis", #tBodyAccJerk-std()-Y
  "summary_mean_time_body_acceleration_jerk_stddev_z_axis", #tBodyAccJerk-std()-Z
  "summary_mean_time_body_gyro_stddev_x_axis", #tBodyGyro-std()-X
  "summary_mean_time_body_gyro_stddev_y_axis", #tBodyGyro-std()-Y
  "summary_mean_time_body_gyro_stddev_z_axis", #tBodyGyro-std()-Z
  "summary_mean_time_body_gyro_jerk_stddev_x_axis", #tBodyGyroJerk-std()-X
  "summary_mean_time_body_gyro_jerk_stddev_y_axis", #tBodyGyroJerk-std()-Y
  "summary_mean_time_body_gyro_jerk_stddev_z_axis", #tBodyGyroJerk-std()-Z
  "summary_mean_time_body_acceleration_magnitude_stddev", #tBodyAccMag-std()
  "summary_mean_time_gravity_acceleration_magnitude_stddev", #tGravityAccMag-std()
  "summary_mean_time_body_acceleration_jerk_magnitude_stddev", #tBodyAccJerkMag-std()
  "summary_mean_time_body_gyro_magnitude_stddev", #tBodyGyroMag-std()
  "summary_mean_time_body_gyro_jerk_magnitude_stddev", #tBodyGyroJerkMag-std()
  "summary_mean_frequency_body_acceleration_stddev_x_axis", #fBodyAcc-std()-X
  "summary_mean_frequency_body_acceleration_stddev_y_axis", #fBodyAcc-std()-Y
  "summary_mean_frequency_body_acceleration_stddev_z_axis", #fBodyAcc-std()-Z
  "summary_mean_frequency_body_acceleration_jerk_stddev_x_axis", #fBodyAccJerk-std()-X
  "summary_mean_frequency_body_acceleration_jerk_stddev_y_axis", #fBodyAccJerk-std()-Y
  "summary_mean_frequency_body_acceleration_jerk_stddev_z_axis", #fBodyAccJerk-std()-Z
  "summary_mean_frequency_body_gyro_stddev_x_axis", #fBodyGyro-std()-X
  "summary_mean_frequency_body_gyro_stddev_y_axis", #fBodyGyro-std()-Y
  "summary_mean_frequency_body_gyro_stddev_z_axis", #fBodyGyro-std()-Z
  "summary_mean_frequency_body_acceleration_magnitude_stddev", #fBodyAccMag-std()
  "summary_mean_frequency_body_acceleration_jerk_magnitude_stddev", #fBodyBodyAccJerkMag-std()
  "summary_mean_frequency_body_gyro_magnitude_stddev", #fBodyBodyGyroMag-std()
  "summary_mean_frequency_body_gyro_jerk_magnitude_stddev" #fBodyBodyGyroJerkMag-std()
)

colnames(summaryData) <- tidySummaryColumnNames

# Write the summary data out to a file for subsequent processing
write.table(summaryData, file="summary_data.out")
