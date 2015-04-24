---
layout: post
published: true
comments: true
title: Functional programming with lambda.r
description: "Exploring the R-package lambda.r and a functional programming style for data manipulation."
tags: [R, fp, lambda.r]
archive: true
---

My first post was on [S4-methods](/Introducing-S4-Methods/) and how I could add new features to a function without changing it -- using function dispatch in S4. This works out fine, but is not optimal for me.

- The function `setMethod` introduces code which is dificult to read
- The dispatch uses classes not attributes or different conditions for dispatch
- I am not trained to use object orientation as a programming style (I am not at all trained as a programmer) and after using it in a project I think if I want to get started with object orientation maybe I should not use a functional language to begin with
- I would never use S4 outside package delelopment
- And S4 is not playing nice with roxygen2, it took me hours to adjust my workflow

So I wanted to get back to the functional programming techniques available in R. Here [lambda.r](http://cran.r-project.org/web/packages/lambda.r/index.html) seems to be a nice addition to what R already offers. Especially the capability of dispatching functions. So here is an example.

## Example function


{% highlight r %}
library(magrittr)
dat <- data.frame(x = rnorm(10, seq(1, 5, length.out=10)), group = gl(2, 5))

applyFun <- function(dat, var, fun, by, ...) {
  split(dat, dat[by]) %>% lapply(function(df) {
    df[[var]] <- fun(df[[var]], ...)
    df
    }) %>% do.call(what=rbind)
  }

applyFun(dat, "x", mean, "group")
{% endhighlight %}



{% highlight text %}
##             x group
## 1.1  1.384096     1
## 1.2  1.384096     1
## 1.3  1.384096     1
## 1.4  1.384096     1
## 1.5  1.384096     1
## 2.6  3.990454     2
## 2.7  3.990454     2
## 2.8  3.990454     2
## 2.9  3.990454     2
## 2.10 3.990454     2
{% endhighlight %}

The function `applyFun` will apply `fun` on a subset denoted by `group` and the variable `var`. This may be usefull if you do transformations on single variables which are different in each group, or you do not want your data collapsed, i.e. preserve the original number of rows. `group` for example can be a chracter with `length > 1`, I can plug in any function wich will return a scalar or a vector with the length of the input. However, it will only work on a single variable in the data, so `var` schould have length 1. I could try something with `[` instead of `[[` for subsetting but then the requirements for `fun` will change and I do want to preserve the behaviour of `applyFun`.

## How can lambda.r help?

There are different possibilities to allow vectors in the argument `var` of `applyFun`:
* rewrite `applyFun`
* write a new function calling `applyFun`
* write a function called `applyFun` calling the version of `applyFun` where `var` is a scalar: use the function dispatch introduced in lambda.r
* And of course many more...

I don't like the first choice, I have a running collection of functions and they like each other so I like the function the way it is. The second would be okay, but I am not very creative in comming up with new function names; and remembering them is even harder. Let's see how the third option is working out:


{% highlight r %}
library(lambda.r)
{% endhighlight %}



{% highlight text %}
## Error in library(lambda.r): there is no package called 'lambda.r'
{% endhighlight %}



{% highlight r %}
rm(applyFun)

# Version of lambda.r if length(var) == 1
applyFun(dat, var, fun, by, ...) %when% {
  length(var) == 1
} %as% {
  split(dat, dat[by]) %>% lapply(function(df) {
    df[[var]] <- fun(df[[var]], ...)
    df
  }) %>% do.call(what=rbind)
}
{% endhighlight %}



{% highlight text %}
## Error in eval(expr, envir, enclos): konnte Funktion "%as%" nicht finden
{% endhighlight %}



{% highlight r %}
# Version of lambda.r if length(var) != 1
applyFun(dat, var, fun, by, ...) %as% {
  for (varName in var) {
    dat <- applyFun(dat, varName, fun, by, ...)
  }
  dat
}
{% endhighlight %}



{% highlight text %}
## Error in eval(expr, envir, enclos): konnte Funktion "%as%" nicht finden
{% endhighlight %}



{% highlight r %}
applyFun(dat, "x", mean, "group")
{% endhighlight %}



{% highlight text %}
## Error in eval(expr, envir, enclos): konnte Funktion "applyFun" nicht finden
{% endhighlight %}



{% highlight r %}
dat["y"] <- rnorm(10)
applyFun(dat, c("x", "y"), mean, "group")
{% endhighlight %}



{% highlight text %}
## Error in eval(expr, envir, enclos): konnte Funktion "applyFun" nicht finden
{% endhighlight %}

With `%when%` I introduce a condition, or multiple conditions, which needs to evaluate to `TRUE`. If it does the function body introduced by `%as%` is evaluated exactly like before. So I am generating a couple of more lines, but I can reuse the function body of the original `applyFun` definition. The second definition of `applyFun` is what will be called if `length(var) != 1`. So something like the else statement in a if-else clause. Like in a if-else control structure the order is important. So either I control access using a second `%when%` or the definition needs to be after the '`length(var) == 1`' version, which I did here.
