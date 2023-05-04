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
    
    tabPanel("Comunidade", icon = tags$img( src = "DABUKURI.jpg" ),
             
        fluidPage(
           
            theme = bs_theme(version = 5, bootswatch = "lumen"),
             
            fluidRow(
                 
                column(4,
                       
                    radioButtons('comunidade', 'Escolha a comunidade', c('Kokama', 'Ipixuna'), inline = TRUE),

                    fileInput( inputId = "filetab",  label = "Comunidade (tabela '.csv') ", accept = c(".csv"), multiple=TRUE),
                    
                    selectInput(inputId = "memorial_template", label = "Arquivo markdown template", 
                                   choices = dir()[dir() %>% grep(pattern = ".Rmd")],
                                   selected = "template_memorial_4_SHINY.Rmd"),
                        
                    selectInput(inputId = "topografico_template", label = "Topográfico template", 
                                   choices = dir()[dir() %>% grep(pattern = ".Rmd")],
                                   selected = "topografico_template.Rmd"),
                ),
       
                column(8,
                       
                    uiOutput("comunidade_intro"),
                    
                    tags$img( src = "www/ipixuna_satelite.png" ),
                       
                    tags$h3("Tabela Geral"),  tableOutput("tab"),
                ),
             )
         ),
             

    ),
  
    tabPanel("Dados",
           
            numericInput(inputId = "lista_de_id", label = "Escolha a ID", value = NULL),
            
            tags$h3("Casa Selecionada:"), tableOutput("V_tab"),
   ),
    navbarMenu("Documentos",
             
          tabPanel("Memorial",
                    
                    tags$h3("o arquivo gerado está em:"),
                        
                    uiOutput("markdown_memorial"),

                    tags$h4("preview:"),
                    
                    #includeHTML("C:/Users/Cliente/Documents/Cassiano/Shiny/Memorial_markdown-shiny/Memorial_descritivo/Dabukuri_espacial/outputs/memorial_casa_55.html"),
                      
                    htmlOutput("preview_memorial")
          ),
            
          tabPanel("Topográfico",
                      
                    tags$h3("o arquivo gerado está em:"),
                      
                    uiOutput("markdown_topografico"),
                    
                    tags$h4("preview:"),
                   
                    htmlOutput("preview_topografico")
          ),
  )
)

server <- function(input, output, session) {
  
  tab_react <- reactive(  {
    
    file <- input$filetab
    
    ext <- tools::file_ext(file$datapath)
    
    req(file)
    
    validate(need(ext == "csv", "Please upload a csv file"))
    
    read.csv(file$datapath, header = TRUE) %>% as_tibble() %>% select(! contains('X'))
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
  
  # works only with the character for the whole file path... trying to make the paste0 works... it never ends...
  output$preview_memorial <- renderUI({  includeHTML( 
      
      #paste0(getwd(),"/outputs/memorial_casa_", input$lista_de_id) 
      
      "C:/Users/Cliente/Documents/Cassiano/Shiny/Memorial_markdown-shiny/Memorial_descritivo/Dabukuri_espacial/outputs/memorial_casa_56.html"
      
      ) })   # "C:/Users/Cliente/Documents/Cassiano/Shiny/Memorial_markdown-shiny/Memorial_descritivo/Dabukuri_espacial/outputs/memorial_casa_55.html" )

  
  output$preview_topografico <- renderUI({  includeHTML( paste0(getwd(),"/outputs/topografico_casa_", input$lista_de_id) ) })
  
}


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
