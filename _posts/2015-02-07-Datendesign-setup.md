---
layout: post
title: "DatendesignR config"
author: "Sebastian"
categories: notes
archive: true
---

# Setup the *Datendesign* stuff

## Data for graphics

{% highlight r %}
dir.create("data")
writeLines("*", "data/.gitignore")
download.file("http://www.datendesign-r.de/alle_daten.zip",
              "data/alle_daten.zip")
unzip("data/alle_daten.zip", exdir = "data")
{% endhighlight %}

## Code for all examples


{% highlight r %}
download.file("http://www.datendesign-r.de/beispielcode.zip",
              "data/beispielcode.zip")
unzip("data/beispielcode.zip", exdir = "data")
{% endhighlight %}
