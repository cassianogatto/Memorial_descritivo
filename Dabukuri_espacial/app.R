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
                      value = 'memorial_template3.Rmd'#width = '500px',  multiple=TRUE
            ),
            
            textInput(inputId = "topographic_template",  label = "Nome do template '.Rmd' Topográfico", # accept = c(".Rmd"),
                      value = 'topografico_template.Rmd', #width = '500px',  multiple=TRUE
            ),
            
            numericInput(inputId = "lista_de_id", label = "Escolha a ID", value = 1),
            
            actionButton("save_memorial", "Salve Memorial", color = 'black'), 
            
            # include text in Rmd formal
            # htmltools::includeMarkdown('www/scan_eng_text1.Rmd')
            
            
            
            
            
            
        ),

        # Show a plot of the generated distribution
        mainPanel(
           
            tags$p("Casa Selecionada:"), 
            
            tableOutput("V"),
            
            tags$p("Output folder"),
            
            textOutput("getwd"),
            
            tags$p("Tabela Geral"),
            
            tableOutput("tab"),
            
            
            # example of tabPanel 
            # tabPanel(value ='tab3', title = "Summary Statistics", tab
            
            
            
            
            )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
    
    
    # output$statistics <- renderTable({ summary_statistics })
    
    
    # 
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
    
    output$getwd <- renderText( getwd())
    
    
    # render vars
    # where_to_put <- "C:/Users/HUMANITAS-FAPEAM - 4/Documents/Cassiano/Memorial_descritivo2/outputs"
    # 
    # output_file <- paste0(where_to_put,"/Memorial_casa_", i, ".html")
    # 
    # 
    # #  https://joshlongbottom.github.io/Rendering-markdown/
    # rmarkdown::render(tempReport, 
    #                   
    #                   output_file = paste0(tempdir(), "/populated_markdown.html"), 
    #                   
    #                   output_format = "html_document", 
    #                   
    #                   params = params, 
    #                   
    #                   envir = globalenv()
    #                   )
    
    
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



# CHAT GPT


