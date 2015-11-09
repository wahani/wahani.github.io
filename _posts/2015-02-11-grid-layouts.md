---
layout: post
section-type: post
title: "Customized layout with grid"
category: graphics
tags: [R, grid]
---

# How to layout element on a viewport

This is a short snippet for customized layouts of a graphic using grid.


{% highlight r %}
library(grid)
grid.rect(gp = gpar(lty = "dashed"))
main <- viewport(x = 0.1, y = 0.05, w = 0.8, h = 0.8,
                 just = c("left", "bottom"), name = "main")
title <- viewport(x = 0, y = 0.9, w = 0.6, h = 0.1,
                  just = c("left", "bottom"))
subtitle <- viewport(x = 0, y = 0.85, w = 0.4, h = 0.05,
                     just = c("left", "bottom"))
footnote <- viewport(x = 0.5, y = 0, w = 0.4, h = 0.05,
                     just = c("left", "bottom"))

grid.rect(gp = gpar(col = "grey"), vp = title)
grid.rect(gp = gpar(col = "grey"), vp = subtitle)
grid.rect(gp = gpar(col = "grey"), vp = main)
grid.rect(gp = gpar(col = "grey"), vp = footnote)
{% endhighlight %}

<img src="/img/2015-02-11-grid-layouts/unnamed-chunk-1-1.png" title="center" alt="center" width="100%" />
