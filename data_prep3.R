library(dplyr)

#In this iteration, I have decided to ignore the features provided
#in features.csv on the assumption that the strongest variable affecting
#weekly sales is the seasonality of dates and isHoliday

#Functions to read in data for train and test
read.train <- function(){
  cls <- c('factor','factor','Date','numeric','logical') #Classes for Store, Dept, Date, Weekly_Sales, isHoliday
  train<- read.csv(file='data/train.csv',colClasses = cls)
  train<-tbl_df(train)
}

read.test <- function(){
  cls <- c('factor','factor','Date','logical') #Classes for Store, Dept, Date, isHoliday
  test<- read.csv(file='data/test.csv',colClasses = cls)
  test<- tbl_df(test)
}

master.ts <- function(train){
  master.ts <- dcast(train, Date~Store + Dept, value.var="Weekly_Sales")
  master.ts<- tbl_df(master.ts)
}

reshape.ts <- function(train,test){
  test.dates <- unique(test$Date)
  num.test.dates <- length(test.dates)
  all.stores <- unique(test$Store)
  num.stores <- length(all.stores)
  test.depts <- unique(test$Dept)
  #reverse the depts so the grungiest data comes first
  test.depts <- test.depts[length(test.depts):1]
  forecast.frame <- data.frame(Date=rep(test.dates, num.stores),
                               Store=rep(all.stores, each=num.test.dates))
  pred <- test
  pred$Weekly_Sales <- 0
  
  train.dates <- unique(train$Date)
  num.train.dates <- length(train.dates)
  train.frame <- data.frame(Date=rep(train.dates, num.stores),
                            Store=rep(all.stores, each=num.train.dates))
  
  unique_pairs <- unique(train[,c("Store","Dept")])
  tr.d <- train.frame
  
  for(i in 1:nrow(unique_pairs)){
    
  }
  
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


