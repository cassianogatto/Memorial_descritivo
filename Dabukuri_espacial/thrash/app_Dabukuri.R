

library(shiny)
library(bslib)

# https://appsilon.com/r-shiny-bslib/
custom_theme <- bs_theme(
    version = 5,    bg = "#FFFFFF",    fg = "#000000",    primary = "#0199F8",
    secondary = "#FF374B",    base_font = "Maven Pro"
)


ui <- navbarPage(
    
    theme = bs_theme(version = 5, bootswatch = "lumen"),#custom_theme,
    
    title = "DABUKURI - Direito ao Território", collapsible = TRUE, 
    
    tabPanel("Comunidade",
             
             fluidPage(
                 theme = bs_theme(version = 5, bootswatch = "lumen"),
                 fluidRow(
                     
                    column(4,

                        fileInput( inputId = "filetab",  label = "Comunidade (tabela '.csv') ", accept = c(".csv"), multiple=TRUE),
                        
                        selectInput(inputId = "memorial_template", label = "Arquivo markdown template", 
                                       choices = dir()[dir() %>% grep(pattern = ".Rmd")],
                                       selected = "template_memorial_4_SHINY.Rmd"),
                            
                        selectInput(inputId = "topografico_template", label = "Topográfico template", 
                                       choices = dir()[dir() %>% grep(pattern = ".Rmd")],
                                       selected = "topografico_template.Rmd"),
                    ),
           
                    column(8,
                           
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
                      
                      htmlOutput("preview")
          ),
            
          tabPanel("Topográfico",
                      
                      tags$h3("o arquivo gerado está em:"),
                      
                      uiOutput("markdown_topografico"),
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
  
  output$V_tab <- renderTable(  tab_react() %>% select(1:12) %>% slice( which(tab_react()$id == input$lista_de_id) )  )
  
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
  
  # output$preview <- renderUI({   function(){  return( includeHTML( paste0( "memorial_casa_", input$casa,".html") ) )  } })
}


shinyApp(ui = ui, server = server, options = list(width = 100))

# Run the application with themer 
# run_with_themer( shinyApp( ui = ui, server = server, options = list(width = 100) ) )
