source('data_prep3.R')
source('forecast2.R')

train <- read.train()
test <- read.test()

pred1 <- apply.forecast(train,test,'seasonal.naive')

###Write a submission file for Kaggle
write.submission(pred1)

