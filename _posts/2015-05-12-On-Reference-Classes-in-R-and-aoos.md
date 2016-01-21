---
layout: post
title: "On Reference Classes in R and aoos"
categories: [R, oop, aoos]
archive: false
---

This post is part of a series related to object oriented programming
in [R](https://cran.r-project.org/) and the package
[aoos](https://cran.r-project.org/package=aoos). The [previous]({% post_url 2015-05-08-Introducing-Another-Object-Orientation-System-2 %}) introduced the
version 0.2.0 of aoos. The [next]({% post_url 2015-09-13-Introducing-Another-Object-Orientation-System-3 %}) links to the
*Introduction* vignette in the package.

To educate myself I am attending a coursera course named *Functional Programming
Principles in Scala*. For the past 2 years I regularly return to the course to
learn something new. However, I never really tried to solve things in Scala but
tried to translate everything into [R](http://cran.r-project.org/). When I
translated one of the examples into R I was a bit shocked why we have to use so
many parenthesis, commas and stuff which makes code hard to read and understand.
I envied Scala for the clear representation but I think you will see that
equivalent clarity in R can be achieved. In the following I will present several
solutions in R to represent the initial example in different ways. Most of the
ideas are implemented in the package
[aoos](https://cran.r-project.org/package=aoos) but the final example will only
be using *base* R.

## Reference Classes

First stop are reference classes implemented in the methods package in R. As far
as I know it was meant to be a Java-like implementation of object orientation in
R. To give some context, the goal is to represent rational numbers and some
basic operations on them, like addition and subtraction.


{% highlight r %}
library("methods")
Rational <- setRefClass(
  Class = "Rational",
  fields = list(numer = "numeric", denom = "numeric"),
  methods = list(
    gcd = function(a, b) if(b == 0) a else Recall(b, a %% b),
    initialize = function(numer, denom) {
      g <- gcd(numer, denom)
      .self$numer <- numer / g
      .self$denom <- denom / g
      },
    show = function() {
      cat(paste0(.self$numer, "/", .self$denom, "\n"))
      },
    add = function(that) {
      Rational(numer = numer * that$denom + that$numer * denom,
               denom = denom * that$denom)
      },
    neg = function() {
      Rational(numer = -.self$numer,
               denom = .self$denom)
      },
    sub = function(that) {
      add(that$neg())
      }
    )
  )

# Test cases:
rational <- Rational(2, 3)
rational$add(rational)
{% endhighlight %}



{% highlight text %}
## 4/3
{% endhighlight %}



{% highlight r %}
rational$neg()
{% endhighlight %}



{% highlight text %}
## -2/3
{% endhighlight %}



{% highlight r %}
rational$sub(rational)
{% endhighlight %}



{% highlight text %}
## 0/1
{% endhighlight %}



{% highlight r %}
x <- Rational(numer = 1, denom = 3)
y <- Rational(numer = 5, denom = 7)
z <- Rational(numer = 3, denom = 2)
x$sub(y)$sub(z)
{% endhighlight %}



{% highlight text %}
## -79/42
{% endhighlight %}

I don't know how you feel about the code above but my eyes just don't find a
point to focus. Maybe this is me but it looks very complicated, given the simple
example I think too complicated. Something which is possible in Scala but not in
R is to have binary notation, so the second test case line can be written as
`rational add rational`, so you get rid of a couple of more symbols. Further
down I will show how this can be implemented in R. Also you do not really want
`gcd` to be public or `denom` and `numer` changeable for the client, which I
think is not easily achieved in R either. Anyway, after two lines I was
frustrated and thought that this has to be solved so that it's fun to write
reference classes and add things like public and private member.

## Modifying `setRefClass`

In a first step I want to get rid of all kinds of commas, parenthesis and lists.
How? For this I use non standard evaluation. In the following example I show how
to evaluate a code snippet and store the results in a list for later use.


{% highlight r %}
# First create an environment in which the code is evaluated:
eval(expression({
  a <- 1
  b <- 2
}), envir = e <- new.env())

# Check that they exist:
ls(envir = e)
{% endhighlight %}



{% highlight text %}
## [1] "a" "b"
{% endhighlight %}



{% highlight r %}
# And convert it to a list:
as.list(e)
{% endhighlight %}



{% highlight text %}
## $a
## [1] 1
## 
## $b
## [1] 2
{% endhighlight %}

Here we have a terribly complicated way to construct a list but basically it is
the idea to improve the definition of reference classes. The list that is
constructed is used to define the arguments to `setRefClass` and then the result
looks as follows:


{% highlight r %}
# devtools::install_github("wahani/aoos", ref = "146ba25b48fb6fda69a622e40784595bb4786819")
library("aoos")

Rational <- defineRefClass({
  Class <- "Rational"

  numer <- "numeric"
  denom <- "numeric"

  gcd <- function(a, b) if(b == 0) a else Recall(b, a %% b)

  initialize <- function(numer, denom) {
    g <- gcd(numer, denom)
    .self$numer <- numer / g
    .self$denom <- denom / g
  }

  show <- function() {
    cat(paste0(.self$numer, "/", .self$denom, "\n"))
  }

  add <- function(that) {
    Rational(numer = numer * that$denom + that$numer * denom,
             denom = denom * that$denom)
  }

  neg <- function() {
    Rational(numer = -.self$numer,
             denom = .self$denom)
  }

  sub <- function(that) {
    add(that$neg())
  }

})
{% endhighlight %}



{% highlight text %}
## Error in eval(expr, envir, enclos): could not find function "defineRefClass"
{% endhighlight %}

`defineRefClass` is a wrapper around `setRefClass` and captures whatever you
write inside the curly braces. So this is really just a different representation
of the above example but at least for me easier to read. The test cases for
confirmation:


{% highlight r %}
rational <- Rational(2, 3)
rational$add(rational)
{% endhighlight %}



{% highlight text %}
## 4/3
{% endhighlight %}



{% highlight r %}
rational$neg()
{% endhighlight %}



{% highlight text %}
## -2/3
{% endhighlight %}



{% highlight r %}
rational$sub(rational)
{% endhighlight %}



{% highlight text %}
## 0/1
{% endhighlight %}



{% highlight r %}
x <- Rational(numer = 1, denom = 3)
y <- Rational(numer = 5, denom = 7)
z <- Rational(numer = 3, denom = 2)
x$sub(y)$sub(z)
{% endhighlight %}



{% highlight text %}
## -79/42
{% endhighlight %}

Next, implement a notion of privacy! I just could not think of anything better
but to override the default accessor, i.e. `$` to make things seem to be
private. You can inherit from a class called `Private` which will not let you
access member with leading period in their names - if you must see the code: [go
here](https://github.com/wahani/aoos/blob/master/R/Private.R).


{% highlight r %}
# Updated definition with 'private' member
Rational <- defineRefClass({
  Class <- "RationalWithPrivate"
  contains <- "Private"

  numer <- "numeric"
  denom <- "numeric"

  .gcd <- function(a, b) if(b == 0) a else Recall(b, a %% b)

  initialize <- function(numer, denom) {
    g <- .gcd(numer, denom)
    .self$numer <- numer / g
    .self$denom <- denom / g
  }

  show <- function() {
    cat(paste0(.self$numer, "/", .self$denom, "\n"))
  }

  add <- function(that) {
    Rational(numer = numer * that$denom + that$numer * denom,
             denom = denom * that$denom)
  }

  neg <- function() {
    Rational(numer = -.self$numer,
             denom = .self$denom)
  }

  sub <- function(that) {
    add(that$neg())
  }

})
{% endhighlight %}



{% highlight text %}
## Error in eval(expr, envir, enclos): could not find function "defineRefClass"
{% endhighlight %}



{% highlight r %}
rational <- Rational(2, 3)
rational$.gcd
{% endhighlight %}



{% highlight text %}
## Error in envRefInferField(x, what, getClass(class(x)), selfEnv): '.gcd' is not a valid field or method name for reference class "Rational"
{% endhighlight %}



{% highlight r %}
rational$add(rational)
{% endhighlight %}



{% highlight text %}
## 4/3
{% endhighlight %}



{% highlight r %}
rational$neg()
{% endhighlight %}



{% highlight text %}
## -2/3
{% endhighlight %}



{% highlight r %}
rational$sub(rational)
{% endhighlight %}



{% highlight text %}
## 0/1
{% endhighlight %}

This will prevent the client to access `.gcd`. But auto-complete for instances
of a *Rational* are polluted with private member and all kinds of other things.
And I still have not implemented the sugar to be able to write `add` and `sub`
in binary notation.

## More object orientation

This was probably a time consuming solution and maybe not really necessary, but
essentially I reimplemented `setRefClass`. This solution is more a prove of
concept because in most scenarios I don't need object orientation and maybe you
want to consider other implementations in R, or you are just like me and like to
get rid of unnecessary symbols in your code. The function `defineClass` has
nothing to do with `setRefClass` but it still uses `S4` method dispatch and
classes. There is more to it than I present here, but lets just look at the
example:


{% highlight r %}
Rational <- defineClass("RationalAoos", contains = c("Show", "Accessor"), {

  numer <- NULL
  denom <- NULL

  .gcd <- function(a, b) if(b == 0) a else Recall(b, a %% b)

  init <- function(numer, denom) {
    g <- .gcd(numer, denom)
    .self$numer <- numer / g
    .self$denom <- denom / g
  }

  show <- function() {
    cat(paste0(.self$numer, "/", .self$denom, "\n"))
  }

  add <- function(that) {
    Rational(numer = .self$numer * that$denom + that$numer * .self$denom,
             denom = .self$denom * that$denom)
  }

  neg <- function() {
    Rational(numer = -.self$numer,
             denom = .self$denom)
  }

  sub <- function(that) {
    add(that$neg())
  }

})

rational <- Rational(2, 3)
rational$add(rational)
{% endhighlight %}



{% highlight text %}
## 4/3
{% endhighlight %}



{% highlight r %}
rational$neg()
{% endhighlight %}



{% highlight text %}
## -2/3
{% endhighlight %}



{% highlight r %}
rational$sub(rational)
{% endhighlight %}



{% highlight text %}
## 0/1
{% endhighlight %}



{% highlight r %}
x <- Rational(numer = 1, denom = 3)
y <- Rational(numer = 5, denom = 7)
z <- Rational(numer = 3, denom = 2)
x$sub(y)$sub(z)
{% endhighlight %}



{% highlight text %}
## -79/42
{% endhighlight %}

In this framework I use inheritance to add or change behaviour of a class. The
class *Show* will look for a member function called *show* to be used as
print/show S4 method. A leading period will also indicate a private member
although this can be changed. The inheritance from *Accessor* changes the way
you can access public fields, the default would be through get/set methods. So
besides this I was also able to implement my desired binary notation, although
it works a bit different:


{% highlight r %}
Rational <- defineClass(
  "RationalWithBinary", contains = c("Show", "Binary", "Accessor"), {

  numer <- NULL
  denom <- NULL

  .gcd <- function(a, b) if(b == 0) a else Recall(b, a %% b)

  init <- function(numer, denom) {
    g <- .gcd(numer, denom)
    .self$numer <- numer / g
    .self$denom <- denom / g
  }

  show <- function() {
    cat(paste0(.self$numer, "/", .self$denom, "\n"))
  }

  ".+" <- function(that) {
    Rational(numer = .self$numer * that$denom + that$numer * .self$denom,
             denom = .self$denom * that$denom)
  }

  neg <- function() {
    Rational(numer = -.self$numer,
             denom = .self$denom)
  }

  ".-" <- function(that) {
    self + that$neg()
  }

})

rational <- Rational(2, 3)
rational + rational
{% endhighlight %}



{% highlight text %}
## 4/3
{% endhighlight %}



{% highlight r %}
rational$neg()
{% endhighlight %}



{% highlight text %}
## -2/3
{% endhighlight %}



{% highlight r %}
rational - rational
{% endhighlight %}



{% highlight text %}
## 0/1
{% endhighlight %}



{% highlight r %}
x <- Rational(numer = 1, denom = 3)
y <- Rational(numer = 5, denom = 7)
z <- Rational(numer = 3, denom = 2)
x - y - z
{% endhighlight %}



{% highlight text %}
## -79/42
{% endhighlight %}

I think by now it is  obvious what has changed. So this is very close to what I
want to have as object orientation, and I am pretty happy with it, although I
still have some ideas I want to implement.

## Again, just different

You can of course explore other implementations of object orientation in R or
just write your own one, but the fewer packages you rely on, the less surprising
bugs arise after a new R version. I am still reluctant to rely on aoos although
it looks nice and I am the maintainer. So maybe we should consider a pure R or
functional solution. What all reference classes in R have in common is that they
inherit from *environment*. And we know that whenever a function is called a new
environment is created in which the body of the function is evaluated, so you
can simply return this environment and use it as an object as in object
orientation.


{% highlight r %}
Rational <- function(numer, denom) {

  gcd <- function(a, b) if(b == 0) a else Recall(b, a %% b)

  g <- gcd(numer, denom)
  numer <- numer / g
  denom <- denom / g

  print <- function() cat(paste0(numer, "/", denom, "\n"))

  add <- function(that) {
    Rational(numer = numer * that$denom + that$numer * denom,
             denom = denom * that$denom)
  }

  neg <- function() {
    Rational(numer = -numer,
             denom = denom)
  }

  sub <- function(that) {
    add(that$neg())
  }

  # Return everything in this scope:
  structure(environment(), class = c("Rational", "Print"))

}

print.Print <- function(x, ...) x$print()

rational <- Rational(2, 3)
rational$add(rational)
{% endhighlight %}



{% highlight text %}
## 4/3
{% endhighlight %}



{% highlight r %}
rational$neg()
{% endhighlight %}



{% highlight text %}
## -2/3
{% endhighlight %}



{% highlight r %}
rational$sub(rational)
{% endhighlight %}



{% highlight text %}
## 0/1
{% endhighlight %}



{% highlight r %}
x <- Rational(numer = 1, denom = 3)
y <- Rational(numer = 5, denom = 7)
z <- Rational(numer = 3, denom = 2)
x$sub(y)$sub(z)
{% endhighlight %}



{% highlight text %}
## -79/42
{% endhighlight %}

Just functions. And yes, the S3 class system. The initialize method did not
survive the translation because the constructor takes on this responsibility. I
use *Print* here for the same reason I defined the class *Show* in aoos, to use
the print/show method defined as member function. Most important for me are the
binary operators - not really but I start with them - which can be implemented
using the S3 class system.


{% highlight r %}
library("magrittr")
list(c("+.Binary", ".+"), c("-.Binary", ".-")) %>%
  lapply(function(pair) {
    assign(pair[1],
           function(e1, e2) get(pair[2], envir = as.environment(e1))(e2),
           envir = .GlobalEnv)
    }) -> captureOutput

Rational <- function(numer, denom) {

  gcd <- function(a, b) if(b == 0) a else Recall(b, a %% b)

  g <- gcd(numer, denom)
  numer <- numer / g
  denom <- denom / g

  print <- function() cat(paste0(numer, "/", denom, "\n"))

  ".+" <- function(that) {
    Rational(numer = numer * that$denom + that$numer * denom,
             denom = denom * that$denom)
  }

  neg <- function() {
    Rational(numer = -numer,
             denom = denom)
  }

  ".-" <- function(that) {
    self + that$neg()
  }

  # Return everything in this scope:
  self <- structure(environment(), class = c("Rational", "Print", "Binary"))
  self

}

rational <- Rational(2, 3)
rational + rational
{% endhighlight %}



{% highlight text %}
## 4/3
{% endhighlight %}



{% highlight r %}
rational - rational
{% endhighlight %}



{% highlight text %}
## 0/1
{% endhighlight %}

What about access restriction? At this time we can access all elements in
*rational*. We can simply return only those elements we want the client to see
in a list; and that is what the function `retList` will do for you. This becomes
tricky when you defined fields which can change, because by exporting them to a
list you made a copy of them and things may not work the way you expect them to.
In that scenario you should define get and set methods, or better, avoid that
scenario. I have seen solutions where the methods are defined directly inside
the list constructor which works fine but then I am back where I started above -
I don't want to define functions inside the list constructor.


{% highlight r %}
Rational <- function(numer, denom) {

  gcd <- function(a, b) if(b == 0) a else Recall(b, a %% b)

  g <- gcd(numer, denom)
  numer <- numer / g
  denom <- denom / g

  print <- function() cat(paste0(numer, "/", denom, "\n"))

  ".+" <- function(that) {
    Rational(numer = numer * that$denom + that$numer * denom,
             denom = denom * that$denom)
  }

  neg <- function() {
    Rational(numer = -numer,
             denom = denom)
  }

  ".-" <- function(that) {
    self + that$neg()
  }

  # Return only what should be visible from this scope:
  self <- retList(c("Binary", "Print"),
                  c("numer", "denom", ".+", ".-", "neg", "print"))
  self

}

rational <- Rational(2, 3)
{% endhighlight %}



{% highlight text %}
## Error in Rational(2, 3): could not find function "retList"
{% endhighlight %}



{% highlight r %}
rational + rational
{% endhighlight %}



{% highlight text %}
## Error in Rational(numer = numer * that$denom + that$numer * denom, denom = denom * : could not find function "retList"
{% endhighlight %}



{% highlight r %}
rational - rational
{% endhighlight %}



{% highlight text %}
## Error in Rational(numer = -numer, denom = denom): could not find function "retList"
{% endhighlight %}

Returning a list can be superior because it comes with an easy and straight
forward way for inheritance. Extensions can be added to the list returned and
method replacements can be implemented, well, by replacing elements in the
returned list. However, it reminds me of prototype based object orientation and
probably can be implemented differently.


{% highlight r %}
Person <- function(name) {
  force(name)
  print <- function() cat("Hi, my name is", name)
  retList(c("Person", "Print"), "print")
}

Employee <- function(id, ...) {
  force(id)
  super <- Person(...)
  print <- function() cat(super$print(), "and my employee id is", id)
  retList("Employee", "print", super)
}

Employee(1, "Chef")
{% endhighlight %}



{% highlight text %}
## Error in Person(...): could not find function "retList"
{% endhighlight %}

The End!
