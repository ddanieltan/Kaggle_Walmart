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

#df2010 <- train[train$Date <= "2011-01-01",]
#dfstore1 <- train[train$Store == 1,]
#s1d1 <- train %>%
#  filter(train$Store==1,train$Dept==1)

png(filename = 'visualizations/test.png')
plot(s1d1$Weekly_Sales~s1d1$Date,type="l")
dev.off()

#There are a total of 45 unique store numbers from 1 to 45.
#There are a total of 81 unique dept numbers from 1 to 99.
#Creating a df of unique store and dept pairs.
unique_pairs <- unique(train[,c("Store","Dept")])

#Creating visualizations of the weekly sales for each store-dept pair
for (i in unique_pairs){
  temp_store <- unique_pairs[i,]$Store
  temp_dept <- unique_pairs[i,]$Dept
  #new_df <- filter(train,train$Store==temp_store,train$Dept==temp_dept)
  new_df <- train %>% filter(train$Store==temp_store, train$Dept==temp_dept)
  name_of_file <- paste("visualizations/store",temp_store,"_dept",temp_dept,".png",sep="")
  png(filename=name_of_file)
  plot(new_df$Weekly_Sales~new_df$Date,type="l",
       main=name_of_file,
       xlab="Date",
       ylab = "Weekly Sales")
  dev.off()
}

for (i in 1:45){
  for (j in dept_num_list){
    new_df <- filter(train,train$Store==i,train$Dept==j)
    name_of_file <- paste("visualizations/store",i,"_dept",j,".png",sep="")
    
    png(filename=name_of_file)
    plot(new_df$Weekly_Sales~new_df$Date,type="l",
         main=name_of_file,
         xlab="Date",
         ylab = "Weekly Sales")
    dev.off()
  }
}
