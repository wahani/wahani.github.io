---
layout: post
published: true
title: On Performance Issues in aoos
comments: true
math: false
categories: [R, oop, aoos]
archive: false
---

This post is part of a series related to object oriented programming
in [R](https://cran.r-project.org/) and the package
[aoos](https://cran.r-project.org/package=aoos). The [previous]({% post_url 2015-09-13-Working-with-lists-as-Objects-in-R %}) introduced how to work with the function  `retList`.

One of the first things you will read about the R package [R6](https://cran.r-project.org/package=R6) is that it fixes some performance issues compared to S4, i.e. the methods package. Although the benchmarks are in microseconds it is reported that it was still a noticeable difference in production systems (shiny). Reason enough to include aoos in the benchmark to get an idea of the implementation. There is a very detailed [vignette in the R6 package](https://cran.r-project.org/web/packages/R6/vignettes/Performance.html) from which I borrow the setup to make it comparable, although I restricted the performance vignette in aoos on the essentials.

The following is a vignette (in an iframe) also contained in the package itself.
You can find it by copying the following into R:


{% highlight r %}
install.packages("aoos")
vignette("performance", "aoos")
{% endhighlight %}

Main findings: As the description in aoos already suggests, don't use `defineClass`, it is not only experimental but also the slowest alternative. `retList` is faster than R6 because it is doing even less.

<iframe width='100%' height='2000' src="https://wahani.github.io/aoos/vignettes/performance.html" frameborder="0" allowfullscreen></iframe>
