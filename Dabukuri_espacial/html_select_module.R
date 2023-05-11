#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("HTML TESTE"),

    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
            
            selectInput("memo", "Memorial", choices = dir(path = "www", pattern = 'memorial_casa') ),
            
            selectInput("topo", "Topografico", choices = dir(path = 'www', pattern = 'topografico_casa') ),
        ),

        # Show a plot of the generated distribution
        mainPanel(
            
            
            fluidRow(
                
                textOutput('texto'),
                
                uiOutput("memo_out"),
                
                uiOutput("topo_out")
                  
            )
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {

    output$texto <- renderText(
        
        file.path(getwd(),'www', input$memo)
    )
    
    output$memo_out <- renderUI({
           
            includeHTML( 
                    file.path(getwd(),'www', input$memo)
                )  
    })
    
    output$topo_out <- renderUI({
        
            includeHTML( 
                    file.path(getwd(),'www', input$topo)
            ) 
    })
    
}

# Run the application 
shinyApp(ui = ui, server = server)
