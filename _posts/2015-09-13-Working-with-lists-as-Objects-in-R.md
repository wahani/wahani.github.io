---
layout: post
published: true
title: Working with Lists as Objects in R and aoos
description: "This post explains how to work with lists as objects in
  [R](https://cran.r-project.org/) using the R package
  [aoos](https://cran.r-project.org/package=aoos). aoos provides alternative
  syntax for functions from the built in system for object orientation in the
  package *methods*."
comments: true
math: false
categories: [R, oop, aoos]
archive: false
---

This post is part of a series related to object oriented programming
in [R](https://cran.r-project.org/) and the package
[aoos](https://cran.r-project.org/package=aoos). The [previous]({% post_url 2015-09-13-Introducing-Another-Object-Orientation-System-3 %}) introduces the
current version of aoos. The [next]({% post_url 2015-09-20-On-Performance-Issues-in-aoos %}) links to the
*Performance* vignette in the package.

This post explains how to work with lists as objects in
[R](https://cran.r-project.org/) using the R package
[aoos](https://cran.r-project.org/package=aoos). aoos provides alternative
syntax for functions from the built in system for object orientation in the
package *methods*.

The following is a vignette (as iframe) also contained in the package itself.
You can find it by copying the following into R:


{% highlight r %}
install.packages("aoos")
vignette("retListClasses", "aoos")
{% endhighlight %}

<iframe width='100%' height='3000' src="https://wahani.github.io/aoos/vignettes/retListClasses.html" frameborder="0" allowfullscreen></iframe>
