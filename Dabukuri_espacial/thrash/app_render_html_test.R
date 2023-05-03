library(shiny)
library(knitr)
library(htmltools)

ui <- shinyUI(
    
    fluidPage(
       
        # load main table
        fileInput( inputId = "filetab",  label = "Selecione a tabela '.csv' ", accept = c(".csv"), multiple=TRUE), #width = '500px', 
        
        actionButton(inputId = "get_tab", label =  "Carregar tabela!",  class = "btn-warning", color = 'black'), #class = "danger"),/8520
        
        numericInput(inputId = "lista_de_id", label = "Escolha a ID", value = 10),
        
        actionButton(inputId = "save_memorial", label = "Salve Memorial", class = "btn-warning", color = 'black'),
        
        textOutput("save_memorial"),
        
        # check tabela
        tableOutput("V_tab"),
        
        tags$h3("Output folder"),
        
        textOutput("getwd"),
        
        tags$h3("Tabela Geral"),
        
        tableOutput("tab"),
        
        # print rendered html
        uiOutput('markdown')
        
        # tabPanel( value ='html_view', title = "Memorial_html", htmlOutput("html_doc") )
    )
)

server <- function(input, output) {
    
    # load the table
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
        
        V <- tab_react() %>% slice(V_cut) #%>% as.list()
    })    
    
    # outputs
    output$tab <- renderTable({
        
        tab_react()
    })
    
    output$V_tab <- renderTable(  V_react()  )
    
    output$save_memorial <- renderText( paste("eitaa", input$save_memorial ) )
    
    
    # https://joshlongbottom.github.io/Rendering-markdown/
    #save tab to params list to be passed to rmarkdown template
    # params <- reactiveValues( tabela = tab_react(), V = V_tab() ) 
    
    # render huml UI
    # output$markdown <- renderUI({   HTML(markdown::markdownToHTML(knit('r_markdown.Rmd', quiet = TRUE)))    })
    
    # eventReactive(input$save_memorial,{
    #                 rmarkdown::render(tempReport, #,#tempReport,
    #                       output_file = "C:/Users/HUMANITAS-FAPEAM%20-%204/Documents/Cassiano/Memorial_descritivo2/Memorial_descritivo/Dabukuri_espacial/test_output_markdown.html", # paste0(tempdir(), "/test_output_markdown.html"),
    #                       output_format = "html_document",
    #                       params = params(),
    #                       envir = globalenv() 
    #                 )
    #  })
    # 
    # render("memorial_template3_SHINY.Rmd", output_file = "C:/Users/HUMANITAS-FAPEAM%20-%204/Documents/Cassiano/Memorial_descritivo2/Memorial_descritivo/Dabukuri_espacial/test_output_markdown.html", # paste0(tempdir(), "/test_output_markdown.html"),
    #        params = c(params$V_react, params$tab_react, input$lista_de_id))
    
    
    
    # render html 
    # getPage <- function(){    return(includeHTML(paste0(tempdir(), "/test_output_markdown.html")))   }
    # 
    # output$html_doc <- renderUI({getPage()})
    
    
    
    # # save Rmd template to a temporary folder
    # tempReport <- file.path(tempdir(), "r_markdown.Rmd") 
    # 
    # file.copy("r_markdown.Rmd", tempReport, overwrite = TRUE)
}

shinyApp(ui, server)