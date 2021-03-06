---
layout: post
title: Introducing Another Object Orientation System
description: "Introduction to the R-package aoos, another object orientation system in R - v0.2.0."
comments: false
math: true
categories: [R, oop, aoos]
archive: true
---

This is the second of a series of posts related to object oriented programming
in [R](https://cran.r-project.org/) and the package
[aoos](https://cran.r-project.org/package=aoos). The [previous]({% post_url 2015-01-02-Introducing-Another-Object-Orientation-System %}) introduced the
first version of aoos; this introduces version 0.2.0. the [next]({% post_url 2015-05-12-On-Reference-Classes-in-R-and-aoos %}) is on different
representations of reference classes in R.

R has more than enough systems for object orientation and here is yet another one. *S3* and *S4* are the built in systems. [R.oo](http://cran.r-project.org/web/packages/R.oo/index.html) has been developed since 2001; [proto](http://cran.r-project.org/web/packages/proto/index.html) since 2005; and [R6](http://cran.r-project.org/web/packages/R6/index.html) is the newest and published to CRAN in 2014.

What I wanted to have is a system where method definitions are part of the class definition. Something which forces me to define functions belonging to one concept in one place, however, I don't feel comfortable to define them inside lists. So here I present my solution for your consideration.

As an example for this post consider the class *Directory*. `defineClass` is used to define a new class. If you want a field or method to be private, i.e. not easily accessible from the client, you can use the function ` private`. The *class definition* is a R-expression; every assignment in that expression will define a field or method.


{% highlight text %}
## Downloading GitHub repo wahani/aoos@v0.2.0
{% endhighlight %}



{% highlight text %}
## Installing aoos
{% endhighlight %}



{% highlight text %}
## '/usr/lib/R/bin/R' --no-site-file --no-environ --no-save --no-restore  \
##   CMD INSTALL '/tmp/RtmpqT9OpB/devtools55174eeaa43/wahani-aoos-25d66d4'  \
##   --library='/usr/local/lib/R/site-library' --install-tests
{% endhighlight %}



{% highlight text %}
## 
{% endhighlight %}


{% highlight r %}
library("aoos")
{% endhighlight %}



{% highlight text %}
## Loading required package: methods
{% endhighlight %}



{% highlight r %}
Directory <- defineClass("Directory", contains = c("Show", "Binary"), {

  dirName <- private(getwd())

  init <- function(name) {
    if(!missing(name)) {
      if(!file.exists(name)) {
        message("Creating new directory '", name, "' ...")
        dir.create(name)
        }
       self$dirName <- name
    }
  }

  remove <- function(...) {
    filesInDir <- list.files(path = dirName, ...)
    if(length(filesInDir)) self - filesInDir else message("No files in directory!")
    invisible(self)
  }

  show <- function(object) {
    print(file.info(dir(dirName, full.names = TRUE))[c("size", "mtime")])
    }

  "./" <- function(e2) paste(dirName, "/", e2, sep = "")

  ".-" <- function(e2) file.remove(self/e2)

})
{% endhighlight %}

The class *Directory* is basically a S4 class and inherits from *environment*. You can only access *public* member; and the return value of `defineClass` is the constructor function, so you can use `Directory()` to create an instance of *Directory*. Arguments to the constructor are passed on to the `init` method if you have defined one. The class inherits from *Show* which means that the member function `show` is used as `show-method`, and *Binary* allows to define binary operators. On initialization a directory is created if it doesn't exist. We start with a directory named 'foo'.


{% highlight r %}
foo <- Directory("foo")
{% endhighlight %}



{% highlight text %}
## Creating new directory 'foo' ...
{% endhighlight %}



{% highlight r %}
# Adding some data:
write.table(matrix(0, 10, 10), file = foo/"someData.txt")
write.table(matrix(0, 10, 10), file = foo/"someMoreData.txt")

# See whats inside 'foo':
foo
{% endhighlight %}



{% highlight text %}
##                      size               mtime
## foo/someData.txt      292 2016-01-21 16:00:24
## foo/someMoreData.txt  292 2016-01-21 16:00:24
{% endhighlight %}



{% highlight r %}
# One file would have been enough!
foo - "someMoreData.txt"
{% endhighlight %}



{% highlight text %}
## [1] TRUE
{% endhighlight %}



{% highlight r %}
# Check if it works:
foo
{% endhighlight %}



{% highlight text %}
##                  size               mtime
## foo/someData.txt  292 2016-01-21 16:00:24
{% endhighlight %}



{% highlight r %}
# Anyway, this is stupid:
foo$remove()
foo
{% endhighlight %}



{% highlight text %}
## [1] size  mtime
## <0 rows> (or 0-length row.names)
{% endhighlight %}


{% highlight text %}
## [1] TRUE
{% endhighlight %}

If you are still interested you can install the package from [Github](https://github.com/wahani/aoos) or [CRAN](https://cran.r-project.org/package=aoos).
