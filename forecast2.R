library(dplyr)
library(forecast)

test.dates <- unique(test$Date)
num.test.dates <- length(test.dates)
all.stores <- unique(test$Store)
num.stores <- length(all.stores)
test.depts <- unique(test$Dept)
#reverse the depts so the grungiest data comes first
test.depts <- test.depts[length(test.depts):1]
forecast.frame <- data.frame(Date=rep(test.dates, num.stores),
                             Store=rep(all.stores, each=num.test.dates))