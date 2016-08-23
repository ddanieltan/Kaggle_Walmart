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


train.sub <- filter(train,row_number(Date)<=12)
train.sub
dcast(train.sub, Date~Store + Dept, value.var="Weekly_Sales")