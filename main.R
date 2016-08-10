source('data_prep3.R')
source('forecast2.R')

train <- read.train()
test <- read.test()

pred1 <- apply.forecast(train,test,'seasonal.naive')
pred2 <- apply.forecast(train,test,'tslm')

###Write a submission file for Kaggle
write.submission(pred1)
write.submission(pred2)

