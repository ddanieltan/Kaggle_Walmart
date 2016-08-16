library(dplyr)

#In this iteration, I have decided to ignore the features provided
#in features.csv on the assumption that the strongest variable affecting
#weekly sales is the seasonality of dates and isHoliday

#Functions to read in data for train and test
read.train <- function(){
  cls <- c('factor','factor','Date','numeric','logical') #Classes for Store, Dept, Date, Weekly_Sales, isHoliday
  train<- read.csv(file='data/train.csv',colClasses = cls)
}

read.test <- function(){
  cls <- c('factor','factor','Date','logical') #Classes for Store, Dept, Date, isHoliday
  train<- read.csv(file='data/test.csv',colClasses = cls)
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