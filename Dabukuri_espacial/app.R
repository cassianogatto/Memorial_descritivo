#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(dplyr)
library(rmarkdown)
library(htmltools)

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("DABUKURI - Direito ao Território"),

    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        
        sidebarPanel( #width = '50px',
            
            # main table
            fileInput( inputId = "filetab",  label = "Selecione a tabela '.csv' ", accept = c(".csv"), #width = '500px', 
                       multiple=TRUE),
            # LOAD MAP!!!     /*
            actionButton("get_tab", "Carregar tabela!",  class = "btn-warning", color = 'black'), #class = "danger"),/8520
            
            textInput(inputId = "memorial_template",  label = "Nome do template Memorial", # accept = c(".Rmd"), 
                      value = 'teste.Rmd' #"C:/Users/HUMANITAS-FAPEAM - 4/Documents/Cassiano/Memorial_descritivo2/Memorial_descritivo/Dabukuri_espacial/memorial_template3_SHINY.Rmd"#width = '500px',  multiple=TRUE
            ),
            
            # textInput(inputId = "topographic_template",  label = "Nome do template '.Rmd' Topográfico", # accept = c(".Rmd"),
            #           value = 'topografico_template.Rmd', #width = '500px',  multiple=TRUE
            # ),
            
            numericInput(inputId = "lista_de_id", label = "Escolha a ID", value = 1),
            
            # get output folder -> uiOutput("output_folder"), etc etc  OR
            textInput(inputId = "output_dir", label = "Output Folder",
                      
                      value = "C:/Users/HUMANITAS-FAPEAM - 4/Documents/Cassiano/Memorial_descritivo2/outputs"),
            
            actionButton(inputId = "save_memorial", label = "Salve Memorial", class = "btn-warning", color = 'black'), 
            
            # include text in Rmd formal
            # htmltools::includeMarkdown('www/scan_eng_text1.Rmd')
            
        ),

        # Show a plot of the generated distribution
        mainPanel(
           
            tags$h3("Casa Selecionada:"), 
            
            tableOutput("V"),
            
            tags$h3("Output folder"),
            
            textOutput("getwd"),
            
            tags$h3("Tabela Geral"),
            
            tableOutput("tab"),
            
            # tags$h3("teste"),
            
            # tabPanel(value ='teste', title = "teste desse caralho", htmlOutput("report") ),
            
            # tags$h4("será que imprimiu?"),
            # 
            # textOutput("quando_imprime"),
            
            
            # example of tabPanel 
            # tabPanel(value ='tab3', title = "Summary Statistics", tab)            
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
    
    # output$statistics <- renderTable({ summary_statistics })
    
    tab_react <- eventReactive( input$get_tab, {
      
        tabdf <- input$filetab
        
        if(is.null(tabdf)){    return()    }
        
        previouswd <- getwd()
        
        uploaddirectory <- dirname(tabdf$datapath[1])
        
        setwd(uploaddirectory)
        
        for(i in 1:nrow(tabdf)){   file.rename(tabdf$datapath[i], tabdf$name[i])    }
        
        setwd(previouswd)
        
        tab <- read.csv(paste(uploaddirectory, tabdf$name[grep(pattern="*.csv$", tabdf$name)], sep="/" )) %>% as_tibble()
        
        tab <- tab %>% select(id, nome, cpf, rua, casa)
        
        tab
    
    })
    
    V_react <- reactive({
        
        V_cut <- which(tab_react()$id == input$lista_de_id)
        
        V <- tab_react() %>% slice(V_cut) %>% as.list()
    })
    
    output$tab <- renderTable({
        
        tab_react()
    })
    
    output$V <- renderTable(  V_react()  )
    
    output$getwd <- renderText( input$output_dir )
    
    # render vars
    output_file <- reactive ({

        paste0(input$output_dir ,"/Memorial_casa_", input$lista_de_id , ".html")

    }) #"C:/Users/HUMANITAS-FAPEAM - 4/Documents/Cassiano/Memorial_descritivo2/outputs"

    # quando_imprime <- eventReactive ("save_memorial", {
    # 
    #     render("memorial_template3_SHINY.Rmd", output_file = output_file(), params = c( V_react(), tab_react() ) )#, row_id)) # 'params' passes the objects to the .Rmd
    # 
    #     "imprimiu?"
    #     })
    # 
    # output$confirmation <- renderText( quando_imprime() )
    
    # 
    # getPage <- function(){
    # 
    #     return( includeHTML( paste0( input$output_dir ,"/Memorial_casa_", input$lista_de_id , ".html") ) )
    # }
    # 
    # output$report <- renderUI({getPage()})
    
    
    #https://joshlongbottom.github.io/Rendering-markdown/
    # tempReport <- file.path(tempdir(), "teste.rmd")
    # 
    # file.copy("teste.rmd", tempReport, overwrite = TRUE)
    # 
    # params <- list(stats_list = tab_react() )
    # 
    # eventReactive("save_memorial",{
    #         
    #     rmarkdown::render(tempReport, output_file = "teste_markdown.html", output_format = "html_document", 
    #                   
    #                   params =  params, 
    #                   
    #                   envir = globalenv())
    #     
    # })
    # 
    # getPage <- function(){
    #     
    #     return(includeHTML("teste_markdown.html"))
    # }
    # 
    # output$report <- renderUI({getPage()})
    
    
    
    # RENDER MARKDOWN TO OUTPUT FILE
    
    # rmarkdown::render("memorial_template3_SHINY.Rmd", output_file = output_file(), output_format = "html_document",
    #       # this is the 'trick' to read the global env (see https://joshlongbottom.github.io/Rendering-markdown/ )
    #       params = params, envir = globalenv()      )

    
    # original loop  as in Script_Memorial.R
    # for (i in lista_de_id ){
    #     
    #     row_id = which(tab$id == i)
    #     
    #     V <- tab %>% slice(row_id) %>% as.list()
    #     
    #     where_to_put <- "C:/Users/HUMANITAS-FAPEAM - 4/Documents/Cassiano/Memorial_descritivo2/outputs"
    #     
    #     output_file <- paste0(where_to_put,"/Memorial_casa_", i, ".html")
    #     
    #     output_file2 <- paste0(where_to_put,"/topografico_casa_", i, ".html")
    #     
    #     render("memorial_template3.Rmd", output_file = output_file, params = c(V, tab, row_id)) # 'params' passes the objects to the .Rmd
    #     
    #     render("topografico_template.Rmd" , output_file = output_file2, params = c(V, tab, row_id))
    #     
    #     cat(paste("Rendered", output_file, "\n"))
    #     
    #     cat(paste("Rendered", output_file2, "\n"))
    # }

}

# Run the application 
shinyApp(ui = ui, server = server)
