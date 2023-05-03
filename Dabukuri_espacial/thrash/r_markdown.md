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

tab <- params$tab %>% as_tibble() %>% select(!contains("X"))
```

```
## Error in eval(expr, envir, enclos): object 'params' not found
```

```r
tab[1:4,1:5]
```

```
## # A tibble: 4 × 5
##      id nome                                       cpf            rua            casa
##   <int> <chr>                                      <chr>          <chr>         <int>
## 1     1 Maria Do Perpetuo Socorro Dos Santos Costa 520.585.222-49 Aturaxana ipe     1
## 2     2 Luciana Silva Da Costa                     064.788.292-27 Aturaxana ipe     3
## 3     3 Jander Marinho Dos Santos                  945.562.882-15 Aturaxana ipe     4
## 4     4 Joelma Dos Santos Costa                    031.805.342-06 Aturaxana ipe     5
```

```r
casa <- params$casa
```

```
## Error in eval(expr, envir, enclos): object 'params' not found
```

```r
casa %>% class()
```

```
## [1] "numeric"
```

```r
casa
```

```
## [1] 5
```

Apenas a casa selecionada- - - versão pretão


```
## # A tibble: 1 × 10
##      id nome                  cpf            rua            casa dec_y_M02  dec_y_M03 dec_y_M04 dec_y_M05 dec_y_M06
##   <int> <chr>                 <chr>          <chr>         <int> <chr>      <chr>     <chr>     <chr>     <chr>    
## 1     5 Wisley Conde Da Silva 105.549.272-09 Aturaxana ipe     6 3°0′57.71… 3°0′57.2… 3°0′57.1… <NA>      <NA>
```

estamos lidando com a rua Aturaxana ipe, uma boa **escolha** pra viver







