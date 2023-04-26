'DABKURI'
# https://github.com/curso-r/lives/blob/master/drafts/20210804-shiny-rmarkdown/rascunho/app.R

# https://github.com/vnijs/shiny-site
# https://github.com/rstudio/shiny/issues/859
# https://stackoverflow.com/questions/56157839/rendering-html-outputs-from-r-markdown-in-shiny-app

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
            
            # template
            textInput( inputId = "memorial_template",  label = "Nome do template Memorial", value = 'teste.Rmd' ),
            
            # main table
            fileInput( inputId = "filetab",  label = "Selecione a tabela '.csv' ", accept = c(".csv"), multiple=TRUE), #width = '500px', 
                      
            actionButton(inputId = "get_tab", label =  "Carregar tabela!",  class = "btn-warning", color = 'black'), #class = "danger"),/8520
            
             # accept = c(".Rmd"),  #"C:/Users/HUMANITAS-FAPEAM - 4/Documents/Cassiano/Memorial_descritivo2/Memorial_descritivo/Dabukuri_espacial/memorial_template3_SHINY.Rmd"#width = '500px',  multiple=TRUE

            # textInput(inputId = "topographic_template",  label = "Nome do template '.Rmd' Topográfico", # accept = c(".Rmd"),
            #           value = 'topografico_template.Rmd', #width = '500px',  multiple=TRUE
            # ),

            numericInput(inputId = "lista_de_id", label = "Escolha a ID", value = 1),

            
            # get output folder -> uiOutput("output_folder"), etc etc  OR
            textInput(inputId = "output_dir", label = "Output Folder",  value = "C:/Users/HUMANITAS-FAPEAM - 4/Documents/Cassiano/Memorial_descritivo2/outputs"),

            actionButton(inputId = "save_memorial", label = "Salve Memorial", class = "btn-warning", color = 'black'),
            
            downloadButton("download_html", label = "Download Memorial html"),
            
        ),

        # Show a plot of the generated distribution
        mainPanel(
           
            tags$h3("Casa Selecionada:"),

            tableOutput("V_tab"),

            tags$h3("Output folder"),

            textOutput("getwd"),

            tags$h3("Tabela Geral"),

            tableOutput("tab"),
            
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
        
        V <- tab_react() %>% slice(V_cut) #%>% as.list()
    })
    
    output$tab <- renderTable({
        
        tab_react()
    })
    
    output$V_tab <- renderTable(  V_react()  )

    output$getwd <- renderText( input$output_dir )

    # render vars
    output_file <- reactive ({   paste0(input$output_dir ,"/Memorial_casa_", input$lista_de_id , ".html")   }) #"C:/Users/HUMANITAS-FAPEAM - 4/Documents/Cassiano/Memorial_descritivo2/outputs"

    output$download_html <- downloadHandler(
        filename = output_file() , # "teste_memorial_markdown", # function() { paste0("memorial_casa", input$lista_de_id, ".html")  },
        content = function( file ){
                rmarkdown::render(
                    input = "www/memorial_template3_SHINY.Rmd",
                    output_file = file,
                    params = list(tabela = tab_react(), V = v_react(),  list_id = input$lista_de_id )
            )
        }
    )
    
    eventReactive("save_memorial",{
        rmarkdown::render(tempReport, output_file = "teste_markdown.html", output_format = "html_document",

                          params =  params,

                          envir = globalenv())

        })
    
}

# Run the application 
shinyApp(ui = ui, server = server)
    
    # https://github.com/curso-r/lives/blob/master/drafts/20210804-shiny-rmarkdown/rascunho/app.R
    # output$gerar_relatorio <- downloadHandler(  
            # filename = function() {  paste0("filmes_", input$pessoa, ".pdf")  },
            #content = function(file) {    
                # rmarkdown::render(    input = "www/template.Rmd",   output_file = file,    params = list(pessoa = input$pessoa)  )  })
    
    
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
# 
# tabela_input_server <- function(){
#     moduleServer(
#         id,
#         function(input, output, session){
#             tab_react <- eventReactive( input$get_tab, {
#                 
#                 tabdf <- input$filetab
#                 
#                 if(is.null(tabdf)){    return()    }
#                 
#                 previouswd <- getwd()
#                 
#                 uploaddirectory <- dirname(tabdf$datapath[1])
#                 
#                 setwd(uploaddirectory)
#                 
#                 for(i in 1:nrow(tabdf)){   file.rename(tabdf$datapath[i], tabdf$name[i])    }
#                 
#                 setwd(previouswd)
#                 
#                 tab <- read.csv(paste(uploaddirectory, tabdf$name[grep(pattern="*.csv$", tabdf$name)], sep="/" )) %>% as_tibble()
#                 
#                 tab <- tab %>% select(id, nome, cpf, rua, casa)
#                 
#             })
#             
#             V_react <- reactive({
#                 V_cut <- which(tab_react()$id == input$lista_de_id)
#                 
#                 V <- tab_react() %>% slice(V_cut) #%>% as.list()
#             })
#             
#             output$tab <- renderTable({  tab_react()     })
#             
#             output$V_tab <- renderTable( { V_react() } )
#             
#         }
#     )
# }
