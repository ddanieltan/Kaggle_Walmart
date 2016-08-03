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

#Converting Date values to Date class
train$Date <- as.Date(train$Date)
test$Date <- as.Date(test$Date)

#There are a total of 45 unique store numbers from 1 to 45.
#There are a total of 81 unique dept numbers from 1 to 99.
#Creating a df of unique store and dept pairs.
unique_pairs <- unique(train[,c("Store","Dept")])

#Creating visualizations of the weekly sales for each store-dept pair
for (i in 1:nrow(unique_pairs)){
  new_df <- filter(train,train$Store==unique_pairs[i,1],train$Dept==unique_pairs[i,2])
  name_of_file <- paste("visualizations/store",unique_pairs[i,1],"_dept",unique_pairs[i,2],".png",sep="")
  png(filename=name_of_file)
  plot(new_df$Weekly_Sales~new_df$Date,type="l",
   main=name_of_file,
   xlab="Date",
   ylab = "Weekly Sales")
  dev.off()
}

#Create a subset of just Weekly Sales for each store-dept pair
s1d1 <- train %>%
  filter(Store == 1, Dept == 1) %>%
  select(5) #Weekly_Sales

#Creating a ts object for each store-dept pair
s1d1.ts <- ts(s1d1,frequency=52)


