library(dplyr)
library(reshape2)

#Functions to read in data for train and test
read.train <- function(){
  cls <- c('integer','integer','Date','numeric','logical') #Classes for Store, Dept, Date, Weekly_Sales, isHoliday
  train<- read.csv(file='data/train.csv',colClasses = cls)
  train<-tbl_df(train)
}

read.test <- function(){
  cls <- c('integer','integer','Date','logical') #Classes for Store, Dept, Date, isHoliday
  test<- read.csv(file='data/test.csv',colClasses = cls)
  test<- tbl_df(test)
}

reshape.by.stores <- function(train){
  #Reshape the train data into a matrix containing the weekly sales for each store
  #This is preparation required for time series clustering
  #Input: Train dataset which contain multiple rows x 4 column variables
  #Output: Matrix of 143 weekly sales observations x 45 stores
  store.matrix <- dcast(train,formula=Date~Store,value.var = "Weekly_Sales",fun.aggregate = sum)
  store.matrix <- tbl_df(store.matrix)
  return(store.matrix)
}


write.submission <- function(pred){
  #Create a csv file for submission to kaggle
  #Input: prediction data table
  #Output: CSV with 2 columns - ID, Weekly_Sales
  pred$ID <- paste0(pred$Store, "_",
               pred$Dept, "_",
               pred$Date)
  submit.path <- paste0('submissions/',Sys.Date(),'.csv')
  submission <- subset(pred,select=c('ID','Weekly_Sales'))
  write.csv(submission,file=submit.path,row.names=FALSE)
  
}


