--- 
title: "render markdown from shiny env"
output: html_document 
params:
  tab: NULL
  casa: NULL
---
## Render R Markdown  from Shiny


```r
knitr::opts_chunk$set(echo = FALSE, message = FALSE, eval = TRUE)

library(dplyr)

tab <- params$tab
```

```
## Error in eval(expr, envir, enclos): object 'params' not found
```

```r
casa <- params$casa
```

```
## Error in eval(expr, envir, enclos): object 'params' not found
```

Apenas a casa selecionada- - - versão pretão


```
## [1] "Hello World!"
```

```
## Error in UseMethod("filter"): no applicable method for 'filter' applied to an object of class "c('reactiveExpr', 'reactive', 'function')"
```



