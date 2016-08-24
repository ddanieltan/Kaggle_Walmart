---
title: "Project Summary"
author: "Daniel Tan"
date: "24 August 2016"
output: html_document
---



## Background

In 2014, Walmart held a Kaggle competition to challenge Kagglers to build an accurate prediction of future sales based on historical data.


I have chosen a scoped down version of this competition as my Springboard Capstone Project. If you would like to see the full details of the original Kaggle competition, please visit [this link](https://www.kaggle.com/c/walmart-recruiting-store-sales-forecasting).

## 1. Data Preparation

I begin with 2 datasets:

* __train.csv__: Historical training data from 5/2/2010 to 26/10/2011, containing Store number, Department number, Date of the week, Weekly sales figure and isHoliday boolean

* __test.csv__: Test data for 2/11/2012 to 26/7/2013, containing collumns for Store, Department, Date and IsHoliday


```r
# Snippet of train data
train
```

```
## Source: local data frame [421,570 x 5]
## 
##     Store   Dept       Date Weekly_Sales IsHoliday
##    (fctr) (fctr)     (date)        (dbl)     (lgl)
## 1       1      1 2010-02-05     24924.50     FALSE
## 2       1      1 2010-02-12     46039.49      TRUE
## 3       1      1 2010-02-19     41595.55     FALSE
## 4       1      1 2010-02-26     19403.54     FALSE
## 5       1      1 2010-03-05     21827.90     FALSE
## 6       1      1 2010-03-12     21043.39     FALSE
## 7       1      1 2010-03-19     22136.64     FALSE
## 8       1      1 2010-03-26     26229.21     FALSE
## 9       1      1 2010-04-02     57258.43     FALSE
## 10      1      1 2010-04-09     42960.91     FALSE
## ..    ...    ...        ...          ...       ...
```

```r
# Snippet of test data
test
```

```
## Source: local data frame [115,064 x 4]
## 
##     Store   Dept       Date IsHoliday
##    (fctr) (fctr)     (date)     (lgl)
## 1       1      1 2012-11-02     FALSE
## 2       1      1 2012-11-09     FALSE
## 3       1      1 2012-11-16     FALSE
## 4       1      1 2012-11-23      TRUE
## 5       1      1 2012-11-30     FALSE
## 6       1      1 2012-12-07     FALSE
## 7       1      1 2012-12-14     FALSE
## 8       1      1 2012-12-21     FALSE
## 9       1      1 2012-12-28      TRUE
## 10      1      1 2013-01-04     FALSE
## ..    ...    ...        ...       ...
```

Note that the `echo = FALSE` parameter was added to the code chunk to prevent printing of the R code that generated the plot.
