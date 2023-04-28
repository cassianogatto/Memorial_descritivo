--- 
title: "Shiny render Markdown"
output: html_document 
params:
  tabela: ""
  V: ""
  list_id: ""
---
## Render R Markdown  from Shiny


```r
knitr::opts_chunk$set(echo = FALSE, message = FALSE)

# params = list(tabela = data_frame(nome = c("Ari", "Barroso", "Silva"), rua("Brasil", "Brasileiro", "isonheiro")), 
#               V = list(nome = "Rui", rua("Chapéu") ),
#               list_id = 1)
# 
# print(paste("o conteúdo da lista params:tabela é "  ) )
# 
# params$tabela
# 
# paste("list_id = ", params$list_id)
```

Apenas a casa selecionada


```
## [1] "Hello World!"
```








