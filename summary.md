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

I begin with 2 data sets:

* __train.csv__: Historical training data from 5/2/2010 to 26/10/2011, containing Store number, Department number, Date of the week, Weekly sales figure and isHoliday boolean

* __test.csv__: Test data for 2/11/2012 to 26/7/2013, containing columns for Store, Department, Date and IsHoliday


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

A quick look through __train__ reveals that there are a total of 45 unique store numbers from 1 to 45. And, a total of 81 unique dept numbers from 1 to 99. This creates 3331 unique store-dept pairs. I.e. 3331 time-series, each with a frequency of 143 (roughly 2+ years of weekly sales date).


```r
unique(train[,c("Store","Dept")])
```

```
## Source: local data frame [3,331 x 2]
## 
##     Store   Dept
##    (fctr) (fctr)
## 1       1      1
## 2       1      2
## 3       1      3
## 4       1      4
## 5       1      5
## 6       1      6
## 7       1      7
## 8       1      8
## 9       1      9
## 10      1     10
## ..    ...    ...
```

To prepare the training data for modelling, I reshaped the data frame to a 143 x 3331 matrix. Each column in the matrix represents a time-series for 1 store-dept pair.


```
## Source: local data frame [143 x 5]
## 
##          Date      1_1     1_10     1_11     1_12
##        (date)    (dbl)    (dbl)    (dbl)    (dbl)
## 1  2010-02-05 24924.50 30721.50 24213.18  8449.54
## 2  2010-02-12 46039.49 31494.77 21760.75  8654.07
## 3  2010-02-19 41595.55 29634.13 18706.21  9165.98
## 4  2010-02-26 19403.54 27921.96 17306.61  9015.37
## 5  2010-03-05 21827.90 33299.27 19082.90 10239.06
## 6  2010-03-12 21043.39 28208.00 17864.32 12386.15
## 7  2010-03-19 22136.64 33731.81 19738.42 12917.55
## 8  2010-03-26 26229.21 31406.96 17592.13 11865.53
## 9  2010-04-02 57258.43 31794.04 21762.46 12033.50
## 10 2010-04-09 42960.91 32486.28 22186.81 10109.00
## ..        ...      ...      ...      ...      ...
```

## 2. Modeling
