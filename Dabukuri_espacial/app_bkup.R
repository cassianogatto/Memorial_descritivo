# setwd("C:/Users/Cliente/Documents/Cassiano/Shiny/Memorial_markdown-shiny/Memorial_descritivo/")

library(shiny)
library(bslib)
library(dplyr)

# https://appsilon.com/r-shiny-bslib/
custom_theme <- bs_theme(
    version = 5,    bg = "#FFFFFF",    fg = "#000000",    primary = "#0199F8",
    secondary = "#FF374B",    base_font = "Maven Pro"
)


ui <- navbarPage(
    
    # theme = bs_theme(version = 5, bootswatch = "lumen"),#custom_theme,
    
    title = "DABUKURI - Direito ao Território", collapsible = TRUE,
    
    tabPanel("Instruções",
             
             fluidRow(
                 
                 column(2),
                 column(8, 
                        
                        includeMarkdown("instrucoes.Rmd")
                 ),
                 column(2),
             )
             
    ),
    
    tabPanel("Comunidade",
             
        fluidPage(
           
            theme = bs_theme(version = 5, bootswatch = "lumen"),
             
            fluidRow(
                
                img(width = "50px", src = "www/DABUKURI.png" ),
                 
                column(4,
                       
                    radioButtons('comunidade', 'Escolha a comunidade', c('Kokama', 'Ipixuna'), inline = TRUE),

                    fileInput( inputId = "filetab",  label = "Comunidade (tabela '.csv') ", accept = c(".csv"), multiple=TRUE),
                    
                    selectInput(inputId = "memorial_template", label = "Arquivo markdown template", 
                                   choices = dir()[dir() %>% grep(pattern = ".Rmd")],
                                   selected = "template_memorial_4_SHINY.Rmd"),
                        
                    selectInput(inputId = "topografico_template", label = "Topográfico template", 
                                   choices = dir()[dir() %>% grep(pattern = ".Rmd")],
                                   selected = "topografico_template1.Rmd"),
                ),
       
                column(8,
                       
                    column(6,
                           
                           uiOutput("comunidade_intro")
                    ),# tags$img( src = "www/ipixuna_satelite.png" ),
                    
                    tags$h3("Tabela Geral"),  tableOutput("tab"),
                ),
             )
         ),
             

    ),
  
    tabPanel("Dados individuais",
           
            numericInput(inputId = "lista_de_id", label = "Escolha a ID", value = NULL),
            
            tags$h3("Casa Selecionada:"), tableOutput("V_tab"),
            
            tags$h3("o arquivo Memorial gerado está em:"),
                        
            uiOutput("markdown_memorial"),
            
            tags$h3("o arquivo Topográfico gerado está em:"),
                      
            uiOutput("markdown_topografico"),
    ),
    
    navbarMenu("Documentos",
             
          tabPanel("Memorial",
                    
                    tags$h4("preview:"),
                    
                    #includeHTML("C:/Users/Cliente/Documents/Cassiano/Shiny/Memorial_markdown-shiny/Memorial_descritivo/Dabukuri_espacial/outputs/memorial_casa_55.html"),
                      
                   actionButton("preview_memo", "Preview"),
                   
                   checkboxInput("check_memo", "check to load file", value = FALSE),
                   
                   conditionalPanel(condition =  "input.check_memo == true",
                       
                       fileInput(inputId = "load_memorial_html", "Carregue o arquivo indicado", accept = ".html"),
                       
                       uiOutput("loaded_memo_html")
                   ),
                   
                   
                   uiOutput("preview_memorial")
          ),
            
          tabPanel("Topográfico",
                      
                tags$h4("preview:"),
                   
                actionButton("preview_topo", "Preview"),   
                   
                uiOutput("preview_topografico")
          ),
    ),
    
    
)

server <- function(input, output, session) {
  
  tab_react <- reactive(  {
    
    file <- input$filetab
    
    ext <- tools::file_ext(file$datapath)
    
    req(file)
    
    validate(need(ext == "csv", "Please upload a csv file"))
    
    tab <- read.csv(file$datapath, header = TRUE) %>% as_tibble()
    
  })
  
  V_react <- reactive({
    
    req(tab_react())
    
    row_slice <- which(tab_react()$id == input$lista_de_id)
    
    V <- tab_react() %>% slice(row_slice) #%>% as.list()
  })
  
  output$tab <- renderTable({  tab_react() %>% select(1:5) })
  
  output$V_tab <- renderTable(  tab_react() %>% select(id, nome, cpf, rua, casa, contains("dist_"), escala, observacoes, area, perim) %>% slice( which(tab_react()$id == input$lista_de_id) )  )
  
  output$comunidade_intro <- renderUI({ includeMarkdown( switch(input$comunidade, Kokama = "www/kokama_intro.Rmd", Ipixuna = "www/ipixuna_intro.Rmd") ) })
            
  # SALVE MEMORIAL
  
  output$markdown_memorial <- renderUI( {
    
    rmarkdown::render(input$"memorial_template",
                      output_format = "html_document",
                      output_file = paste0("memorial_casa_", input$lista_de_id), 
                      output_dir = paste0(getwd(),'/outputs'),
                      params = list(tab = tab_react(), casa = input$lista_de_id, V = V_react() )  )
  })
  
  output$markdown_topografico <- renderUI( {
    
    rmarkdown::render(input$"topografico_template",
                      output_format = "html_document",
                      output_file = paste0("topografico_casa_", input$lista_de_id), 
                      output_dir = paste0(getwd(),'/outputs'),
                      params = list(tab = tab_react(), casa = input$lista_de_id, V = V_react() )  )
  })
  
  output$preview_memorial <- renderUI({
      
      if(input$preview_memo){
            includeHTML( 
                file.path("C:/Users/cassiano/hubic/DABUKURI/Memorial_descritivo/Dabukuri_espacial/outputs", 
                          paste0("memorial_casa_",input$lista_de_id,".html") ) 
            )  }
  })
  
  output$preview_topografico <- renderUI({
      
      if(input$preview_topo){ 
            includeHTML( 
                file.path("C:/Users/cassiano/hubic/DABUKURI/Memorial_descritivo/Dabukuri_espacial/outputs/", 
                          paste0("topografico_casa_",input$lista_de_id,".html") ) 
            ) }
  })
  
  file_memo_html <- reactive({
      
  })
  
  output$loaded_memo_html <- renderUI({
      includeHTML()
  })
}

# C:/Users/cassiano/hubic/DABUKURI/Memorial_descritivo/Dabukuri_espacial/outputs/topografico_casa_4.html

# runApp('Dabukuri_espacial')

shinyApp( ui = ui, server = server, options = list(width = 100) )

# Run the application with themer
# run_with_themer( shinyApp( ui = ui, server = server, options = list(width = 100) ) )





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
