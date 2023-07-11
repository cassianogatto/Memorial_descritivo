library(rmarkdown)
library(htmltools)
library(tidyverse)

# # remember !!
# > tab |> write.csv(file.choose(), row.names = FALSE)
# > tab <- read.csv(file.choose(), check.names = FALSE)


#### LOAD TABLE KOKAMA ----
'> getwd()
[1] "C:/Users/HUMANITAS-FAPEAM - 4/Documents/Cassiano/Memorial_descritivo2/Memorial_descritivo"'

# REMEMBER TO ASSIGN    row.names = FALSE  to save csv!

# tab %>% write.csv("TAB_Kokama6.csv", row.names = F)

tab <- read.csv("TAB_Kokama6.csv", header = T) %>% as_tibble()

tab <- tab %>% select(id, nome, cpf, rua, casa, dist_frente, dist_lateral, escala, perim, area, 
                      dms_x_M01, dms_y_M01, dms_x_M02, dms_y_M02, dms_x_M03, dms_y_M03,
                      dms_x_M04, dms_y_M04, everything())

tab %>% write.csv("TAB_Kokama6.csv", row.names = F)

#### LOAD IPIXUNA

setwd("C:/Users/Cliente/Documents/Cassiano/Shiny/Memorial_markdown-shiny/Memorial_descritivo/Dabukuri_espacial")

# ipixuna <- read.csv('Ipixuna4_longer.csv') %>% as_tibble()

ipixuna <- read.csv('Ipixuna7.csv', check.names = F) %>% as_tibble()

# ipi4 <-read.csv("C:/Users/Cliente/Documents/Cassiano/Shiny/Memorial_markdown-shiny/Memorial_descritivo/Old_stuf/Ipixuna4_longer.csv", check.names = F)
# ipixuna <- ipi4 %>% as_tibble()

ipixuna %>% names()

ipixuna <- ipixuna %>% arrange(ID_GERAL, ponto)

ipixuna <- ipixuna %>% mutate(ponto = paste0("M0", ponto))

ipixu <- ipixuna %>% select(id = 'ID_GERAL', nome, cpf, rua,  ponto, dms_x, dms_y, everything())

ipixu <- ipixu %>% pivot_wider(id_cols = c(id, nome, cpf, rua, SEMSA, frente, lateral), names_from = ponto, values_from = c(dms_x, dms_y, x, y))

ipixu %>% filter(nome != "")


write.csv(ipixu, "Ipixuna8.csv", row.names = F)


# TABELA GERAL

tg <- read.csv("TABELA GERAL.csv",check.names = F)

kk < read.csv("TAB_Kokama9.csv", check.names = F)


# # chat python version in pandas to pivot
# import pandas as pd
# 
# # Assuming 'obj' is a DataFrame in Python
# 
# # Specify the columns to keep as ID columns
# id_cols = ['id', 'nome', 'cpf', 'rua', 'SEMSA', 'frente', 'lateral']
# 
# # Specify the columns to pivot and the corresponding values
# ponto_cols = ['dms_x', 'dms_y', 'x', 'y']
# 
# # Perform the pivot operation
# obj = pd.pivot_table(obj, index=id_cols, columns='ponto', values=ponto_cols)









'print Memorial e levantamento topográfico'
#### RENDER MARKDOWN!!! ----


lista_de_id <-  c(2:9, 15:21, 51:58, 101:103) # c(2, 8, 17, 21, 51, 58) #c(1:6, 8, 10,11, 15:23, 51:58)             #    #seq_len(nrow(table))) {

# loop to print Memorial and Topographic
for (i in lista_de_id ){
  
    row_id = which(tab$id == i)
    
    V <- tab %>% slice(row_id) %>% as.list()
    
    where_to_put <- "C:/Users/HUMANITAS-FAPEAM - 4/Documents/Cassiano/Memorial_descritivo2/outputs"
  
    output_file <- paste0(where_to_put,"/Memorial_casa_", i, ".html")
    
    output_file2 <- paste0(where_to_put,"/topografico_casa_", i, ".html")
    
    render("memorial_template3.Rmd", output_file = output_file, params = c(V, tab, row_id)) # 'params' passes the objects to the .Rmd
    
    render("topografico_template.Rmd" , output_file = output_file2, params = c(V, tab, row_id))
    
    cat(paste("Rendered", output_file, "\n"))
    
    cat(paste("Rendered", output_file2, "\n"))
}




#### LOAD TABLE IPIXUNA ----

tab_ipi <- read.csv('TAB_Ipixuna_lotes.csv', header = T) %>% as_tibble()

#### RENDER MARKDOWN!!! ----

lista_de_id <- c(1:nrow(tab_ipi)) # c(2, 8, 17, 21, 51, 58) #c(1:6, 8, 10,11, 15:23, 51:58)             #    #seq_len(nrow(table))) {

for (i in lista_de_id ){
  
  row_id = which(tab$id == i)
  
  V <- tab %>% slice(row_id) %>% as.list()
  
  where_to_put <- "C:/Users/HUMANITAS-FAPEAM - 4/Documents/Cassiano/Memorial_descritivo2/outputs"
  
  output_file <- paste0(where_to_put,"/Memorial_casa_", i, ".html")
  
  output_file2 <- paste0(where_to_put,"/topografico_casa_", i, ".html")
  
  render("memorial_template3.Rmd", output_file = output_file, params = c(V, tab, row_id)) # 'params' passes the objects to the .Rmd
  
  render("topografico_template.Rmd" , output_file = output_file2, params = c(V, tab, row_id))
  
  cat(paste("Rendered", output_file, "\n"))
  
  cat(paste("Rendered", output_file2, "\n"))
}


#

#

#### TABLE MAKE-UP KOKAMA ----

{ # KOKAMA tab
  
  # load table and variables
  table <- read.csv("kokama_data/vertices_Novo_lotes.csv", header = T) %>% as_tibble()
  
  table$nome <- gsub("\n", "", table$nome)
  table
  # read_file('kokama_data/nomecpf.txt')
  # read_file('kokama_data/check_names_cpf.csv') %>% gsub(pattern = '\\r',replacement = '', x = .) %>% write.csv("test.csv")
  # read.table("kokama_data/nomecpf.txt", sep = '\t', header = T) %>% as_tibble()
  cpf_table <- read.csv("kokama_data/check_names_cpf.csv", header = T) %>% as_tibble()
  
  table <- table %>% left_join(cpf_table, by = c('nome' = 'nome')) %>% select(id, nome, cpf = cpf.y, rua, casa, vertex_ind, ponto, dec_x, dec_y, x, y)
  table  %>% group_by(id,nome, cpf) %>% summarise() %>% print(n = 24)
  table[which((table$id == 8)),'cpf'] <- paste0("???",'705.863.4832-39')
  
  # remove non-specified 'ponto'
  table <- table %>%  filter(ponto != "")
  table <- table %>%  filter(vertex_ind != 0)
  table[which(table$nome == "NATALIA DOS SANTOS COSTA" & table$ponto == 'M05'), "ponto"] <- 'M01'
  table %>% names()
  
  # Pivot tab
  tab <- table %>% pivot_wider(id_cols =  c(id, nome, cpf, rua, casa ), names_from = ponto, values_from = c(dec_x, dec_y, x,y) )
  
  # names to low caps
  tab$nome <- tab$nome %>% tolower() %>% str_to_title()
  
  # ajustes para cada terreno
  tab <- tab %>% 
    mutate(orientacao = case_when(
      id %in% c(1:7, 51:54) ~ 'sul',
      id %in% c(8,9,21, 55:58) ~ 'norte',
      id %in% c(16:20) ~ 'leste',
      id == 15 ~ 'oeste',
      TRUE ~ NA_character_  )) %>% 
    mutate(vizinho_dir = case_when(
      id %in% c(2:5,9, 52:54) ~ 'tab[i-1,"id"]',
      id %in% c(16:19, 55:57) ~ 'tab[i+1, "id"]',
      id == 15 ~ '55,56,57',
      TRUE ~ NA_character_  )) %>% 
    mutate(vizinho_esqr = case_when(
      id %in% c(1:4, 8) ~  'tab[i+1,"id"]',
      id %in% c(17:20, 51:53, 56:58) ~ 'tab[i-1, "id"]',
      TRUE ~ NA_character_  ))
  
  # orientação das laterais conforme orientação principal do terreno
  tab <- tab %>% mutate( orient_lat_dir = case_when(
    orientacao == 'sul' ~  'oeste',
    orientacao == 'oeste' ~  'norte',
    orientacao == 'norte' ~  'leste',
    orientacao == 'leste' ~ 'sul' )) %>% 
    mutate( orient_fun = case_when(
      orientacao == 'sul' ~  'norte',
      orientacao == 'oeste' ~  'leste',
      orientacao == 'norte' ~  'sul',
      orientacao == 'leste' ~ 'oeste' )) %>% 
    mutate( orient_lat_esq = case_when(
      orientacao == 'sul' ~  'leste',
      orientacao == 'oeste' ~  'sul',
      orientacao == 'norte' ~  'oeste',
      orientacao == 'leste' ~ 'norte'
    ))
  
  # add perimeter & area
  tab <- tab %>% mutate(area = case_when(
    id %in% c(2:5, 6:9, 15:20) ~ 120,
    id %in% c(51:58) ~ 42,
    id == 1 ~ 258,
    id == 21 ~ 450,
    TRUE ~ NA )) %>% 
    mutate(perim = case_when(
      id %in% c(2:5, 6:9, 15:20) ~ 46,
      id %in% c(51:58) ~ 28,
      id == 1 ~ 64,
      id == 21 ~ 90,
      TRUE ~ NA ))
  
  tab <- tab %>% mutate(dist_frente = case_when(
          id %in% c(1:20) ~ 8,
          id == 21 ~ 15,
          id %in% c(51:58) ~ 6))
  tab <- tab %>% mutate(dist_lateral = case_when(
          id %in% c(1:20) ~ 15,
          id == 21 ~ 30,
          id %in% c(51:58) ~ 7))
  
  tab <- tab %>% select(id, nome, cpf, rua, casa, contains('dec_x'), contains('dec_y'),
                        contains('orient'), contains('viz'), everything()) %>% arrange(id)
  
  # criar observacoes com ajustes gerais e pra cada lateral em cada casa
  
  tab <- tab %>% mutate(observacoes = as.character(""), 
                        obs_frente = as.character(""), obs_lat_dir = as.character(""), 
                        obs_lat_esq = as.character(""), obs_fundos = as.character(""))
  
  tab[which(tab$id %in% c(1:7, 16:20)),"obs_fundos"] <-"Fundos para o terreno do Sr. Julio Kokama."
  tab[1:nrow(tab), 'obs_frente'] <- paste0("Frente para a ", tab$rua)
  
  # OBS específicas -> usar a função fobs() assim: table <- fobs(table, ask = T )
  
  fobs <- function( tab = table, ask = TRUE) {
    
    if (ask){  YN <- readline("alguma observação? (Y/N)") } else {YN = 'Y'}
    
    if (! ((YN == 'Y')|(YN == 'y')) ){ stop("eita") } else {
      
      casas <- readline("quais casas? (use vírgulas): ")
      casas <- as.numeric(unlist(strsplit(casas, ",")))
      
      # if(! (all(casas) %in% table$casa ) ){ break("somente as casas existentes, porfa! ", )}
      
      OBS <- readline("1-observacoes; 2-obs_frente; 3-obs_lat_dir; 4-obs_fundos; 5-obs_lat_esq; 0-outras colunas; (vírgulas...) ")
      OBS <- as.numeric(unlist(strsplit(OBS, ",")))
      
      if( 0 < OBS & OBS < 6 ){ obs <- if(1 %in% OBS){ c("observacoes")} else { c() }
      obs <- if(2 %in% OBS){ c(obs, "obs_frente")} else { obs }
      obs <- if(3 %in% OBS){ c(obs, "obs_lat_dir")} else { obs }
      obs <- if(4 %in% OBS){ c(obs, "obs_fundos")} else { obs }
      obs <- if(5 %in% OBS){ c(obs, "obs_lat_esq")} else { obs }
      
      } else {obs <- readline(" números das colunas (vírgulas, pls) ") 
      obs <- as.numeric(unlist(strsplit(obs, ",")))    
      }
      
      text_obs <- readline(paste0("Digite a(s) ", names(tab[,obs]), " sobre a(s) casa(s) ", casas, "  :"))
      
      # print obs to table
      rows = which(tab$casa == casas)
      
      tab[rows, obs] <- text_obs
      
      # mais observações?
      repeat_obs <- readline("mais alguma observação? (Y/N)")
      
      if ((repeat_obs == 'Y')|(repeat_obs == 'y') ) { 
        
        # RUN AGAIN or get out!
        tab <- fobs(tab, ask = FALSE) 
        
      } else { return(tab) }
    }
    
  }
  
  # Observações individuais -> atualiza a tabela original
  tab[which(tab$id == 15), "vizinho_dir"] <- NA
  tab <- tab %>% mutate( observacoes = case_when(
    id == 1 ~ 'Primeira casa da rua Aturaxana',
    (id == 7 | id == 8) ~ 'Última casa da rua Aturaxana ipe',
    id == 16 ~ "Primeira casa da rua Mutsana ipe",
    TRUE ~ NA_character_
  ))
  
  tab <- tab %>% mutate(uso = ifelse( id %in% c(1:6,8, 15:21), "alvenaria", "terreno")) 
  
  # with my function :-P
  novas_obs <- FALSE
  if(novas_obs){
    try( table <- fobs(table), silent = TRUE)
  }
  
# tab <- tab %>% select(-c(1,2,3))  
  # Save the queen tab
  write.csv(tab,'TAB_Kokama_lotes.csv')
  # tab %>%  write.table('clipboard')
  
  '  Jucirneide de Sena Batista
  CPF: 572.590.972-72, esse parente vai ficar com a parte onde está com as linhas vermelhas no Mapa.
  Meirejane de Sena Batista
  CPF 003.417.522-90, essa parente ficará com a parte Azul do mapa.
  Jeonid de Sena Batista 
  CPF 646.270.802-63, esse parente ficará com a parte verde do Mapa.'
  
  julio_vertices <- read.csv('vertices_Novo_lotes.csv', header = T) %>% as_tibble() %>% select(id, rua, casa, nome, cpf, ponto = vertex_ind, everything())
  
  julio <- julio_vertices %>% pivot_wider(id_cols =  c(id, nome, cpf, rua, casa ), names_from = ponto, values_from = c(dec_x, dec_y, x,y) )
  
  
  
  # casa 22 (copy from dbftable) to tab
  t <- read.table("clipboard")
  t = t %>% mutate(nome = paste(V2,V3,V4), rua = paste(V5, V6), cpf = "032.566.862-06") %>% 
            select(id = V1, nome, cpf, rua, casa = V7, vertex_ind = V8, ponto = V9, y = V10, x = V11, dec_x = V12, dec_y = V13)
  
  t$ponto = c("M01", "M02", "M03", "M04")
  
  t <- t %>% pivot_wider(id_cols = c(id, nome, cpf, rua, casa), names_from = ponto, values_from = c(dec_x, dec_y, x, y))
  
  ncol(tab); ncol(t)
  
  Ntab <- full_join(tab, t)
  
  Ntab[which(Ntab$id == 22),]
  
  write.csv(Ntab, 'clipboard')
  
  
  ## tab <- read.csv('TAB_Kokama_lotes.csv', header = T) %>% as_tibble()
  tab<- read.csv('TAB_Kokama_lotes_2.csv', header = T) %>% as_tibble()
  
  tab$escala <- rep("1/200", nrow(tab))
  
  'escala terrenos filhos do seu Júlio = 1/1000'
  
  test <- full_join(tab,julio)
  test[26:29, 24:35] <- test[26:29, 24:35] /1000
  
  #SAVE
  tab <- test
  
  # Julio filhos
  tab = tab %>% edit()
  
  tab[tab$id==101,]
  
  
  "Carlos Alberto da Costa Santos, CPF 520.202.902-00, mudou de local, ele agora é morador da rua Panara Ipé, o terreno dele é 6 de frente por 7 de comprimento.

    Zenildes Marques da Costa CPF 510.948.942-49, é moradora da Rua mutsana Ipé, tamanho do terreno dela é 8 de frente por 20 de comprimento.
    
    CLEYDE MARIA SANTOS TEXEIRA CPF 699.030.422-72 moradora da rua Aturaxana Ipé, o tamanho do terreno dela é 5 de frete por 15 de comprimento.
    
    Jaqueline dos Santos Costa, CPF: 703.617.482-05, moradora da rua mutsana Ipé, o terreno dela é 7 de frete por 7 de comprimento.
    
    Tatiana da Silva Araújo CPF 024.812.832-95, moradora da rua Aturaxana Ipé, o terreno dela mede 5 de frente por 15 de comprimento.
    
    Cleinando Coelho Batista CPF 704.444.722-01, morador da rua Aturaxana Ipé, o terreno mede 6 de frente por 15 de comprimento."
  
  tab[30:35, "nome"] <- c("Carlos Alberto da Costa Santos", "Zenildes Marques da Costa", "Cleyde Maria dos Santos Teixeira", "Jaqueline dos Santos Costa",
    "Tatiana da Silva Araújo", "Cleinando Coelho Batista")
  tab[30:35, "cpf"] <- c("520.202.902-00", "510.948.942-49", "699.030.422-72", "703.617.482-05", "024.812.832-95", "704.444.722-01")
  tab[30:35, "rua"] <- c("Panara ipe", "Mutsana ipe", "Aturaxana ipe", "Mutsana ipe", "Aturaxana ipe", "Aturaxana ipe")
  tab[30:35, "dist_frente"] <- c(6,8, 5, 7, 5, 6)
  tab[30:35, "dist_lateral"] <- c(7, 20, 15, 7, 15, 15 )
  
  
  
  
  tab %>% write.csv(.,"TAB_Kokama_lotes_4.csv")
  
  
}







