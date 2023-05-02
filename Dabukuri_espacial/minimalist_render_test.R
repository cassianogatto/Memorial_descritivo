library(shiny)
library(dplyr)
library(markdown)
library(knitr)



  
  ui = fluidPage(
    
    # inputs
    
    fileInput(inputId = "tab", "tabela da comunidade (csv)", accept = ".csv" ),
  
    numericInput(inputId = "casa", label = "número da casa", value = NULL),
    
    actionButton("get_html", "Imprime Memorial HTML"),
    
    # outputs
    
    tableOutput("tab_out"),
    
    tags$h3("aqui o html gerado:"),
    
    uiOutput("markdown"),
    
    
    # htmltools::includeMarkdown("r_markdown.Rmd"), # do not render R commands...
    
    htmlOutput("preview"),
    
    )
 
  
  
  server = function(input, output) {
    
    # reactive
    
    tab <- reactive({
      
      file <- input$tab
      
      ext <- tools::file_ext(file$datapath)
      
      req(file)
      
      validate(need(ext == "csv", "Please upload a csv file"))
      
      read.csv(file$datapath, header = TRUE) %>% as_tibble() %>% select(! contains('X'))
      
    })
    
    # outputs
    
    output$tab_out = renderTable({  tab() %>% slice(which(tab()$id == input$casa)) %>% as.list()   })
    
    
    
    # it renders to current directory and gives back the file path
    
    #observeEvent(input$render_html, {
      
    output$markdown <- renderUI({ 
      
      rmarkdown::render("r_markdown.Rmd", output_file = paste0("memorial_casa_", input$casa), # output_file = 'outputs',
                        params = list(tab = tab(), casa = input$casa))
    })

    output$preview <- renderUI({   
      
      #req( input$render_html )
      
      # tags$iframe(seamless="seamless", src=  paste0("memorial_casa_", input$casa,".html"), width=1000)
                                            
      includeHTML( paste0("memorial_casa_", input$casa,".html") )
    })
  }
  
shinyApp(ui,server,  options = list(height = 500))



  
# scritp original
# render("memorial_template3.Rmd", output_file = output_file, params = c(V, tab, row_id)) 

# from cursoR  -   https://github.com/curso-r/lives/blob/master/drafts/20210804-shiny-rmarkdown/rascunho/app.R

#  UI
# downloadButton("gerar_relatorio", "Gerar PDF"),

#  server
# output$gerar_relatorio <- downloadHandler(
#   filename = function() {
#     paste0("filmes_", input$pessoa, ".pdf")
#   },
#   content = function(file) {
#     rmarkdown::render(
#       input = "www/template.Rmd",
#       output_file = file,
#       params = list(pessoa = input$pessoa)
#     )
#   }
# )
