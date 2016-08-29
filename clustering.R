library(TSclust)

calculate.ts.dist <- function(store.matrix){
  #Calculates the dissimilarity matrix via the Autocorrelation method (ACF)
  #Input: A matrix of Weekly_Sales values from the training set of dimension
  #         (number of weeeks in training data) x (number of stores)
  #Output:A matrix of dissimilarity computations of length 990
  
  tsdist <-t(select(store.matrix,-1)) #remove date column
  tsdist<-scale(tsdist) #standardising data points
  tsdist <- diss(tsdist, "ACF", p=0.05)
  return(tsdist)
}