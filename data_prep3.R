library(dplyr)

#In this iteration, I have decided to ignore the features provided
#in features.csv on the assumption that the strongest variable affecting
#weekly sales is the seasonality of dates and isHoliday

###Read in data with correct classes
read.train <- function(){
  #Classes for Store, Dept, Date, Weekly_Sales, isHoliday
  cls <- c('factor','factor','Date','numeric','logical')
  train<- read.csv(file='data/train.csv',colClasses = cls)
}

###Read in data with correct classes
read.test <- function(){
  #Classes for Store, Dept, Date, isHoliday
  cls <- c('factor','factor','Date','logical')
  train<- read.csv(file='data/test.csv',colClasses = cls)
}