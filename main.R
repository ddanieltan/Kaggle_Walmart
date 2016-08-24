source('data_prep3.R')
source('forecast2.R')

train <- read.train()
test <- read.test()

mts <- master.ts(train)
mts

pred1 <- apply.forecast(train,test,'seasonal.naive')
pred2 <- apply.forecast(train,test,'tslm')
pred3 <- apply.forecast(train,test,'arima.f',12)

###Write a submission file for Kaggle
write.submission(pred1)
write.submission(pred2)
write.submission(pred3)

###Write summary.rmd as summary.md to commit to Github
library(knitr)
knit(input="summary.rmd", output = "summary.md") 