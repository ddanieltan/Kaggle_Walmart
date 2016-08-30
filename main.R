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

#To get an estimate coefficients for AR and MA, plot the ACF and PACF curve for each cluster
#The PACF and ACF lag orders which cross the confidence boundaries, are candidates for AR and MA coefficients respectively
tsdisplay(cluster1.ts)
tsdisplay(cluster2.ts)
tsdisplay(cluster3.ts)
tsdisplay(cluster4.ts)

#It is observed that all 4 clusters have a clear seasonal pattern for period length of 52 weeks.
#Hence, the seasonal order for ARIMA modeling will be defaulted to 'seasonal= list(order = c(0,1,0), period = 52'
#To find the optimal pdq coeffecients for the trend component, run the following function for each cluster

#Please be warned that this function takes a long time because it runs every possible combination of input coefficients
#If you prefer to manually test for optimal pdq, please skip to the next step
optimal.pdq(5,1,2,cluster1.ts) #Optimal pdq = (1,0,1)
optimal.pdq(5,1,2,cluster2.ts) #Optimal pdq = (1,0,2)
optimal.pdq(5,1,5,cluster3.ts) #Optimal pdq = (1,0,1)
optimal.pdq(5,1,5,cluster4.ts) #Optimal pdq = (1,0,1)

#If the method above takes too long to process, you can manually try out combinations of p,d,q using the code below.
cluster1.fit<-Arima(cluster1.ts,order=c(1,0,1), seasonal = list(order = c(0,1,0), period = 52), include.mean = FALSE)#AIC=2174.26   AICc=2174.54   BIC=2181.79
cluster2.fit<-Arima(cluster2.ts,order=c(1,0,2), seasonal = list(order = c(0,1,0), period = 52), include.mean = FALSE)#AIC=2221.03   AICc=2221.49   BIC=2231.07
cluster3.fit<-Arima(cluster3.ts,order=c(1,0,1), seasonal = list(order = c(0,1,0), period = 52), include.mean = FALSE)#AIC=2225.74   AICc=2226.02   BIC=2233.28
cluster4.fit<-Arima(cluster4.ts,order=c(1,0,1), seasonal = list(order = c(0,1,0), period = 52), include.mean = FALSE)#AIC=2207.87   AICc=2208.15   BIC=2215.41

###4. Evaluating forecast accuracy
#
#
# Visually check the fit of the arima model by plotting the ACF, PACF graph of the residuals
# Residuals which fall within the confidence boundaries suggest a good fit
tsdisplay(residuals(cluster1.fit))
tsdisplay(residuals(cluster2.fit))
tsdisplay(residuals(cluster3.fit))
tsdisplay(residuals(cluster4.fit))

# Testing the accuracy of Arima model based on subsetting my existing 143 train data, to a 120 mini-train data, and 23 mini-test data
# To calculate the MAPE of the 4 ARIMA models
calc.mape(cluster1.ts,cluster1.fit) #5.837927
calc.mape(cluster2.ts,cluster2.fit) #5.824512
calc.mape(cluster3.ts,cluster3.fit) #5.570019
calc.mape(cluster4.ts,cluster4.fit) #6.833386

#Next, I test the overall accuracy of ARIMA model applied to the entire training set against Kaggle's test data
#I added 2 other simple forecast methods as benchmarks
#The seasonal naive model predicts future weekly sales using the weekly sales exactly 1 year before
#The tslm model predicts future weekly sales using linear regression, and dummy seasonal variables

pred1 <- apply.forecast(train,test,'seasonal.naive')
pred2 <- apply.forecast(train,test,'tslm')
pred3 <- apply.forecast(train,test,'arima.m')

#Write submission files to be uploaded on Kaggle
write.submission(pred1)
write.submission(pred2)
write.submission(pred3)

###4. Project Summary
#
#
#
library(knitr)
knit(input="summary.rmd", output = "summary.md") 