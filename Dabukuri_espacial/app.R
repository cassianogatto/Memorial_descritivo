library(shiny)
library(bslib)
library(tidyverse)
# source("html_select_module_small.R")

# https://appsilon.com/r-shiny-bslib/
custom_theme <- bs_theme(
    version = 5,    bg = "#FFFFFF",    fg = "#000000",    primary = "#0199F8",
    secondary = "#FF374B",    base_font = "Maven Pro"
)

# NÃO ESQUEÇA DE SETWD()!!
# setwd("C:/Users/Cliente/Documents/Cassiano/Shiny/Memorial_markdown-shiny/Memorial_descritivo/Dabukuri_espacial")


ui <- 
    
    tagList(tags$head(tags$style(HTML(" 
              
       body{
          align: center;
          text-size:14px;
          margin: 0px;
          padding:20px;
          width: auto; 
          height: auto;
      }
      
      @media print {
          @page { size: A4;}
      }
      
      .container {
          align-items: center;
          justify-content: center 
          display: flex;
          column-gap: 5px;
          width: 209mm;
          margin: 2px;
          padding: 2px;
          <!-- height: 297mm; -->
          <!-- border: 0.2px solid blue; -->
      }       
    
    " ) ) ),
    
    
    navbarPage(position = 'fixed-top', 

    # theme = bs_theme(version = 5, bootswatch = "lumen"),
    
    title = "DABUKURI - Direito ao Território", collapsible = TRUE,
    
    theme = bs_theme(version = 5, bootswatch = "flatly"),
    
    tabPanel("Apresentação",
             
             fluidRow(  column(2),  column(8, includeMarkdown("instrucoes.Rmd")  ), column(2),  )
             
    ),
    
    # "Comunidade" AQUI SELECAO DE COMUNIDADE DEVE ESCOLHER A TABELA BASE OU CHECKBOX PARA ESCOLHER OUTRA...
    
    tabPanel("Comunidade",
             
             sidebarLayout(
                 
                 sidebarPanel(width = 3,
                     
                    div(align = 'center', img(width = "80px", src = "DABUKURI.png" )),
                 
                    radioButtons('comunidade', 'Escolha a comunidade', c('Kokama', 'Ipixuna'), inline = TRUE),

                    fileInput( inputId = "filetab",  label = "Comunidade (tabela '.csv') ", accept = c(".csv"), multiple=TRUE),
                ),
                 
                mainPanel(width = 9,
                    
                    uiOutput("comunidade_intro"),
                
                    tags$h3("Tabela Geral"),  
                
                    tableOutput("tab"), 
                 )
             ),
    ),
    
    # Dados individuais
    
    tabPanel("Dados individuais",
           
            numericInput(inputId = "lista_de_id", label = "Escolha a ID", value = NULL),
            
            tags$h3("Casa Selecionada:"),
            
            fluidRow(
                
                column(8,  tableOutput("V_tab"),  ),
                
                column(4, uiOutput("image_dados_individuais"),  ),
            ),
            
            tags$h5("Use os botôes pra gerar os docs baseados nos templates base para Memoriais e Levantamentos Topográficos. 
                    Os documentos gerados estarão disponíveis nos respectivos links 
                    e poderão ser abertos no seu browser, ou na aba 'Documentos' deste App"),
            
            checkboxInput('input_templates',"Se desejar escolher outros templates, 'tique' este quadradinho", value = FALSE),
            
            conditionalPanel( condition = "input.input_templates == true",
                
                tags$h5("Após selecionar os templates gere os documentos e verifique o link."),
                
                br(),
                
                fluidRow(
                    
                    div(class = 'container',
                        
                        column(6,    
                               
                               selectInput(inputId = "memorial_template", label = "Arquivo memorial template", 
                                           choices = dir()[dir() %>% grep(pattern =  "*template_memorial*")],
                                           selected = "template_memorial_4_SHINY.Rmd"),
                        )),
                    
                    div(class = 'container',
                        
                        column(6,
                               
                               selectInput(inputId = "topografico_template", label = "Topográfico template", 
                                           choices = dir()[dir() %>% grep(pattern = "*template_topografico*")],
                                           selected = "topografico_template1.Rmd"),
                        )),
                ),
                
            ),
            
            fluidRow(
                
                div(class = 'container',
                    
                    column(6,    
                           
                           actionButton('get_memorial',"gerar memorial"),
                           
                           tags$h3("o arquivo Memorial gerado está em:"),
                           
                           uiOutput("markdown_memorial"),
                    )),
                
                div(class = 'container',
                    
                    column(6,
                           
                           actionButton("get_topografico","gerar topografico"),
                           
                           tags$h3("o arquivo Topográfico gerado está em:"),
                           
                           uiOutput("markdown_topografico"),
                    )),
            ),
    ),
    
    tabPanel("Selecione Documento",
               
            fileInput(inputId = 'file_html', label = 'na pasta www escolha o memorial ou levantamento topografico HTML', 
                                multiple = FALSE, accept = '.html'),
                 
            uiOutput("file_html") ,
    ),
)
)

server <- function(input, output, session) {
    
    options(shiny.maxRequestSize=1000*1024^2) # this is required for uploading large files.
  
    tab_react <- reactive(  {
    
        file <- input$filetab
        
        ext <- tools::file_ext(file$datapath)
        
        req(file)
        
        validate(need(ext == "csv", "Please upload a csv file"))
        
        tab <- read.csv(file$datapath, header = TRUE) %>% as_tibble()
    
    }  )
    
    V_react <- reactive(  {
    
        req(tab_react())
        
        row_slice <- which(tab_react()$id == input$lista_de_id)
        
        V <- tab_react() %>% slice(row_slice) 
    }  )
    
    output$tab <- renderTable( {  tab_react() %>% 
            
            select(id, nome, cpf, rua, casa, area, perim, dist_frente, dist_lateral, observacoes, obs_frente, obs_lat_dir, obs_lat_esq, obs_fundos,
                   
                  X1 = dms_x_M01, Y1 = dms_y_M01, X2 = dms_x_M02, Y2 = dms_y_M02, X3 = dms_x_M03, Y3 = dms_y_M03,  X4 = dms_x_M04, Y4 = dms_y_M04)
    } )
    
    output$V_tab <- renderTable(  tab_react() %>% 
                      select(id, nome, cpf, rua, casa, contains("dist_"), escala, observacoes, area, perim) %>%
                          slice( which(tab_react()$id == input$lista_de_id) )  )
    
    output$comunidade_intro <- renderUI({ includeMarkdown( switch(input$comunidade, Kokama = "www/kokama_intro.Rmd", Ipixuna = "www/ipixuna_intro.Rmd") ) })
    
    output$image_dados_individuais <- renderUI(
        
            file <- paste0()
    )
            
# SALVE MEMORIAL E TOPOGRAFICO
    
    output$markdown_memorial <- renderUI(  {
            
            req( input$get_memorial)
        
            rmarkdown::render(input$"memorial_template",
                      output_format = "html_document",
                      output_file = paste0("memorial_casa_", input$lista_de_id), 
                      output_dir = paste0(getwd(),'/www'),
                      params = list(tab = tab_react(), casa = input$lista_de_id, V = V_react() )  )
    } )
    
    output$markdown_topografico <- renderUI(  {
            
            req(input$get_topografico)
            
            rmarkdown::render(input$"topografico_template",
                      output_format = "html_document",
                      output_file = paste0("topografico_casa_", input$lista_de_id), 
                      output_dir = paste0(getwd(),'/www'),
                      params = list(tab = tab_react(), casa = input$lista_de_id, V = V_react() )  )
    } )
    
# LOAD HTML MEMORIAL E TOPOGRAFICO
    output$file_html <- renderUI({
      
        file <- input$file_html
        
        includeHTML( file$datapath )
  })
    
}
    


# runApp('Dabukuri_espacial')

# Normal Run App

shinyApp( ui = ui, server = server, options = list(width = 100) )


# Run the application with themer

# run_with_themer( shinyApp( ui = ui, server = server, options = list(width = 100) ) )



# navbarMenu("Documentos",       
# tabPanel("Memorial",
#          
#         ui_select_html(id = 'memo', type = 'memorial', button_label = 'escolha a casa', action_label = "Mostrar"),
#         
#         uiOutput("memo_out")
#           
#         
#        # selectInput("memo", "Memorial", choices = dir(path = "www", pattern = 'memorial_casa') ),
#        # textOutput('texto'),
#        # 
#        # uiOutput("loaded_memo_html")
# ),
# 
# tabPanel("Topográfico",
#          
#         ui_select_html(id = 'topo', type = 'topografico' , button_label = 'escolha a casa', action_label = "Mostrar"),
#         
#         uiOutput("topo_out")
#           
#         # selectInput("topo", "Topografico", choices = dir(path = 'www', pattern = 'topografico_casa') ), 
#         # 
#         # uiOutput("preview_topografico")
# ),
# ),    
# output$memo_out <- renderUI({
#     
#     includeHTML( 
#         file.path(getwd(),'www', input$memo)
#     )  
# })
# 
# output$topo_out <- renderUI({
#     
#     includeHTML( 
#         file.path(getwd(),'www', input$topo)
#     ) 
# })
# 
# output$texto <- renderText( file.path(getwd(),'www', input$memo) )
# MODULE select_html is NOT working as
# output$memo_out <- server_select_html(id = 'memo')
# 
# output$topo_out <- server_select_html(id = 'topo')

# # Define a reactiveFileReader to monitor the HTML file

# output$myhtml <- reactiveFileReader(
#     intervalMillis = 5000, # Check every second
#     filePath =   "C:/Users/Cliente/Documents/Cassiano/Shiny/Memorial_markdown-shiny/Memorial_descritivo/Dabukuri_espacial/www/memorial_casa_4.html",
#     session = NULL ,
#     readFunc = function(filePath) {
#         includeHTML(filePath)
#     }
# )
# UI
# uiOutput("myhtml")



# load figures in Mdown through R

# ```{r, out.width=='350px', fig.align='right'}
# 
# figure_path <- paste0('figures/casa__', V$id, '.png')  ## CHECK FIGURES' ID !!
# 
# knitr::include_graphics(figure_path)
# 
# ```

# Download
# output$downloadReport <- downloadHandler(

#     filename = function() {
#         paste('my-report', sep = '.', switch(
#             input$format, PDF = 'pdf', HTML = 'html', Word = 'docx'
#         ))
#     },
#     
#     content = function(file) {
#         src <- normalizePath('report.Rmd')
#         
#         # temporarily switch to the temp dir, in case you do not have write
#         # permission to the current working directory
#         owd <- setwd(tempdir())
#         on.exit(setwd(owd))
#         file.copy(src, 'report.Rmd', overwrite = TRUE)
#         
#         library(rmarkdown)
#         out <- render('report.Rmd', switch(
#             input$format,
#             PDF = pdf_document(), HTML = html_document(), Word = word_document()
#         ))
#         file.rename(out, file)
#     }
# )
