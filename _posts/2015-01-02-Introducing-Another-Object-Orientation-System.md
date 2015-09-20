---
layout: post
published: true
title: Introducing Another Object Orientation System
description: "Introduction to the R-package aoos, another object orientation system in R - v0.1.0."
comments: true
math: true
tags: [R, oop, aoos]
archive: true
---

This is the first of a series of posts related to object oriented programming in [R](https://cran.r-project.org/) and the package [aoos](https://cran.r-project.org/package=aoos).
[The second introduces version 0.2.0]({% post_url 2015-05-08-Introducing-Another-Object-Orientation-System-2 %}).

R has more than enough systems for object orientation and here is yet another one. *S3* and *S4* are the built in systems. [R.oo](http://cran.r-project.org/web/packages/R.oo/index.html) has been developed since 2001; [proto](http://cran.r-project.org/web/packages/proto/index.html) since 2005; and [R6](http://cran.r-project.org/web/packages/R6/index.html) is the newest and published to CRAN in 2014.

What I wanted to have is a system where method definitions are part of the class definition. Something which forces me to define functions belonging to one concept in one place, however, I don't feel comfortable to define them inside lists. Furthermore I wanted to have auto-complete in R. So here I present my solution for your consideration. See also the [vignette for the package](http://wahani.github.io/aoos/vignettes/Introduction.html) if you should be interested in some more details.

As an example for this post consider the class *Directory*. `defineClass` is used to define a new class. The second argument is a R-expression. Every assignment in that expression will define a field or method. By default everything is private, if you want something to be public you have to use the function `public`.


{% highlight r %}
devtools::install_github("wahani/aoos", ref = "v0.1.0")
{% endhighlight %}



{% highlight text %}
## Downloading github repo wahani/aoos@v0.1.0
## Installing aoos
## '/usr/lib/R/bin/R' --no-site-file --no-environ --no-save --no-restore  \
##   CMD INSTALL '/tmp/Rtmph8OhqA/devtools5b531c263a93/wahani-aoos-94010bd'  \
##   --library='/home/sebastian/R/x86_64-pc-linux-gnu-library/3.2'  \
##   --install-tests
{% endhighlight %}



{% highlight r %}
library("aoos")
{% endhighlight %}



{% highlight text %}
## Loading required package: methods
{% endhighlight %}



{% highlight r %}
Directory <- defineClass("Directory", {

  dirName <- getwd()

  init <- function(name) {
    if(!missing(name)) {
      if(!file.exists(name)) {
        message("Creating new directory '", name, "' ...")
        dir.create(name)
        }
      self$dirName <- name
    }
  }

  getDirName <- public(function() dirName)

  remove <- public(function(...) {
    filesInDir <- list.files(path = dirName, ...)
    if(length(filesInDir)) self - filesInDir else message("No files in directory!")
    invisible(self)
  })

})

setMethod("show", "Directory",
          function(object) {
            print(file.info(dir(object$getDirName(), full.names = TRUE))[c("size", "mtime")])
            })

setMethod("/", c(e1 = "Directory", e2 = "character"),
          function(e1, e2) paste(e1$getDirName(), "/", e2, sep = ""))

setMethod("-", c(e1 = "Directory", e2 = "character"),
          function(e1, e2) file.remove(e1/e2))
{% endhighlight %}

The class *Directory* is basically a S4 class and inherits from *environment*. You can only access *public* member; and the return value of `defineClass` is the constructor function, so you can use `Directory()` to create an instance of *Directory*. Arguments to the constructor are passed on to the `init` method if you have defined one.

On initialization a directory is created if it doesn't exist. We start with a directory named 'foo'. I also defined some S4-methods, `show` to print some file infos to the console and two binary operators. `/` will be like a 'slash' and `-` will delete files from the directory.


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
## foo/someData.txt      292 2015-09-20 10:42:44
## foo/someMoreData.txt  292 2015-09-20 10:42:44
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
## foo/someData.txt  292 2015-09-20 10:42:44
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

If you are still interested, you can install the package from [Github](https://github.com/wahani/aoos) or [CRAN](http://cran.r-project.org/web/packages/aoos/index.html).
