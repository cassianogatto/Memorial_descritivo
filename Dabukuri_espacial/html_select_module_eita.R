


select_html_ui <- function( id ){
    
    tagList(
        
        selectInput(NS(id,"memo"), "Memorial", choices = dir(path = "www", pattern = 'memorial_casa') ),
        
        textOutput(NS(id,'texto')),
        
        actionButton(NS(id,"memo_but"), "view memo"),
       
        uiOutput(NS(id,"memo_out")),
        
        selectInput(NS(id,"topo"), "Topografico", choices = dir(path = 'www', pattern = 'topografico_casa') ),
        
        actionButton(NS(id,"topo_but"), "view topo"),
        
        uiOutput(NS(id, "topo_out")),
    )
}

select_html_server <- function(id){
    
    moduleServer(id, function(input, output, session){
        
        output$texto <- renderText( file.path(getwd(),'www', input$memo) )
        
        output$memo_out <- renderUI( if(input$memo_but) {  includeHTML( file.path(getwd(),'www', input$memo) )  })
        
        output$topo_out <- renderUI( if (input$topo_but) { includeHTML( file.path(getwd(),'www', input$topo) )  })
    })
}

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
