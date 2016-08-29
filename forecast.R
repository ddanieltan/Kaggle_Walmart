library(dplyr)
library(forecast)
library(reshape)
library(TSclust)

apply.forecast <- function(train,test,fname, ...){
  ### This function loops a selected function across all departments
  #Input: Train data table, Test data table, function
  #Output: Prediction data table
  
  #Creating a forecast frame
  test.dates <- unique(test$Date)
  num.test.dates <- length(test.dates)
  all.stores <- unique(test$Store)
  num.stores <- length(all.stores)
  test.depts <- unique(test$Dept)
  forecast.frame <- data.frame(Date=rep(test.dates, num.stores),
                               Store=rep(all.stores, each=num.test.dates))
  
  #Creating a train frame
  pred <- test
  pred$Weekly_Sales <- 0
  train.dates <- unique(train$Date)
  num.train.dates <- length(train.dates)
  train.frame <- data.frame(Date=rep(train.dates, num.stores),
                            Store=rep(all.stores, each=num.train.dates))
  
  #Apply function to each department in a loop
  f <- get(fname)
  for(d in test.depts){
    print(paste('dept:', d))
    tr.d <- train.frame
    # This joins in Weekly_Sales but generates NA's. Resolve NA's 
    # in the model because they are resolved differently in different models.
    tr.d <- left_join(tr.d, train[train$Dept==d, c('Store','Date','Weekly_Sales')])
    tr.d <- cast(tr.d, Date ~ Store)    
    fc.d <- forecast.frame
    fc.d$Weekly_Sales <- 0
    fc.d <- cast(fc.d, Date ~ Store)
    result <- f(tr.d, fc.d, ...)
    # This has all Stores/Dates for this dept, but may have some that
    # don't go into the submission.
    result <- melt(result)
    pred.d.idx <- pred$Dept==d
    #These are the Store-Date pairs in the submission for this dept
    pred.d <- pred[pred.d.idx, c('Store', 'Date')]
    pred.d <- left_join(pred.d, result)
    pred$Weekly_Sales[pred.d.idx] <- pred.d$value
  }
  pred
}

seasonal.naive <- function(train, test){
  # Computes seasonal naive forecasts
  #
  # Input:
  # train - A matrix of Weekly_Sales values from the training set of dimension
  #         (number of weeeks in training data) x (number of stores)
  # test - An all-zeros matrix of dimension:
  #       (number of weeeks in training data) x (number of stores)
  #       The forecasts are written in place of the zeros.
  #
  # Output:
  #  the test(forecast) data frame with the forecasts filled in 
  h <- nrow(test)
  tr <- train[nrow(train) - (52:1) + 1,]
  tr[is.na(tr)] <- 0
  test[,2:ncol(test)]  <- tr[1:h,2:ncol(test)]
  test
}

tslm <- function(train, test){
  # Computes a forecast using linear regression and seasonal dummy variables
  #
  # Input:
  # train - A matrix of Weekly_Sales values from the training set of dimension
  #         (number of weeeks in training data) x (number of stores)
  # test - An all-zeros matrix of dimension:
  #       (number of weeeks in training data) x (number of stores)
  #       The forecasts are written in place of the zeros.
  #
  # Output:
  #  the test(forecast) data frame with the forecasts filled in 
  horizon <- nrow(test)
  train[is.na(train)] <- 0
  for(j in 2:ncol(train)){
    s <- ts(train[, j], frequency=52)
    model <- tslm(s ~ trend + season)
    fc <- forecast(model, h=horizon)
    test[, j] <- as.numeric(fc$mean)
  }
  test
}

library(TSclust)
tsclust.f <- function (mts){
  #Clusters time series from training data into n number of clusters.
  #This function is called in preparation for ARIMA.
  #The idea is that trend and seasonality is common across many departments as they are selling similar items.
  # Input: 
  # ts - A matrix of Weekly_Sales values from the training set of dimension
  #         (number of weeks in training data) x (number of stores)
  # n.clusters - the number of clusters
  # Output:
  # train matrix of n clusters
  
  tsdist <- diss(mts, "ACF", p=0.05)
  #perform hierachical clustering to the dist object
  hc <- hclust(tsdist)
  #show the results
  plot(hc)
  
}

arima.f <- function(train, test, n.comp){
  # Replaces the training data with a rank-reduced approximation of itself
  # and then produces seasonal arima forecasts for each store.
  #
  # args:
  # train - A matrix of Weekly_Sales values from the training set of dimension
  #         (number of weeeks in training data) x (number of stores)
  # test - An all-zeros matrix of dimension:
  #       (number of weeeks in training data) x (number of stores)
  #       The forecasts are written in place of the zeros.
  # n.comp - the number of components to keep in the singular value
  #         decomposition that is performed for preprocessing
  #
  # returns:
  #  the test(forecast) data frame with the forecasts filled in 
  horizon <- nrow(test)
  tr <- preprocess.svd(train, n.comp)
  for(j in 2:ncol(tr)){
    if(sum(is.na(train[, j])) > nrow(train)/3){
      # Use DE model as fallback
      test[, j] <- fallback(tr[,j], horizon)
      store.num <- names(train)[j]
      print(paste('Fallback on store:', store.num))
    }else{
      # fit arima model
      s <- ts(tr[, j], frequency=52)
      model <- auto.arima(s, ic='bic', seasonal.test='ch')
      fc <- forecast(model, h=horizon)
      test[, j] <- as.numeric(fc$mean)
    }
  }
  test
}

fallback <- function(train, horizon){
  # This method is a fallback forecasting method in the case that there are
  # enough NA's to possibly crash arima models. It takes one seasonal 
  # difference, forecasts with a level-only exponential model, and then
  # inverts the seasonal difference.
  # 
  # args:
  # train - a vector of training data for one store
  # horizon - the forecast horizon in weeks
  #
  # returns:
  #  a vector of forecast values
  s <- ts(train, frequency=52)
  s[is.na(s)] <- 0
  fc <- ses(diff(s, 52), h=horizon)
  result <- diffinv(fc$mean, lag=52, xi=s[length(s) - 51:0])
  result[length(result) - horizon:1 + 1]
}


