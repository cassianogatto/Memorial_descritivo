'DABKURI'
# https://github.com/curso-r/lives/blob/master/drafts/20210804-shiny-rmarkdown/rascunho/app.R

# https://github.com/vnijs/shiny-site
# https://github.com/rstudio/shiny/issues/859
# https://stackoverflow.com/questions/56157839/rendering-html-outputs-from-r-markdown-in-shiny-app

library(shiny)
library(dplyr)
library(rmarkdown)
library(htmltools)
# library(knitr)

setwd("C:/Users/Cliente/Documents/Cassiano/Shiny/Memorial_markdown-shiny/Memorial_descritivo/Dabukuri_espacial/")


# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("DABUKURI - Direito ao Território"),

    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        
        sidebarPanel(
            
            # template
            selectInput(inputId = "Rmarkdown_template", label = "Arquivo markdown template", 
                        choices = dir()[dir() %>% grep(pattern = ".Rmd")],
                        selected = "template_memorial_4_SHINY.Rmd"),
            
            fileInput( inputId = "filetab",  label = "Selecione a tabela '.csv' ", accept = c(".csv"), multiple=TRUE), #width = '500px', 
                      
            numericInput(inputId = "lista_de_id", label = "Escolha a ID", value = NULL),

            # textInput(inputId = "output_dir", label = "Output Folder",  value = "C:/Users/HUMANITAS-FAPEAM - 4/Documents/Cassiano/Memorial_descritivo2/outputs"),

            HTML("<br>"),
            
            # Action !!
            actionButton(inputId = "save_memorial", label = "Salve Memorial", class = "btn-warning", color = 'black'),
            
            tags$code(
                tags$h3("o arquivo gerado está em:"),
                
                uiOutput("markdown"),
            ),
            # Download!!
            #downloadButton("download_html", label = "Download Memorial html"),
            
        ),

        # Show a plot of the generated distribution
        mainPanel(
           
            tags$h3("Casa Selecionada:"), tableOutput("V_tab"),
            
           
            
            #htmlOutput("preview"),
            
            tags$h3("Tabela Geral"),  tableOutput("tab"),
            
            # htmltools::includeMarkdown("r_markdown.Rmd"), # do not render R commands...
            
            # htmlOutput("preview"),
        )
    )
)

# Define server logic required to draw a histogram
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
    
    output$tab <- renderTable({  tab_react() %>% select(1:7) })
    
    output$V_tab <- renderTable(  tab_react() %>% select(1:7) %>% slice( which(tab_react()$id == input$lista_de_id) )  )

    # SALVE MEMORIAL
    
    output$markdown <- renderUI( {
      
      rmarkdown::render(input$"Rmarkdown_template",
                        output_format = "html_document",
                        output_file = paste0("topografico_casa_", input$lista_de_id), 
                        output_dir = paste0(getwd(),'/outputs'),
                        params = list(tab = tab_react(), casa = input$lista_de_id, V = V_react() )  )
    })
 
    # output$preview <- renderUI({   function(){  return( includeHTML( paste0( "memorial_casa_", input$casa,".html") ) )  } })
}

# Run the application 
shinyApp(ui = ui, server = server, options = list(width = 100))
    
    




# NOT WORKING
# output$download_html <- downloadHandler(
#   
#   filename = "teste_markdown_1.html",# function(){  paste0("render_memorial_Rmd_casa_", input$lista_de_id ) }, #output_file() , #  # function(Ncasa = input$lista_de_id) { paste0("memorial_casa", Ncasa, ".html")  },
#   
#   content = function( file ){
#     rmarkdown::render( "r_markdown.Rmd",
#                        output_file = file #, 
#                        # params = list( tabela = tab_react(), V = V_react(),  list_id = input$lista_de_id )
#     )
#   }
# )


# rmarkdown::render("r_markdown.Rmd", output_file = "teste_markdown_2.html", output_format = "html_document",
#                   
#                   params =  list(tabela = tab_react(), V = V_react(),  list_id = input$lista_de_id ) #,envir = globalenv()
# )



#https://joshlongbottom.github.io/Rendering-markdown/
# tempReport <- file.path(tempdir(), "teste.rmd")
# 
# file.copy("teste.rmd", tempReport, overwrite = TRUE)
# 
# params <- list(stats_list = tab_react() )
# 
# eventReactive("save_memorial", {
# 
#     rmarkdown::render(tempReport, output_file = "teste_markdown.html", output_format = "html_document",
# 
#                   params =  params ,   envir = globalenv() )
# })
# 
# getPage <- function(){ return(includeHTML("teste_markdown.html")) }
# 
# output$report <- renderUI({getPage()})
# 
# 
# 
# RENDER MARKDOWN TO OUTPUT FILE
# 
# rmarkdown::render("memorial_template3_SHINY.Rmd", output_file = output_file(), output_format = "html_document",
#       # this is the 'trick' to read the global env (see https://joshlongbottom.github.io/Rendering-markdown/ )
#       params = params, envir = globalenv()      )
# 
# 
# tabela_input_UI <- function(id){
#     
#     ns <- NS(id)
#     
#     tagList(
#         
#         fileInput( inputId = ns("filetab"),  label = "Selecione a tabela '.csv' ", accept = c(".csv"), multiple=TRUE),
#     
#         actionButton(inputId = ns("get_tab"), label =  "Carregar tabela!",  class = "btn-warning", color = 'black'),
# 
#         numericInput(inputId = ns("lista_de_id"), label = "Escolha a ID", value = 1),
#     )
# }
