library("forecast")
library("tseries")
library("dplyr")
library("plyr")

###Test for stationarity using Augmented Dickey-Fuller Test
#Create a time series object of Store 1, Dept 1
s1d1 <- train %>%
  filter(Store == 1, Dept == 1) %>%
  select(5) #Weekly_Sales
s1d1.ts <- ts(s1d1,frequency=52)
#Run ADF Test
adf.test(s1d1.ts,alternative = "stationary")

#The null-hypothesis for an ADF test is that the data are non-stationary. 
#So large p-values are indicative of non-stationarity, and small p-values suggest stationarity. 
#Using the usual 5% threshold, differencing is required if the p-value is greater than 0.05.

####ETS
s1d1.fit <- ets(s1d1.ts) #frequency too high, suggested using stlf
s1d1.fit <- forecast(s1d1.ts)
s1d1.test <- train %>%
  filter(Store == 1, Dept == 1) %>%
  select(5)
accuracy(s1d1.fit,s1d1.test)

##Exponential Smoothing using state space approach
ets.f <- dlply(dfTrain, "id", function(x) stlf(ts(x[,2],frequency=52),method="ets",h=39)$mean)

##ets.f[[1]] would give 39 weeks of forecast for store 1_1 and so on

##Arima
s1d1.fit <- auto.arima(s1d1.ts)
arima.f <- dlply(train, "id", function(x) stlf(ts(x[,2],frequency=52),method="arima",h=39,stepwise=FALSE,approx=FALSE)$mean)

##Naive Method - whatever I did last year same week is what I'm going to do ##same week this year
naive.f <- dlply(train, "id", function(x) stlf(ts(x[,2],frequency=52),method="naive",h=39)$mean) 

###Time Series Clustering using Dynamic Time Warp
library(dtwclust)

#Random sampling of 60 time series
n <- 10
s <- sample(1:100, n)
idx <- c(s, 100+s, 200+s, 300+s, 400+s, 500+s)
sample_unique_pairs <- unique_pairs[idx,]
#i need to figure out if I want to loop through train and creat 3331 time series objects