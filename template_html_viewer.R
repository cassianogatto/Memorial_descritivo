
# https://stackoverflow.com/questions/24875943/display-html-file-in-shiny-app

ui <- fluidPage(
    
    
    
    htmlOutput("map")
)

addResourcePath("tmpuser", getwd())

server <- function(input,output){
    
    path = "tmpuser/www/memorial_casa_7.html"
    
    output$map <- renderUI({
        
        tags$iframe(seamless="seamless",  src= path,  width='1000', height='1300')
    })
}

shinyApp(ui, server)


# tags$iframe( onload= "this.contentWindow.document.documentElement.scrollLeft=820; this.contentWindow.document.documentElement.scrollTop=400" )