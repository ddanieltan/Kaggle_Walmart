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

master.ts <- function(train,test){
  #Take in raw train data and extract time series as (No. of weeks) x (TS1, TS2, TS3 ...)
  #mts <- matrix(nrow=143,ncol=3331) #1 head, 143 weekly sales for 3331 time series
  mts <- matrix()
  
  #There are a total of 45 unique store numbers from 1 to 45.
  #There are a total of 81 unique dept numbers from 1 to 99.
  #Creating a df of unique store and dept pairs.
  unique_pairs <- unique(train[,c("Store","Dept")]) #There are 3331 unique pairs of store-depts ie. 3331 Time-series
  for(i in 1:nrow(unique_pairs)){
    temp.store <- unique_pairs[i,]$Store
    temp.dept <- unique_pairs[i,]$Store
    ts.name <- c(temp.store,"_",temp.dept)
    new_df <- filter(train,train$Store==unique_pairs[i,1],train$Dept==unique_pairs[i,2])
    
    mts$ts.name<-new_df$Weekly_Sales
    
    
  }
  mts
}

master2.ts <- function(train,test){
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


