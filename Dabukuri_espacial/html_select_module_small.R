


select_html_ui <- function( id, type = '' , button_label = 'choose file', action_label = "Mostrar"){
    
    tagList(
        
        selectInput(NS(id,"memo"), label = button_label , choices = dir(path = "www", pattern = paste0(type, '_casa') ) ),
        
        textOutput(NS(id,'text')),
        
        actionButton(NS(id,"memo_but"), action_label),
       
        uiOutput(NS(id,"memo_out")),
    )
}


select_html_server <- function(id){
    
    moduleServer(id, function(input, output, session){
        
        output$text <- renderText( file.path(getwd(),'www', input$memo) )
        
        output$memo_out <- renderUI( if(input$memo_but) {  includeHTML( file.path(getwd(),'www', input$memo) )  })
    })
}


# this App is only for testing ... you have to call for UI(id) (or input(id) + output() ) functions and server (id) in your shiny app!

select_html_App <- function(){
    
    ui <- fluidPage(
        
        select_html_ui("select1")
    )
    
    server <- function(input, output, session) {
        
        select_html_server("select1")
    }
    
    shinyApp(ui,server)
}


select_html_App()


