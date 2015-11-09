---
layout: post
title: Why is plyr so much faster?
description: "Speed comparisons with plyr and the split-apply-combine idiom."
comments: true
tags: [R, plyr, performance]
archive: true
---

Speed comparisons with plyr and the split apply combine idiom.


{% highlight r %}
library(microbenchmark)
library(profr)
# library(lineprof)
library(plyr)

# Example from:
# http://www.r-statistics.com/2013/09/a-speed-test-comparison-of-plyr-data-table-and-dplyr/
rm(list=ls())
gc()
{% endhighlight %}



{% highlight text %}
##          used (Mb) gc trigger (Mb) max used (Mb)
## Ncells 406753 21.8     750400 40.1   549375 29.4
## Vcells 583182  4.5    1308461 10.0   783860  6.0
{% endhighlight %}



{% highlight r %}
set.seed(42)

types <- c("A", "B", "C", "D", "E", "F")
obs <- 4e+07
dat <- data.frame(id = as.factor(seq(from = 1, to = 80000, by = 1)),
                  percent = round(runif(obs, min = 0, max = 1), digits = 2),
                  type = as.factor(sample(types, obs, replace = TRUE)))



## Test 1 (plyr): Use ddply and subset one with [ ] style indexing from
## within the ddply call.

typeSubset <- c("A", "C", "E")

system.time(test1 <- ddply(dat[dat$type %in% typeSubset, ], .(id), summarise,
                           percent_total = sum(percent)))
{% endhighlight %}



{% highlight text %}
##    user  system elapsed 
##  29.508   0.256  29.758
{% endhighlight %}



{% highlight r %}
# Test 2 (Naive split-apply-combine)
system.time({
  datSmall <- dat[dat$type %in% typeSubset, ]
  tmp <- lapply(split(datSmall, datSmall$id), summarise,
                percent_total = sum(percent))
  test2 <- do.call(rbind, tmp)
})
{% endhighlight %}



{% highlight text %}
##    user  system elapsed 
##  26.120   0.608  26.730
{% endhighlight %}



{% highlight r %}
system.time({
  datSmall <- dat[dat$type %in% typeSubset, ]
  lData <- plyr:::splitter_d(datSmall, .(id))
  tmp <- lapply(1:length(lData), function(i, ...) summarise(lData[[i]], ...) ,
         percent_total = sum(percent))
  test3 <- dplyr::rbind_all(tmp)
})
{% endhighlight %}



{% highlight text %}
##    user  system elapsed 
##  26.956   0.136  27.094
{% endhighlight %}
