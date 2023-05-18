
# https://stackoverflow.com/questions/24875943/display-html-file-in-shiny-app

ui <- fluidPage(
    htmlOutput("map")
)

addResourcePath("tmpuser", getwd())

server <- function(input,output){
    
    output$map <- renderUI({
        
        tags$iframe(seamless="seamless",  src= "tmpuser/memorial_casa_7.html",  width='1000', height='1300')
    })
}

shinyApp(ui, server)
