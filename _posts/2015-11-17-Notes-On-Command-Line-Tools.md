---
layout: post
section-type: post
title: Notes On Command Line Tools
comments: true
category: notes
tags: [shell]
---

In this post I keep some notes on usefull tools on the command line.

## Monitoring folders:

### For new files


{% highlight bash %}
inotifywait ~/data --recursive --monitor --event create
{% endhighlight %}

## Git

### remove all history


{% highlight bash %}
rm -rf .git
{% endhighlight %}

### init git
    

{% highlight bash %}
git init
git add .
git commit -m "Initial commit"
{% endhighlight %}

### push to GitHub


{% highlight bash %}
git remote add origin <github-uri>
git push -u --force origin master
{% endhighlight %}
