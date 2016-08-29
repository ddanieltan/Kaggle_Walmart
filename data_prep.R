library(dplyr)
library(reshape2)

#In this iteration, I have decided to ignore the features provided
#in features.csv on the assumption that the strongest variable affecting
#weekly sales is the seasonality of dates and isHoliday

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

master.ts <- function(train){
  master.ts <- dcast(train, Date~Store + Dept, value.var="Weekly_Sales",na.rm=TRUE)
  master.ts<- tbl_df(master.ts)
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


