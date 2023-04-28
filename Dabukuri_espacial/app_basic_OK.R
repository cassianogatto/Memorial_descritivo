'DABKURI'
# https://github.com/curso-r/lives/blob/master/drafts/20210804-shiny-rmarkdown/rascunho/app.R

# https://github.com/vnijs/shiny-site
# https://github.com/rstudio/shiny/issues/859
# https://stackoverflow.com/questions/56157839/rendering-html-outputs-from-r-markdown-in-shiny-app

library(shiny)
library(dplyr)
library(rmarkdown)
library(htmltools)
library(knitr)

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
                      
            numericInput(inputId = "lista_de_id", label = "Escolha a ID", value = 1),

            # textInput(inputId = "output_dir", label = "Output Folder",  value = "C:/Users/HUMANITAS-FAPEAM - 4/Documents/Cassiano/Memorial_descritivo2/outputs"),

            
            HTML("<br>"),
            
            # Action !!
            actionButton(inputId = "save_memorial", label = "Salve Memorial", class = "btn-warning", color = 'black'),
            
            # Download!!
            downloadButton("download_html", label = "Download Memorial html"),
            
        ),

        # Show a plot of the generated distribution
        mainPanel(
           
            tags$h3("Casa Selecionada:"), tableOutput("V_tab"),

            tags$h3("Output folder"), textOutput("getwd"),

            tags$h3("Tabela Geral"),  tableOutput("tab"),
            
            uiOutput("markdown"),
            
            htmltools::includeMarkdown("r_markdown.Rmd"), # do not render R commands...
            
            htmlOutput("report"),
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output, session) {
    
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
        
        req(tab_react())
        
        V_cut <- which(tab_react()$id == input$lista_de_id)
        
        V <- tab_react() %>% slice(V_cut) #%>% as.list()
    })
    
    output$tab <- renderTable({  tab_react()  })
    
    output$V_tab <- renderTable(  V_react()   )
    
    output$markdown <- renderUI({
        HTML(markdown::markdownToHTML(knit('r_markdown.Rmd', quiet = TRUE)))
    })
    
    # NOT WORKING
    output$download_html <- downloadHandler(
        
        filename = "teste_markdown_1.html",# function(){  paste0("render_memorial_Rmd_casa_", input$lista_de_id ) }, #output_file() , #  # function(Ncasa = input$lista_de_id) { paste0("memorial_casa", Ncasa, ".html")  },
        
        content = function( file ){
            rmarkdown::render( "r_markdown.Rmd",
                output_file = file #, 
                # params = list( tabela = tab_react(), V = V_react(),  list_id = input$lista_de_id )
            )
        }
    )
    
    # NOT WORKING
    eventReactive("save_memorial", {
        
        rmarkdown::render("r_markdown.Rmd", output_file = "teste_markdown_2.html", output_format = "html_document",

              params =  list(tabela = tab_react(), V = V_react(),  list_id = input$lista_de_id ) #,envir = globalenv()
        )
    })
    
    output$report <- renderUI({   function(){  return( includeHTML( paste0( "teste_markdown_2.html") ) )  } })
    
}

# Run the application 
shinyApp(ui = ui, server = server)
    
    








    #https://joshlongbottom.github.io/Rendering-markdown/
    # tempReport <- file.path(tempdir(), "teste.rmd")
    # 
    # file.copy("teste.rmd", tempReport, overwrite = TRUE)
    # 
    # params <- list(stats_list = tab_react() )
    # 
    # eventReactive("save_memorial", {
    # 
    #     rmarkdown::render(tempReport, output_file = "teste_markdown.html", output_format = "html_document",
    # 
    #                   params =  params ,   envir = globalenv() )
    # })
    
    # getPage <- function(){ return(includeHTML("teste_markdown.html")) }
    
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
