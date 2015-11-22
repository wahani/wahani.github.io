---
layout: post
section-type: post
title: Notes On Google Trend Data
comments: false
category: notes
tags: [R]
---


Some notes on querying and reshaping data from Google trends. Most importantly
your language in you Google account must be in English. The package relies on
some keywords.


{% highlight r %}
devtools::install_github("PMassicotte/gtrendsR")
library(gtrendsR)

usr <- ""  # alternatively store as options() or env.var
psw <- ""              # idem

gconnect(usr, psw)       # stores handle in environment

res <- gtrends(c("Pizza", "Pasta", "Italy"), geo = "IT")
{% endhighlight %}

Need some reshaping for using data on cities.


{% highlight r %}
do.call(rbind, 
        lapply(res$cities, function(df) {
          df$query <- names(df)[[2]]
          names(df)[[2]] <- "count"
          df
        })
)
{% endhighlight %}

