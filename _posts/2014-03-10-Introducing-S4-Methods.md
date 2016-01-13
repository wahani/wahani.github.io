---
layout: post
comments: false
title: Introducing S4-Methods
description: "A short introduction to generic functions using the S4 class system in R."
tags: [R, oop, S4, S3]
archive: false
---



I am often in the position to write functions for different types (classes) of 
objects (arguments). Somehow it never occurred to me, that it would be a good 
idea to write methods instead of several functions. Besides all other great
advantages of generic functions and methods, one main reason for me is simply
the number of function names I have to come up with. And the more functions I
use in my package the crazier the names. Not good.

# Generic Functions

A generic function is a function which will do the method dispatch for us.
Meaning that a generic function will decide which method to call depending on
the class of its arguments. `summary` is a good example for a generic function,
it will behave differently when calling it on an object of the class
`data.frame` or `lm` or `glm`.


{% highlight r %}
dat <- data.frame(x = rnorm(10), y = rnorm(10))
summary(dat)
{% endhighlight %}



{% highlight text %}
##        x                 y          
##  Min.   :-1.7458   Min.   :-1.6306  
##  1st Qu.:-0.8405   1st Qu.:-0.4204  
##  Median :-0.4316   Median :-0.2509  
##  Mean   :-0.2688   Mean   : 0.3870  
##  3rd Qu.: 0.5028   3rd Qu.: 0.8392  
##  Max.   : 1.2282   Max.   : 4.3288
{% endhighlight %}



{% highlight r %}
summary(lm(y ~ x, dat))
{% endhighlight %}



{% highlight text %}
## 
## Call:
## lm(formula = y ~ x, data = dat)
## 
## Residuals:
##     Min      1Q  Median      3Q     Max 
## -1.9708 -0.9175 -0.3570  0.7501  3.6568 
## 
## Coefficients:
##             Estimate Std. Error t value Pr(>|t|)
## (Intercept)   0.4899     0.5572   0.879    0.405
## x             0.3828     0.5736   0.667    0.523
## 
## Residual standard error: 1.693 on 8 degrees of freedom
## Multiple R-squared:  0.05272,	Adjusted R-squared:  -0.06569 
## F-statistic: 0.4452 on 1 and 8 DF,  p-value: 0.5234
{% endhighlight %}

## Methods

A method is a function which is written for specific classes of its arguments;
although you probably expect specific classes of your arguments for every
function you write. Methods are typically not called directly but by a call to a
generic function. So for the generic function `summary`, there are several
methods, for example `summary.data.frame` and `summary.lm` which are called
depending on the class of the first argument of the call to `summary`. The
advantage over writing functions named `summaryDF` and `summarylm` is that you
don't need to remember so many (badly chosen) function names.

### Define S3 Methods

Typically I try not to write new generic functions because I have to remember
their names, but write new methods for existing generics. A typical example in
my own work are functions like `plot`, `rbind` and also `summary`. The simplest
way is to use S3-generics. Their are little formal requirements one has to think
of.


{% highlight r %}
mean("Hello!")
{% endhighlight %}



{% highlight text %}
## Warning in mean.default("Hello!"): argument is not numeric or logical:
## returning NA
{% endhighlight %}



{% highlight text %}
## [1] NA
{% endhighlight %}



{% highlight r %}
mean.character <- function(x) x
mean("Hello!")
{% endhighlight %}



{% highlight text %}
## [1] "Hello!"
{% endhighlight %}

OK, so this is a stupid example for a S3-Method. The only thing you have to do
is to write a new function with a certain naming convention. Begin with the name
of the generic function, then a dot and then the class for which this method is
written for.

### Define S4 Methods

S3 method dispatch uses "only" the class of the first argument. Sometimes it 
might be useful to supply methods not only for the first argument, but for 
different arguments. I find this especially appealing for plotting methods,
where one needs different plots for different combinations of x and y variables
(scatter-plot, boxplot, or histogram). Here is a small example:


{% highlight r %}
data(InsectSprays)

setMethod("plot", signature(x="factor", y="numeric"),
  function(x,  y, ...) boxplot(y ~ x, ...)
)
{% endhighlight %}



{% highlight text %}
## Creating a generic function for 'plot' from package 'graphics' in the global environment
{% endhighlight %}



{% highlight r %}
plot(InsectSprays$spray, InsectSprays$count)
{% endhighlight %}

<img src="/assets/images/2014-03-10-Introducing-S4-Methods/unnamed-chunk-4-1.png" title="center" alt="center" width="100%" />
