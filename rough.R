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


#select unique store-depts that appear in test set
unique.test.pairs <- unique(test[,c("Store","Dept")])
unique.test.pairs<-mutate(unique.test.pairs,id=paste(Store,"_",Dept,sep="")) #3169

col.num <- which(colnames(mts) %in% unique.test.pairs$id) #3158
mts.test.pairs <-mts[,col.num] #3158

#check for NAs
sapply(mts.test.pairs, function(x) sum(is.na(x)))

#removing NAs from mts.test.pairs
mts.rmna <- mts.test.pairs[, colSums(is.na(mts.test.pairs)) == 0] #2660

#Performing TSClust
library(TSClust)
tsdist <- diss(mts.rmna, "ACF", p=0.05) #this takes way too long

#Performing correlation analysis
mts.cor <- cor(mts.rmna) #2660x2660 matrix
hc<-hclust(mts.cor) #Error in if (is.na(n) || n > 65536L) stop("size cannot be NA nor exceed 65536")

#trying to use corrplot to visualize mts.cor
library(corrplot)
mts.corrplot<- corrplot(mts.cor,method="square",order="hclust")
