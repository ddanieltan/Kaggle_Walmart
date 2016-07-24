library(dplyr)
library(tidyr)
library(reshape)

#read in data
dfStore <- read.csv(file='data/stores.csv')
dfTrain <- read.csv(file='data/train.csv')
dfTest <- read.csv(file='data/test.csv')
dfFeatures <- read.csv(file='data/features.csv')
submission = read.csv(file='data/sampleSubmission.csv',header=TRUE,as.is=TRUE)

# Merge Type and Size
dfTrainTmp <- merge(x=dfTrain, y=dfStore, all.x=TRUE)
dfTestTmp <- merge(x=dfTest, y=dfStore, all.x=TRUE)

# Merge all the features
train <- merge(x=dfTrainTmp, y=dfFeatures, all.x=TRUE)
test <- merge(x=dfTestTmp, y=dfFeatures, all.x=TRUE)

#### Convert Date to character
dfTrain$Date <- as.character(dfTrain$Date)
dfTest$Date <- as.character(dfTest$Date)
dfFeatures$Date <- as.character(dfFeatures$Date)

#### Compute the number of days back to baseline date
baseline_date <- as.Date('2010-02-05')
dfTrain$Days <- as.numeric(as.Date(dfTrain$Date) - baseline_date)
dfTest$Days <- as.numeric(as.Daplote(dfTest$Date) - baseline_date)

#### Compute the corresponding day index for plotting figure
all_dates <- sort(unique(dfFeatures$Date))
dfTrain$Day_Index <- sapply(dfTrain$Date, function(d)which(d==all_dates))
dfTest$Day_Index <- sapply(dfTest$Date, function(d)which(d==all_dates))

#### Split Date into Year/Month/Day
## train
d <- strsplit(dfTrain$Date, '-')
d <- as.numeric(unlist(d))
d <- matrix(d, dim(dfTrain)[1], 3, byrow=T)
dfTrain$Year <- d[,1]
dfTrain$Month <- d[,2]
dfTrain$Day <- d[,3]
## test
d <- strsplit(dfTest$Date, '-')
d <- as.numeric(unlist(d))
d <- matrix(d, dim(dfTest)[1], 3, byrow=T)
dfTest$Year <- d[,1]
dfTest$Month <- d[,2]
dfTest$Day <- d[,3]
