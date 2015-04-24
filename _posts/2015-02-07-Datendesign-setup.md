---
layout: post
title: "DatendesignR config"
author: "Sebastian"
tags: datendesign
bibliography:
output: wahaniMiscs:::pdf_memo
archive: true
---

# Setup the *Datendesign* stuff

## Data for graphics

{% highlight r %}
dir.create("_rmd/data")
writeLines("*", "_rmd/data/.gitignore")
download.file("http://www.datendesign-r.de/alle_daten.zip",
              "_rmd/data/alle_daten.zip")
unzip("_rmd/data/alle_daten.zip", exdir = "_rmd/data")
{% endhighlight %}

## Code for all examples


{% highlight r %}
download.file("http://www.datendesign-r.de/beispielcode.zip",
              "_rmd/data/beispielcode.zip")
unzip("_rmd/data/beispielcode.zip", exdir = "_rmd/data")
{% endhighlight %}
