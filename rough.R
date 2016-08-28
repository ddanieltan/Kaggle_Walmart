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
sapply(store.matrix, function(x) sum(is.na(x)))

#removing NAs from mts.test.pairs
mts.rmna <- mts.test.pairs[, colSums(is.na(mts.test.pairs)) == 0] #2660 

#Performing TSClust
library(TSclust)
tsdist <- diss(mts.rmna, "ACF", p=0.05) #this takes way too long

#Performing correlation analysis
mts.cor <- cor(mts.rmna) #2660x2660 matrix
hc<-hclust(mts.cor) #Error in if (is.na(n) || n > 65536L) stop("size cannot be NA nor exceed 65536")

#trying to use corrplot to visualize mts.cor
library(corrplot)
mts.corrplot<- corrplot(mts.cor,method="square",order="hclust")

##
store.matrix.total <- train %>%
  group_by(Store)%>%
  summarise(Weekly_Sales=sum(Weekly_Sales))
store.matrix.total$Store<-as.integer(store.matrix.total$Store)


##
store.matrix <- dcast(train,formula=Date~Store,value.var = "Weekly_Sales",fun.aggregate = sum)
store.matrix <- tbl_df(store.matrix)
store.matrix

##
#Performing TSClust
library(TSclust)
tsdist <-t(select(store.matrix,-1)) #remove date column
tsdist<-scale(tsdist) #standardising data points
tsdist <- diss(tsdist, "ACF", p=0.05)
hc<-hclust(tsdist)
plot(hc)

##
rect.hclust(hc,k=4) # 4 clusters, my choice
rect.hclust(hc,h=0.1) #5 clusters

##
clust.vec <- cutree(hc,k=4)
clust.vec[hc$order]

#temp remove date column from store matrix
store.matrix.wodate <- store.matrix[,-1]

##Creating clusters
cluster1 <- store.matrix.wodate[,clust.vec==1]
cluster2 <- store.matrix.wodate[,clust.vec==2]
cluster3 <- store.matrix.wodate[,clust.vec==3]
cluster4 <- store.matrix.wodate[,clust.vec==4]

##Force clusters in a ts() object
cluster1.ts <-ts(rowMeans(cluster1),frequency=52)
cluster2.ts <-ts(rowMeans(cluster2),frequency=52)
cluster3.ts <-ts(rowMeans(cluster3),frequency=52)
cluster4.ts <-ts(rowMeans(cluster4),frequency=52)

library('forecast')
library('tseries')
#Perform adf test on clusters
adf.test(cluster1.ts, alternative='stationary') #Dickey-Fuller = -5.279, Lag order = 5, p-value = 0.01
adf.test(cluster2.ts, alternative='stationary') #Dickey-Fuller = -5.2943, Lag order = 5, p-value = 0.01
adf.test(cluster3.ts, alternative='stationary') #Dickey-Fuller = -5.3377, Lag order = 5, p-value = 0.01
adf.test(cluster4.ts, alternative='stationary') #Dickey-Fuller = -5.1801, Lag order = 5, p-value = 0.01

#ndiffs(cluster1.ts,test="adf")

#Decompose
cluster1.stl<-stl(cluster1.ts,s.window="periodic")
plot(cluster1.stl,main="STL decomposition for Cluster 1")

cluster1.decomp<-decompose(cluster1.ts)
plot(cluster1.decomp)

#TSdisplay
tsdisplay(cluster1.ts)
tsdisplay(diff(cluster1.ts,52))
tsdisplay(diff(diff(cluster1.ts)))

#Loop to find pdq which minimizes AIC
azfinal.aic <- Inf
azfinal.order <- c(0,0,0)
for (p in 1:5) for (d in 0:1) for (q in 1:4) {
  azcurrent.aic <- AIC(Arima(cluster1.ts, order=c(p, d, q)))
  if (azcurrent.aic < azfinal.aic) {
    azfinal.aic <- azcurrent.aic
    azfinal.order <- c(p, d, q)
    azfinal.arima <- Arima(cluster1.ts, order=azfinal.order)
       }
}
azfinal.order

auto.arima(cluster1.ts, seasonal=TRUE)
Arima(cluster1.ts,order=c(4,1,3))

#build Arima
cluster1.fit<- Arima(cluster1.ts, order=c(1,1,1))