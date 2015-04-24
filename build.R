library(knitr)

args <- commandArgs(TRUE)
input <- args[1]
output <- args[2]

opts_chunk$set(tidy = FALSE)
figPath <- paste0("assets/images/", sub(".Rmd$", "", basename(input)), "/")
opts_chunk$set(fig.path = figPath)
opts_knit$set(base.url="/")
opts_chunk$set(fig.cap = "center")
opts_chunk$set(out.width = "100%")
opts_chunk$set(fig.width=7)
opts_chunk$set(fig.height=4)
opts_chunk$set(dev = 'png')
render_jekyll()

knit(input = args[1], output = args[2])
