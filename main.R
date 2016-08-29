source('data_prep.R')
source('forecast.R')
source('clustering.R')

###1. Data preparation
#
#
#Load train and test dataset
train <- read.train()
test <- read.test()


###2. Time Series Clustering
#
#
#Reshape train data into 143 weeks x 45 store matrix
store.matrix <- reshape.by.stores(train)

#Perform and plot hierarchical clustering based on dissimilarity computation of weekly sales vs stores
tsdist<-calculate.ts.dist(store.matrix)
hc<-hclust(tsdist)
plot(hc)

#Upon visual inspection of the cluster plot, I decide to cluster the data into 4 clusters
rect.hclust(hc,k=4)
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

###3. Time Series Forecasting
#
#
#Test for stationarity by performing ADF test
adf.test(cluster1.ts, alternative='stationary') #Dickey-Fuller = -5.279, Lag order = 5, p-value = 0.01
adf.test(cluster2.ts, alternative='stationary') #Dickey-Fuller = -5.2943, Lag order = 5, p-value = 0.01
adf.test(cluster3.ts, alternative='stationary') #Dickey-Fuller = -5.3377, Lag order = 5, p-value = 0.01
adf.test(cluster4.ts, alternative='stationary') #Dickey-Fuller = -5.1801, Lag order = 5, p-value = 0.01
#

###4. Comparing Arima Forecasts with 2 simpler forecasts
pred1 <- apply.forecast(train,test,'seasonal.naive')
pred2 <- apply.forecast(train,test,'tslm')
pred3 <- apply.forecast(train,test,'arima.f',12)

#Write submission files to be uploaded on Kaggle
write.submission(pred1)
write.submission(pred2)
write.submission(pred3)

###4. Project Summary
#
#
library(knitr)
knit(input="summary.rmd", output = "summary.md") 