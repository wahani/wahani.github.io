---
layout: post
title: Design Patterns in R
description: "A collection of design patterns for R as a functional programming language"
comments: true
math: true
categories: [R, fp]
archive: false
---

These notes are inspired by 

- [a talk by Stuart Sierra](http://www.infoq.com/presentations/Clojure-Design-Patterns) on *Design Patterns in Functional Programming* and 
- some thoughts I found on [F# for fun an profit](http://fsharpforfunandprofit.com/)

and are reflection on how I use different strategies to solve things in *R*.
*Design Pattern* seems to be a big word, especially because of its use in
object-oriented programming. But in the end I think it is simply the correct
label for reoccurring strategies to design software.

# The Fixed Point Algorithm

I keep my notes using *R* and as an ongoing example I use a fixed point
algorithm to compute the square root of a positive real number. The algorithm is
defined as:

$$ x_{n + 1} = f(x_{n}) $$

and the fixed point function to find the square root is given by:

$$ f(x | p) = \frac{p}{x} $$

where \\(p\\) is a given (positive) number for which we want to find the square
root. To represent this in *R* I define the algorithm as:


{% highlight r %}
fp <- function(f, x, converged, ...) {
  value <- f(x, ...)
  if (converged(x, value)) value
  else Recall(f, value, converged, ...) 
}
{% endhighlight %}

\\(x\\) is the value of the last iteration or the starting value. `converged` is a
function with two arguments and `...` can be used for currying in *R*. Let the
fixed point function be defined as:


{% highlight r %}
fpsqrt <- function(x, p) p / x
{% endhighlight %}

and 


{% highlight r %}
converged <- function(x, y) all(abs(x - y) < 0.001)
{% endhighlight %}

So let's compute that value:


{% highlight r %}
fp(fpsqrt, 2, converged, p = 2)
{% endhighlight %}



{% highlight text %}
## Error: evaluation nested too deeply: infinite recursion / options(expressions=)?
{% endhighlight %}

And as so often nothing really works the first time. In the current 
implementation it is also kind of hard to find out what is going wrong but we 
will get there. In the following I will apply different patterns to modify the
above framework to get to a solution.


# Wrapper Pattern

This pattern is one I saw in [the talk by Stuart
Sierra](http://www.infoq.com/presentations/Clojure-Design-Patterns). The
*Wrapper Pattern* is something I use to add some functionality to a function,
without actually changing it. One of the things I do is adding a logger to a
function or taking care that a function preserves attributes, which is not the
case for many functions in *R*. Something else would be to try to call a
function and retry every two minutes because of a failing connection to a 
database or a file system that is not responding.

A function has a single, well defined purpose; logging and writing to a database
are two things. Computing the next iteration and keeping track of the number of 
iterations are also two things. That one feature, with an additional argument
for logging yes/no, will not be alone for long.

The problem in my example is that the fixed point function oscillates between
two values instead of converging against the square root. A trick to overcome
this is to use *average damping*. This means that instead of directly taking the
value \\(x\_\{n\}\\) for computing \\(x\_{n + 1}\\) we use \\(\frac{x_{n - 1} + 
x_n}{2}\\). And this is actually not part of the logic of the fixed point 
function so it should not be polluted with it:


{% highlight r %}
averageDamp <- function(fun) {
  function(x, ...) (x + fun(x, ...)) / 2
}

fp(averageDamp(fpsqrt), 2, converged, p = 2)
{% endhighlight %}



{% highlight text %}
## [1] 1.414214
{% endhighlight %}



{% highlight r %}
# and to compare:
sqrt(2)
{% endhighlight %}



{% highlight text %}
## [1] 1.414214
{% endhighlight %}

Okay, great, now it seems to work. An additional wrapper I want to have is for
printing the value in each iteration to the console:


{% highlight r %}
printValue <- function(fun) {
  function(x, ...) {
    cat(x, "\n")
    fun(x, ...)
  }
}

fp(printValue(averageDamp(fpsqrt)), 2, converged, p = 2)
{% endhighlight %}



{% highlight text %}
## 2 
## 1.5 
## 1.416667 
## 1.414216
{% endhighlight %}



{% highlight text %}
## [1] 1.414214
{% endhighlight %}

The problem now becomes that if we add to many wrappers it gets complicated.
Actually try to figure out which wrapper is called first, maybe that is not
obvious to you yet.

The wrapper pattern can be applied to add features *before* or *after* (or both)
the actual function. `printValue` adds the printing *before* and `averageDamp`
the correction *after* the original function. If we look at a different
formulation of `averageDamp` the pattern becomes more obvious:


{% highlight r %}
averageDamp <- function(fun) {
  function(x, ...) {
    value <- fun(x, ...)
    (x + value) / 2
  }
}
{% endhighlight %}


# Interface Patterns

## Currying

The value of this technique - from my perspective - is that you can build
interfaces more easily (with sufficient support of the language). For example
the fixed point function for the square root needs two arguments. The algorithm,
however, actually knows only about one argument. Currying in this case simply 
means to make the two-argument function `fpsqrt` into a one-argument function.
We can do this by setting \\(p = 2\\) which is what I accomplished using the
`...` so far.

In *R* you have two native options to model currying. The one you see most of 
the time is to use the dots argument to allow to pass additional arguments to 
the function. However, this puts an additional burden to every implementation in
my framework because I need to take care that I allow for dots in every wrapper
function I define. The other option is to use an anonymous function to wrap the
original version in an one-argument function which would look like this:


{% highlight r %}
fp(averageDamp(function(x) fpsqrt(x, p = 2)), 2, converged)
{% endhighlight %}



{% highlight text %}
## [1] 1.414214
{% endhighlight %}

If I rely on this interface (one-argument function) I can get rid of all the 
dots. However the syntactical support of this technique is limited in *R* which 
is why packages like [purrr](https://cran.r-project.org/package=purrr) and 
[rlist](https://cran.r-project.org/package=rlist) try to improve the situation;
The packages [functional](https://cran.r-project.org/package=functional)
and [pryr](https://cran.r-project.org/package=pryr) provide dedicated functions
for currying.

## Closures

Every function in *R* is a closure (except for primitive functions). A closure
is a function which has an environment associated to it. E.g. a function in a
R-package has access to the packages namespace or a method in a class as in 
object orientation has access to the scope of the class. But typically the term 
is used when functions are returned from other functions (except *R*s error 
message whenever you try to *subset a closure*). If you don't know about them, 
but want to, you can read [this article]({% post_url 2014-09-23-Promises-and-Closures-in-R %}) or the chapter in [Advanced
R](http://adv-r.had.co.nz/Functional-programming.html#closures).

For my example I use a closure to redefine the fixed point function for the
square root for a *given* value of \\(p\\). Where I think that the 
*given-value-of-p* part is only emphasized by the following implementation:


{% highlight r %}
fpsqrt <- function(p) {
  function(x) p / x
}
{% endhighlight %}

And this actually makes the call of the algorithm a bit more concise:


{% highlight r %}
fp(averageDamp(fpsqrt(2)), 2, converged)
{% endhighlight %}



{% highlight text %}
## [1] 1.414214
{% endhighlight %}


# Cache Pattern

In various situations I want to cache some results instead of recomputing them. 
This I do for performance reasons because no matter which library you use, the 
time to compute an inverse is not linear in the sample size. Once you have 
10.000 observations and compute the inverse of a \\((10.000 \times 10.000)\\) 
variance-covariance matrix combined with a bootstrap in a Monte-Carlo simulation
study you have to wait. To illustrate this I want to compute a linear estimator.
And although the estimator can be identified analytically I use the fixed point 
algorithm. The fixed point function, in this case I use Newton-Raphson
algorithm, is defined as:

$$
\beta_{n + 1} = \beta_n - (f''(\beta_n))^{-1} f'(\beta_n) 
$$

with 

$$
f'(\beta) = X^\top (y - X\beta) \\
f''(\beta) = -X^\top X
$$

being the first and second order derivatives for \\(\beta\\) of the likelihood 
under a normal distribution. If this does not mean anything to you, take it for 
granted and focus on the pattern. Consider the following implementation in *R*
where I already applied the interface pattern using a closure:


{% highlight r %}
nr <- function(X, y) {
  function(beta) beta - solve(-crossprod(X)) %*% crossprod(X, y - X %*% beta)
}

# Some data to test the function:
set.seed(1)
X <- cbind(1, 1:10)
y <- X %*% c(1, 2) + rnorm(10)

# Average damping in this case will make the convergence a bit slower:
fp(printValue(averageDamp(nr(X, y))), c(1, 2), converged)
{% endhighlight %}



{% highlight text %}
## 1 2 
## 0.9155882 2.027366 
## 0.8733823 2.041049 
## 0.8522794 2.047891 
## 0.8417279 2.051311 
## 0.8364522 2.053022 
## 0.8338143 2.053877 
## 0.8324954 2.054304
{% endhighlight %}



{% highlight text %}
##           [,1]
## [1,] 0.8318359
## [2,] 2.0545183
{% endhighlight %}



{% highlight r %}
# And to have a comparison:
stats::lm.fit(X, y)$coefficients
{% endhighlight %}



{% highlight text %}
##        x1        x2 
## 0.8311764 2.0547321
{% endhighlight %}

The results look promising. We should choose a different tolerance level,
which at the moment is chosen very liberal, to get closer to *R*s
implementation; but that is not the focus here. What I want to do now is to make
the returned function of `nr` rely on pre-calculated values to avoid that they
are recomputed in every iteration. In this example I combine this with the 
definition of local functions:


{% highlight r %}
nr <- function(X, y) {
  
  # f1 relies on values in its scope:
  f1 <- function(beta) Xy - XX %*% beta
  
  Xy <- crossprod(X, y)
  XX <- crossprod(X)
  f2inv <- solve(-XX)
  
  function(beta) beta - f2inv %*% f1(beta)
  
}

fp(averageDamp(nr(X, y)), c(1, 2), converged)
{% endhighlight %}



{% highlight text %}
##           [,1]
## [1,] 0.8318359
## [2,] 2.0545183
{% endhighlight %}

Some remarks:

- local function definitions like `f1` in the above example, where I am sure to
control the environment, are the only places where I rely on free variables.
I.e. `f1` relies on `Xy` and `XX` which are values defined in the enclosing
environment; which I avoid at all cost in a top-level function.
- I like this representation because I keep the logic of the fixed point
function local to `nr`; that function knows everything there is to know about
how to compute the next iteration, given the data. A different approach is to
define `nr` such that it expects `XX`, `Xy` and `f2inv` as arguments, which
means some other part of my code has to know about the implementation in `nr`
and I have to look at different places to understand how the next iteration is
computed.


# Counter Pattern

So far the fixed point framework does not allow to restrict the number of
iterations. This is of course something you always want to control. This time I
use closures to model mutable state. Consider the two implementations of a
counter:


{% highlight r %}
# Option 1:
counterConst <- function() {
  # like a constructor function
  count <- 0
  function() {
    count <<- count + 1
    count
  }
}
counter <- counterConst()
counter()
{% endhighlight %}



{% highlight text %}
## [1] 1
{% endhighlight %}



{% highlight r %}
counter()
{% endhighlight %}



{% highlight text %}
## [1] 2
{% endhighlight %}



{% highlight r %}
# Option 2:
counter <- local({
  count <- 0
  function() {
    count <<- count + 1
    count
  }
})
counter()
{% endhighlight %}



{% highlight text %}
## [1] 1
{% endhighlight %}



{% highlight r %}
counter()
{% endhighlight %}



{% highlight text %}
## [1] 2
{% endhighlight %}

I remember that closures are hard to understand because as in the above example 
they can be used to model mutable state when almost everything in *R* is 
immutable. I probably banged my head against the wall for a couple of hours over
one of Hadleys examples to get the idea. 

To implement a maximum number of iterations in the fixed point framework I
combine the *wrapper pattern* and the *counter pattern* to modify the
convergence criterion such that the algorithm will terminate after a given
number of iterations:


{% highlight r %}
addMaxIter <- function(converged, maxIter) {
    count <- 0
    function(...) {
        count <<- count + 1
        if (count >= maxIter) TRUE else converged(...)
    }
}
{% endhighlight %}

This allows us to explore the error which occurred in the initial example:


{% highlight r %}
fp(printValue(fpsqrt(2)), 2, addMaxIter(converged, 4))
{% endhighlight %}



{% highlight text %}
## 2 
## 1 
## 2 
## 1
{% endhighlight %}



{% highlight text %}
## [1] 2
{% endhighlight %}

Now we can see that the initial version of the algorithm oscillates between 1
and 2. You may argue that in this case you can also see the number of iterations
as logic of the algorithm (as a responsibility of `fp`). In that case I would
argue that the code does not reflect the previously introduced formula of the
algorithm any more. But let's compare a different implementation:


{% highlight r %}
fpImp <- function(f, x, convCrit, maxIter = 100) {
  
  converged <- function() {
    convCrit(x, value) | count >= maxIter
  }
  
  count <- 0
  value <- NULL
  
  repeat {
    
    count <- count + 1 
    value <- f(x)
    
    if (converged()) break
    else {
      x <- value
      next
    }
    
  }
  
  list(result = value, iter = count)
  
}

fpImp(averageDamp(fpsqrt(2)), 2, converged)
{% endhighlight %}



{% highlight text %}
## $result
## [1] 1.414214
## 
## $iter
## [1] 4
{% endhighlight %}

And now let's add the number of iterations to the return value of `fp`:


{% highlight r %}
addIter <- function(fun) {
  count <- 0
  function(x) {
    count <<- count + 1
    value <- fun(x)
    attr(value, "count") <- count
    value
  }
}

fp(addIter(averageDamp(fpsqrt(2))), 2, converged)
{% endhighlight %}



{% highlight text %}
## [1] 1.414214
## attr(,"count")
## [1] 4
{% endhighlight %}

Maybe this implementation deserves an own name, but you can
still see the *wrapper* and *counter* pattern and it is similar to the
`averageDamp` function. Compared to `fpImp` the logic around a *maximum number
of iterations* has been separated from the concrete implementation of the
algorithm. Especially if I think about adding more features, the imperative
implementation has to cope with more and more things. Instead I can plug-in new 
features around my fixed point framework. So I'd argue it is [*open for 
extensions and closed for
modifications*](https://en.wikipedia.org/wiki/Open/closed_principle) which is
not only a good thing if you like object-orientation.

The counter pattern is of course more general. It simply reflects one strategy
to model mutable state. There are just very few situations in which I really
need to do that and counting is a reoccurring theme.
