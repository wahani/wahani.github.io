---
layout: post
title: "A not so simple bar plot example using ggplot2"
author: "Sebastian"
categories: [R, graphics]
description: "A barplot example using ggplot2 from the book 'Datendesign mit R'."
archive: false
---



This is a reproduction of the (*simple*) bar plot of chapter 6.1.1 in [*Datendesign mit R*](http://www.datendesign-r.de/) with [ggplot2](http://ggplot2.org/). To download the data you can use the following lines:


{% highlight r %}
dir.create("data")
writeLines("*", "data/.gitignore")
download.file("http://www.datendesign-r.de/alle_daten.zip",
              "data/alle_daten.zip")
unzip("data/alle_daten.zip", exdir = "data")
{% endhighlight %}

And to download the original script and the base R version of this plot:


{% highlight r %}
download.file("http://www.datendesign-r.de/beispielcode.zip",
              "data/beispielcode.zip")
unzip("data/beispielcode.zip", exdir = "data")
{% endhighlight %}

After downloading check out the original pdf version of this plot in `data/beispielcode/pdf/balkendiagramm_einfach.pdf`.

## Preparing data

Here are some steps to modify the data such that it can be easily used with ggplot2.


{% highlight r %}
ipsos <- openxlsx::read.xlsx("../data/alle_daten/ipsos.xlsx") # this most likely needs adjustment
{% endhighlight %}



{% highlight text %}
## Error in loadNamespace(name): there is no package called 'openxlsx'
{% endhighlight %}



{% highlight r %}
ipsos <- ipsos[order(ipsos$Wert),]
{% endhighlight %}



{% highlight text %}
## Error in eval(expr, envir, enclos): object 'ipsos' not found
{% endhighlight %}



{% highlight r %}
ipsos$Land <- ordered(ipsos$Land, ipsos$Land)
{% endhighlight %}



{% highlight text %}
## Error in factor(x, ..., ordered = TRUE): object 'ipsos' not found
{% endhighlight %}



{% highlight r %}
ipsos$textFamily <- ifelse(ipsos$Land %in% c("Deutschland","Brasilien"),
                           "Lato Black", "Lato Light")
{% endhighlight %}



{% highlight text %}
## Error in match(x, table, nomatch = 0L): object 'ipsos' not found
{% endhighlight %}



{% highlight r %}
ipsos$labels <- paste0(ipsos$Land, ifelse(ipsos$Wert < 10, "     ", "  "),
                       ipsos$Wert)
{% endhighlight %}



{% highlight text %}
## Error in paste0(ipsos$Land, ifelse(ipsos$Wert < 10, "     ", "  "), ipsos$Wert): object 'ipsos' not found
{% endhighlight %}



{% highlight r %}
rect <- data.frame(
  ymin = seq(0, 80, 20),
  ymax = seq(20, 100, 20),
  xmin = 0.5, xmax = 16.5,
  colour = rep(c(grDevices::rgb(191,239,255,80,maxColorValue=255),
                 grDevices::rgb(191,239,255,120,maxColorValue=255)),
               length.out = 5))
{% endhighlight %}

## The basic plot

First we add the *geoms*, then modifications to the *scales* and flip of the coordinate system. The remaining code is just modifying the appearance.


{% highlight r %}
library("ggplot2")
ggBar <- ggplot(ipsos) +
  geom_bar(aes(x = Land, y = Wert), stat = "identity", fill = "grey") +
  geom_bar(aes(x = Land, y = ifelse(Land %in% c("Brasilien", "Deutschland"), Wert, NA)),
           stat = "identity", fill = rgb(255,0,210,maxColorValue=255)) +
  geom_rect(data = rect,
            mapping = aes(ymin = ymin, ymax = ymax,
                          xmin = xmin, xmax = xmax),
            fill = rect$colour) +
  geom_hline(aes(yintercept = 45), colour = "skyblue3") +
  scale_y_continuous(breaks = seq(0, 100, 20), limits = c(0, 100), expand = c(0, 0)) +
  scale_x_discrete(labels = ipsos$labels) +  
  coord_flip() +
  labs(y = NULL,
       x = NULL,
       title = NULL) +
  theme_minimal() +
  theme(panel.grid.minor = element_blank(),
        panel.grid.major = element_blank(),
        axis.ticks = element_blank(),
        axis.text.y = element_text(
          family = ipsos$textFamily),
        text = element_text(family = "Lato Light"))
{% endhighlight %}



{% highlight text %}
## Error in ggplot(ipsos): object 'ipsos' not found
{% endhighlight %}



{% highlight r %}
ggBar
{% endhighlight %}



{% highlight text %}
## Error in eval(expr, envir, enclos): object 'ggBar' not found
{% endhighlight %}

## Annotations and layout

Of course you can simply add the title and text annotations to the plot using ggplot2, but I didn't find a way to do the exact placement comparable to the original version without the package grid.


{% highlight r %}
library("grid")

vp_make <- function(x, y, w, h) 
  viewport(x = x, y = y, width = w, height = h, just = c("left", "bottom"))

main <- vp_make(0.05, 0.05, 0.9, 0.8)
title <- vp_make(0, 0.9, 0.6, 0.1)
subtitle <- vp_make(0, 0.85, 0.4, 0.05)
footnote <- vp_make(0.55, 0, 0.4, 0.05)
annotation1 <- vp_make(0.7, 0.8, 0.225, 0.05)
annotation2 <- vp_make(0.4, 0.8, 0.13, 0.05)

# To see which space these viewports will use:
grid.rect(gp = gpar(lty = "dashed"))
grid.rect(gp = gpar(col = "grey"), vp = main)
grid.rect(gp = gpar(col = "grey"), vp = title)
grid.rect(gp = gpar(col = "grey"), vp = subtitle)
grid.rect(gp = gpar(col = "grey"), vp = footnote)
grid.rect(gp = gpar(col = "grey"), vp = annotation1)
grid.rect(gp = gpar(col = "grey"), vp = annotation2)
{% endhighlight %}

<img src="/assets/images/2015-05-15-Datendesign-Barplot-simple/unnamed-chunk-6-1.png" title="center" alt="center" width="100%" />

And now we can add the final annotations to the plot:


{% highlight r %}
# pdf_datei<-"balkendiagramme_einfach.pdf"
# cairo_pdf(bg = "grey98", pdf_datei, width=9, height=6.5)

grid.newpage()
print(ggBar, vp = main)
{% endhighlight %}



{% highlight text %}
## Error in print(ggBar, vp = main): object 'ggBar' not found
{% endhighlight %}



{% highlight r %}
grid.text("'Ich glaube fest an Gott oder ein höheres Wesen'",
          gp = gpar(fontfamily = "Lato Black", fontsize = 14),
          just = "left", x = 0.05, vp = title)

grid.text("...sagten 2010 in:",
          gp = gpar(fontfamily = "Lato Light", fontsize = 12),
          just = "left",
          x = 0.05, vp = subtitle)

grid.text("Quelle: www.ipsos-na.com, Design: Stefan Fichtel, ixtract",
          gp = gpar(fontfamily = "Lato Light", fontsize = 9),
          just = "right",
          x = 0.95, vp = footnote)

grid.text("Alle Angaben in Prozent",
          gp = gpar(fontfamily = "Lato Light", fontsize = 9),
          just = "right",
          x = 1, y = 0.55, vp = annotation1)

grid.text("Durchschnitt: 45",
          gp = gpar(fontfamily = "Lato Light", fontsize = 9),
          just = "right",
          x = 0.95, y = 0.55, vp = annotation2)
{% endhighlight %}

<img src="/assets/images/2015-05-15-Datendesign-Barplot-simple/unnamed-chunk-7-1.png" title="center" alt="center" width="100%" />

{% highlight r %}
# dev.off()
{% endhighlight %}

