---
layout: post
comments: true
title: "subsetting data.frames"
description: ""
tags: [R]
archive: true
---

Why do I write this post?
-------------------------
Here I will discuss some interesting behavior of standard subsetting in [R](http://cran.r-project.org/). Actually it is nothing special or completely unexpected, still I didn't see the mechanism right away.

Subsetting `data.frame`s
------------------------

### Basic subsetting
This is the data


{% highlight r %}
dat <- data.frame(x = 1:5, y = rnorm(5))
{% endhighlight %}


{% highlight r %}
class(dat$x)
{% endhighlight %}



{% highlight text %}
## [1] "integer"
{% endhighlight %}



{% highlight r %}
class(dat[["x"]])
{% endhighlight %}



{% highlight text %}
## [1] "integer"
{% endhighlight %}



{% highlight r %}
class(dat[, "x"])
{% endhighlight %}



{% highlight text %}
## [1] "integer"
{% endhighlight %}



{% highlight r %}
class(dat["x"])
{% endhighlight %}



{% highlight text %}
## [1] "data.frame"
{% endhighlight %}

### Interesting behavior


{% highlight r %}
dat[] <- lapply(dat, function(x) is.na(x))
{% endhighlight %}
