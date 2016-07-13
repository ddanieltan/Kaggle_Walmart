library(dplyr)
library(tidyr)

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
