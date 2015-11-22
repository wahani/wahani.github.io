---
layout: post
section-type: post
title: Notes On Google Trend Data
comments: false
category: notes
tags: [R]
---


{% highlight r %}
devtools::install_github("PMassicotte/gtrendsR")
library(gtrendsR)

usr <- ""  # alternatively store as options() or env.var
psw <- ""              # idem

gconnect(usr, psw)       # stores handle in environment

res <- gtrends(c("Pizza", "Pasta", "Italy"), geo = "IT")

do.call(rbind, 
        lapply(res$cities, function(df) {
          df$query <- names(df)[[2]]
          names(df)[[2]] <- "count"
          df
        })
)

plot(res)
{% endhighlight %}

