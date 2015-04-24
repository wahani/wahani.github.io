---
layout: post
title: "The Matrix package"
author: "Sebastian"
bibliography:
output: wahaniMiscs:::pdf_memo
tags: [R, Matrix]
---

# Some considerations on perfomance:

This is the example from


{% highlight r %}
vignette("Comparisons", package = "Matrix")
{% endhighlight %}

## Base R

{% highlight r %}
library("Matrix")
{% endhighlight %}



{% highlight text %}
## Loading required package: methods
## 
## Attaching package: 'Matrix'
## 
## The following objects are masked from 'package:base':
## 
##     crossprod, tcrossprod
{% endhighlight %}



{% highlight r %}
data(KNex, package = "Matrix")
y <- KNex$y
mm <- as(KNex$mm, "matrix")
system.time(naive.sol <- solve(t(mm) %*% mm) %*% t(mm) %*% y)
{% endhighlight %}



{% highlight text %}
##    user  system elapsed 
##   0.797   0.379   0.378
{% endhighlight %}



{% highlight r %}
system.time(cpod.sol <- solve(crossprod(mm), crossprod(mm,y)))
{% endhighlight %}



{% highlight text %}
##    user  system elapsed 
##   0.141   0.071   0.054
{% endhighlight %}



{% highlight r %}
system.time(t(mm) %*% mm)
{% endhighlight %}



{% highlight text %}
##    user  system elapsed 
##   0.240   0.059   0.076
{% endhighlight %}

## Using Matrix

This is equivalent to use `cpod.sol`:

{% highlight r %}
mm <- as(KNex$mm, "dgeMatrix")
system.time(Mat.sol <- solve(crossprod(mm), crossprod(mm, y)))
{% endhighlight %}



{% highlight text %}
##    user  system elapsed 
##   0.153   0.050   0.055
{% endhighlight %}

There is also a concept of memoization implemented as allustrated as:


{% highlight r %}
xpx <- crossprod(mm)
xpy <- crossprod(mm, y)
system.time(solve(xpx, xpy))
{% endhighlight %}



{% highlight text %}
##    user  system elapsed 
##   0.031   0.005   0.010
{% endhighlight %}



{% highlight r %}
system.time(solve(xpx, xpy))
{% endhighlight %}



{% highlight text %}
##    user  system elapsed 
##   0.003   0.002   0.001
{% endhighlight %}

I don't know where the results are stored exactly. The document says with the original object, so either as attribute to `xpx` or `xpy`.


{% highlight r %}
names(xpx@factors)
{% endhighlight %}



{% highlight text %}
## [1] "Cholesky"
{% endhighlight %}



{% highlight r %}
names(xpy@factors)
{% endhighlight %}



{% highlight text %}
## NULL
{% endhighlight %}

Okay, seems that only the first argument to `solve` is modified. But in nested calls this effect is not used:


{% highlight r %}
system.time(solve(crossprod(mm), crossprod(mm, y)))
{% endhighlight %}



{% highlight text %}
##    user  system elapsed 
##   0.147   0.106   0.073
{% endhighlight %}



{% highlight r %}
class(mm)
{% endhighlight %}



{% highlight text %}
## [1] "dgeMatrix"
## attr(,"package")
## [1] "Matrix"
{% endhighlight %}



{% highlight r %}
class(xpx)
{% endhighlight %}



{% highlight text %}
## [1] "dpoMatrix"
## attr(,"package")
## [1] "Matrix"
{% endhighlight %}

Maybe the reason for this is that `crossprod` will change the data, so storing results of the cholesky decomposition would not be meaningfull as it only makes sense for the cross product and not `mm`. Still this means that creating `xpy` is not necessary:


{% highlight r %}
xpx <- crossprod(mm)
system.time(solve(xpx, crossprod(mm, y)))
{% endhighlight %}



{% highlight text %}
##    user  system elapsed 
##   0.025   0.025   0.013
{% endhighlight %}



{% highlight r %}
system.time(solve(xpx, crossprod(mm, y)))
{% endhighlight %}



{% highlight text %}
##    user  system elapsed 
##   0.004   0.012   0.004
{% endhighlight %}

It's kind of the *manual* memoization of results you don't want to recompute.

## Taking advantage of sparse


{% highlight r %}
mm <- KNex$mm
class(mm)
{% endhighlight %}



{% highlight text %}
## [1] "dgCMatrix"
## attr(,"package")
## [1] "Matrix"
{% endhighlight %}

The matrix package privides a class for sparse matrices. The gain in speed is obvious, no tricky memoization needed as a lot of elements in `mm` are indeed zero.


{% highlight r %}
system.time(sparse.sol <- solve(crossprod(mm), crossprod(mm, y)))
{% endhighlight %}



{% highlight text %}
##    user  system elapsed 
##   0.003   0.000   0.004
{% endhighlight %}

The methods seem to be polimorphic, so the return value can have different classes. `Matrix` for example will try to determine the class on it's own:


{% highlight r %}
dat <- rnorm(1e6)
dat[1:300000] <- 0
m <- Matrix(dat, ncol = 1e3, nrow = 1e2)
class(m)
{% endhighlight %}



{% highlight text %}
## [1] "dgCMatrix"
## attr(,"package")
## [1] "Matrix"
{% endhighlight %}


{% highlight r %}
oldM <- matrix(rnorm(1e6), ncol = 1e3, nrow = 1e2)
oldMm <- crossprod(oldM)
class(Matrix(oldMm))
{% endhighlight %}



{% highlight text %}
## [1] "dsyMatrix"
## attr(,"package")
## [1] "Matrix"
{% endhighlight %}

So this is nice!
