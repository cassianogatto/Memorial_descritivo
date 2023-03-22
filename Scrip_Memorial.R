library(rmarkdown)
library(htmltools)
library(tidyverse)


#### LOAD TABLE ----

tab <- read.csv('TAB_Kokama_lotes.csv', header = T) %>% as_tibble()

#### RENDER MARKDOWN!!! ----

lista_de_id <- c(1:9, 15:21, 51:58) # c(2, 8, 17, 21, 51, 58) #c(1:6, 8, 10,11, 15:23, 51:58)             #    #seq_len(nrow(table))) {

lista_de_id = 2

for (i in lista_de_id ){
  
    row_id = which(tab$id == i)
    
    V <- tab %>% slice(row_id) %>% as.list()
  
    output_file <- paste0("outputs/Memorial_casa_", i, ".html")
    
    output_file2 <- paste0("outputs/topografico_casa_", i, ".html")
    
    render("memorial_template3.Rmd", output_file = output_file, params = c(V, tab, row_id)) # 'params' passes the objects to the .Rmd
    
    render("topografico_template.Rmd" , output_file = output_file2, params = c(V, tab, row_id))
    
    cat(paste("Rendered", output_file, "\n"))
    
    cat(paste("Rendered", output_file2, "\n"))
}
#
#
#
#
#



#### TABLE MAKE-UP ----

{
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
      id %in% c(2:5,9, 52:54) ~ 'tab[i-1,"casa"]',
      id %in% c(16:19, 55:57) ~ 'tab[i+1, "casa"]',
      id == 15 ~ '55,56,57',
      TRUE ~ NA_character_  )) %>% 
    mutate(vizinho_esqr = case_when(
      casa %in% c(1:4, 8) ~  'tab[i+1,"casa"]',
      casa %in% c(17:20, 51:53, 56:58) ~ 'tab[i-1, "casa"]',
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
  
  # Save the queen tab
  write.csv(tab,'TAB_Kokama_lotes.csv')
  # tab %>%  write.table('clipboard')
}







