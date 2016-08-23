library(dplyr)
library(reshape2)

source('data_prep3.R')
train <- read.train()
test <- read.test()

train <- select(train,Store,Dept,Date,Weekly_Sales)
melt.df <- melt.data.frame(train, id.vars='Date')


rough <- read.csv(file='data/rough.csv')
rough$Date <- as.Date(rough$Date, format="%d/%m/%Y")
rough <- tbl_df(rough)
dcast(rough, Date ~ Store + Dept, value.var = "Weekly_Sales")

library(dplyr)
library(reshape2)
library(data.table)
dcast(train, formula = Date~Weekly_Sales,value.var = c("Store","Dept"), sep=".") 

cls <- c('factor','factor','Date','numeric','logical') #Classes for Store, Dept, Date, Weekly_Sales, isHoliday
train.rmna<- read.csv(file='data/train.csv',colClasses = cls, na.strings = 0)
train.rmna<-tbl_df(train.rmna)


library(TSClust)
tsdist <- diss(mts.rmna, "ACF", p=0.05) #this takes way too long
hc <- hclust(tsdist)
plot(hc)

#to find sum of NAs in collumns
sapply(mts.rmna, function(x) sum(is.na(x)))

#removing NAs from mts
mts.rmna <- mts[, colSums(is.na(mts)) == 0]
mts.rmna <- subset(mts.rmna, select=-Date)


