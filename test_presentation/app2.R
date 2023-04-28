library(shiny)

ui <- shinyUI(
    
    navbarPage(title = "Input",
        
        tabPanel("input tabela",
                 
            sidebarLayout(
                 
                sidebarPanel(
                     
                     fileInput( inputId = "filetab",  label = "Selecione a tabela '.csv' ", accept = c(".csv"), multiple=TRUE), #width = '500px', 
                     
                     numericInput(inputId = "lista_de_id", label = "Escolha a ID", value = 10),
                 ),
            
                mainPanel(
                     
                    tableOutput("V_tab"),
                
                    tableOutput("tab"),
                ),
            ),
        ),
            
        navbarMenu("View HTML",
                   
            tabPanel("Memorial",
             
                div(style = "border: 1px solid black;  max-width = 1000px;", 
                
                includeHTML('C:/Users/HUMANITAS-FAPEAM - 4/Documents/Cassiano/Memorial_descritivo2/outputs/Memorial_casa_102.html')
                
                ),     
             ),
            
            tabPanel("topográfico",
                    
                     div(style="height:600px; width:100%", includeHTML('C:/Users/HUMANITAS-FAPEAM - 4/Documents/Cassiano/Memorial_descritivo2/outputs/topografico_casa_102.html'))
            ),
        ),
        
        tabPanel("pdf - not working :-( ",
         
             uiOutput("pdfview")
         ),
    )
)

server <- function(input, output) { 
    
    tab_react <- reactive(  {
        
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
        
        req(tab_react)
        
        V_cut <- which(tab_react()$id == input$lista_de_id)
        
        V <- tab_react() %>% slice(V_cut) #%>% as.list()
    })
    
    output$tab <- renderTable(    tab_react()   )
    
    output$V_tab <- renderTable(    V_react()   )
    
    output$pdfview <- renderUI({   tags$iframe(#style="height:600px; width:100%", 
           
           src="www/Memorial_casa_15.pdf")    })
}

shinyApp(ui, server)
