source('data_prep3.R')
source('forecast2.R')

train <- read.train()
test <- read.test()

mts <- master.ts(train,test)
head(mts)

a <- 0
for (i in 1:nrow(mts)){a<-a+1}
a

pred1 <- apply.forecast(train,test,'seasonal.naive')
pred2 <- apply.forecast(train,test,'tslm')
pred3 <- apply.forecast(train,test,'arima.f',12)
pred4 <- apply.forecast(train,test,'tsclust.f')

###Write a submission file for Kaggle
write.submission(pred1)
write.submission(pred2)
write.submission(pred3)

