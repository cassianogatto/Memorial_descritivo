library(shiny)
library(bslib)
library(tidyverse)
library(DT)
# source("html_select_module_small.R")

# https://appsilon.com/r-shiny-bslib/
custom_theme <- bs_theme(
    version = 5,    bg = "#FFFFFF",    fg = "#000000",    primary = "#0199F8",
    secondary = "#FF374B",    base_font = "Maven Pro"
)

# NÃO ESQUEÇA DE SETWD()!!
# setwd("C:/Users/Cliente/Documents/Cassiano/Shiny/Memorial_markdown-shiny/Memorial_descritivo/Dabukuri_espacial")


# UI -----
ui <- 
    # CSS head ----
    tagList(tags$head(tags$style(HTML(" 
              
       body{
          align: center;
          text-size:12px;
          margin: 0px;
          padding:20px;
          width: auto; 
          height: auto;
      }
      
      @media print {
          @page { size: A4;}
      }
      
      .container {
          align-items: center;
          justify-content: center 
          display: flex;
          column-gap: 5px;
          width: 209mm;
          margin: 2px;
          padding: 2px;
          <!-- height: 297mm; -->
          <!-- border: 0.2px solid blue; -->
      }       
    
    " ) ) ),
    
    navbarPage(position = 'fixed-top', 

        title = "DABUKURI - Direito ao Território", collapsible = TRUE,
    
        theme = bs_theme(version = 5, bootswatch = "flatly"),
        
        # apresentação ----
        tabPanel("Apresentação",
                 
                 fluidRow(  column(2),  column(8, includeMarkdown("instrucoes.Rmd")  ), column(2),  )
        ),
        
        # comunidade ----
        
        tabPanel("Comunidade",
                 
                tags$h3("Tabela dos dados da comunidade"),
                
                tags$h5("Aqui você pode visualizar toda a comunidade e selecionar, uma à uma, casas para criar o Memorial Descritivo e o Levantamento Topográfico na próxima aba de 'Dados individuais'"),
                
                br(),
                 
                fluidRow( # theme = bs_theme(version = 5, bootswatch = "flatly"),
                    
                    column( width =2,
                            
                        div(class = "card", style = "padding:10px;",
                         
                            div( 
                                
                                img(width = "80px", align = "left", src = "DABUKURI.png" ), 
                                                    
                                img(width = "80px", align = "right", src = "COPIME.png" )),
                            
                            radioButtons('comunidade', 'Escolha a comunidade', c('Kokama', 'Ipixuna'), inline = TRUE),
                    )),
                     
                    column(width = 10,
                           
                       div(class = "card", style = "padding:10px;",
                           
                           uiOutput("comunidade_intro")
                       ),
                      
                    ),
                ),
                
                br(),
                
                checkboxInput("box_select_tab","Prefer escolher a tabela com os dados da comunidade?", value = FALSE),
                
                conditionalPanel(condition = "input.box_select_tab == true",
                                 
                                 fileInput( inputId = "filetab",  label = "Comunidade (tabela '.csv') ", accept = c(".csv"), multiple=TRUE),
                ),
                
                fluidPage(
                    
                    fluidRow(
                        
                        column(3, actionButton('fake', "Selecione apenas UMA casa na tabela abaixo", class = 'btn-primary btn-lg' ), ),
                            
                        column(2, actionButton('clear1', 'Apague a(s) seleção(ôes) aqui', class = 'btn-secondary btn-lg' ), ),
                    ),
                    
                    hr(),
                    
                    div(style = "font-size: 70%;  height: 10px; white-space: nowrap;", 
                        
                        DTOutput("tab")), 
                )
        ),
        
        
        
        # dados individuais ----
        tabPanel("Dados individuais",
                 
                tags$h3("Dados individuais de cada terreno"),
                
                tags$h5("Aqui você pode conferir os detalhes de lotes individuais e criar o Memorial Descritivo e o Levantamento Topográfico."),
                
                HTML("<br>"),
                
                textOutput("casa_selecionada") ,
                
                div(#style = "font-size: 90%; height: 10px; white-space: nowrap;", 
                    
                    DTOutput("V_tab"),
                ),
                
                HTML("<br>"),
                
                checkboxInput('select_por_id',"Mas, se preferir, pode escolher pela ID...", value = FALSE),
                
                conditionalPanel(condition = 'input.select_por_id == true',
                                 
                            numericInput(inputId = "lista_de_id", label = "Escolha a ID", value = NULL), # selectInput('coluna_select', 'Selecione o critério de escolha', choices = c("ID", "nome", "cpf", "endereço")),
                ),
                
                
                fluidRow(
                    
                    column(8,
                           
                        fluidRow(
                    
                            column(5, p("Posição do terreno na comunidade"),  imageOutput("inset")  ),
                    
                            column(5,  p('Esquema do terreno'), imageOutput("image") ),
                        ),    
                    ),
                ),
                
                br(),
                
                tags$code(style = "font-size:18px ", "Use os botôes pra gerar os docs baseados nos templates base para Memoriais e Levantamentos Topográficos."),
                
                HTML("<br>"),
                
                tags$code(style = "font-size:18px ", "Os documentos gerados estarão disponíveis nos respectivos links 
                                            e poderão ser abertos no seu browser, ou na aba 'Visualização' deste App"),
                
                HTML("<br>"),
                
                checkboxInput('input_templates',"Escolher outros templates?", value = FALSE),
                
                conditionalPanel( condition = "input.input_templates == true",
                    
                    tags$h5("Após selecionar os templates gere os documentos e verifique o link."),
                    
                    fluidRow(
                        column(6,     selectInput(inputId = "memorial_template", label = "Arquivo memorial template", 
                                           choices = dir()[dir() %>% grep(pattern =  "*template_memorial*")],
                                           selected = "template_memorial_6.Rmd"),
                        ),
                        column(6,    selectInput(inputId = "topografico_template", label = "Topográfico template", 
                                               choices = dir()[dir() %>% grep(pattern = "*template_topografico*")],
                                               selected = "topografico_template1.Rmd"),
                        ),
                    ),
                ),
                
                fluidRow(
                    
                    div(class = 'container',
                        
                        column(6,    actionButton('get_memorial',"gerar memorial"),
                               
                               tags$h3("o arquivo Memorial gerado está em:"),
                               
                               uiOutput("markdown_memorial"),
                        )),
                    
                    div(class = 'container',
                        
                        column(6,  actionButton("get_topografico","gerar topografico"),
                               
                               tags$h3("o arquivo Topográfico gerado está em:"),
                               
                               uiOutput("markdown_topografico"),
                        )),
                ),
        ),
        
        # visualização ----
        navbarMenu("Visualização",
        
                tabPanel("Memorial",
                         
                        tags$h5("Para imprimir abra o endereço gerado na aba anterior ('C:/.../www/memorial_casa_X.html') no seu browser e 'imprima' em PDF (ctrl P)."),
                        
                        br(),
                        tags$code(tags$strong("Se desejar consultar para outra casa, clique e escolha na pasta /www; se não encontar tente gerá-lo na aba 'Dados Individuais'")),
                        
                        checkboxInput("another_memo", "escolha casa ID", value = FALSE),
                        
                        conditionalPanel(condition = 'input.another_memo == true',
                                         
                                         numericInput("another_memo_number","Escolha outra casa ID", value = NULL),
                        ),
                        
                        uiOutput("file_memo_html") ,
                ),
                
                tabPanel("Topografico",
                         
                        tags$h5("Para imprimir abra o endereço gerado na aba anterior ('C:/.../www/memorial_casa_X.html') no seu browser e 'imprima' em PDF (ctrl P)."),
                        br(),
                        tags$code("Se desejar consultar para outra casa, clique e escolha na pasta /www; se não encontar tente gerá-lo na aba 'Dados Individuais'"),
                        
                        checkboxInput("another_topo", "escolha casa ID", value = FALSE),
                        
                        conditionalPanel(condition = 'input.another_topo == true',
                                      
                                numericInput("another_topo_number","Escolha outra casa ID", value = NULL),
                        ),
                         
                        uiOutput("file_topo_html") ,
                         
                 ),
        ),
        
        # editor ----
        
        tabPanel("Editor",
            
            fluidRow(
                column(3,   
                       fileInput("upload", "Choose CSV File", multiple = FALSE,
                              accept = c("text/csv", "text/comma-separated-values,text/plain", ".csv")),
                ),
                column(4,   
                       tags$h5("tabela em edição:"),  
                       
                       style = "font-size: 26px", textOutput("tab2_name"), 
                       
                ),
                column(3,  
                       tags$h5( style = "color:red", "Salve as suas modificações na tabela!" ),
                       
                       downloadButton('download', class = 'btn-danger'),
                ),
            ),  
            
            textOutput('proxy'),
            
            div(style = "font-size: 70%;  height: 10px; white-space: nowrap;", DTOutput('tab2') )
        ),
    )
)

# ADD PATH to Viewer
addResourcePath("tmpuser", getwd())

# SERVER -----
server <- function(input, output, session) {
    
    options(shiny.maxRequestSize=1000*1024^2) # this is required for uploading large files.
    
    options(DT.options = list(pageLength = 50, lineHeight='70%', columnDefs = list( list( targets = 2, width = '400px' ) ) ))
    
    react_list <- reactiveValues(selec = NULL) # I could have used input$tab_rows_selected as in V_tab but this is an option to store the reactive value as well, and can be expanded to encompass other values
    
    observe(  
        
        if( input$select_por_id ){ react_list$selec <- input$lista_de_id  } else { react_list$selec <- V_react()$id[1]  } )
    
    tab_react <- reactive(  {
        
        if(input$box_select_tab){
            
            file <- input$filetab
            
            ext <- tools::file_ext(file$datapath)
            
            req(file)
            
            validate(need(ext == "csv", "Please upload a csv file"))
            
            tab <- read.csv(file$datapath, check.names = F, header = TRUE) %>% as_tibble()
            
            if('comunidade' %in% names(tab)) tab <- tab %>% filter(comunidade == input$comunidade)
            
        } else {
            
            # ipixuna5.csv is NOT WORKING figure out what is going on!!!!!!!!!
            
            switch(input$comunidade, Kokama = read.csv("TAB_Kokama9.csv", check.names = F), Ipixuna = read.csv("Ipixuna5.csv",  header = TRUE)) # cannot use row.names = F for Ipixuna! only ??!!
            
        }
    }  )
    
    V_react <- reactive(  {
        
        req( tab_react() )
        
        if(input$select_por_id){ row_slice <- which( tab_react()[,"id"] == input$lista_de_id ) } else { row_slice <- input$tab_rows_selected[1] }
            
        # col <- which( names( tab_react() == input$coluna_select ) )
        # row_slice <- which( tab_react()[,col] == input$lista_de_id )
        
        V <- tab_react() %>% slice( row_slice )  %>% select(id, nome, cpf, rua, casa, dist_frente, dist_lateral, escala, observacoes, area, perim, everything())
    
    }  )
    
    output$comunidade_intro <- renderUI( { includeMarkdown( switch(input$comunidade, Kokama = "www/kokama_intro.Rmd", Ipixuna = "www/ipixuna_intro.Rmd") ) })
    
    # RESET not working anymore... :-(
    output$tab <- renderDT(  tab_react(), editable = 'cell', server = TRUE,
                             
                              options = list( selection = 'single', autoWidth = TRUE, # scrollX = TRUE,
                                         
                                        pageLength = 50, columnDefs = list(list( targets = 2, width = '400px' ) ) 
                 ) )
    
    # manipulating  DT tab
    proxy = dataTableProxy('tab')
    
    # reset selection is NOT WORKING anymore!!!!
    observeEvent( input$clear1, {    proxy %>% selectRows(NULL)    } )
    
    output$casa_selecionada <- renderText( paste("linha da tabela selecionada:", input$tab_rows_selected, ";  ID casa selecionada:", V_react()$id) )
    
    output$V_tab <- renderDT(   V_react(), 
                                options = list( selection = 'single', autoWidth = TRUE, # scrollX = TRUE,
                                    pageLength = 50, columnDefs = list(list( targets = 2, width = '400px' ) ) )
     )
    
    output$inset <- renderImage( {
        
            file1 <- normalizePath(file.path( './figures/inset', paste("inset__", react_list$selec, ".png", sep = '')))
        
                # normalizePath(file.path( './figures', paste0("casa___",input$lista_de_id, ".png")))
            
            list(src = file1, width = '500px')
            
    },   deleteFile = FALSE )
            
    output$image <- renderImage( {
    
            file2 <- normalizePath(file.path( './figures', paste0("casa___", react_list$selec, ".png")))
            
            list(src = file2, width = '500px')
    
    },   deleteFile = FALSE )

# SALVE MEMORIAL E TOPOGRAFICO
    
    output$markdown_memorial <- renderUI(  {
            
            req( input$get_memorial)
        
            rmarkdown::render(input$"memorial_template",
                      output_format = "html_document",
                      output_file = paste0("memorial_casa_", react_list$selec), 
                      output_dir = paste0(getwd(),'/www'),
                      
                      # params passed to the template !!
                      params = list(tab = tab_react(), casa = react_list$selec, V = V_react() )  )
    } )
    
    output$markdown_topografico <- renderUI(  {
            
            req(input$get_topografico)
            
            rmarkdown::render(input$"topografico_template",
                      output_format = "html_document",
                      output_file = paste0("topografico_casa_", react_list$selec), 
                      output_dir = paste0(getwd(),'/www'),
                      params = list(tab = tab_react(), casa = react_list$selec, V = V_react() )  )
    } )
    
# LOAD HTML MEMORIAL E TOPOGRAFICO
    
    output$file_memo_html <- renderUI( {
        # using includeHTML does mess up all CSS configuration of the whole shiny app after reading html with <head>... tags$iframe fixes it but requires (?) addResourcePath
        # file <- input$file_html
        # includeHTML( file$datapath )
        
        if(input$another_memo){
            
            path = paste0("tmpuser/www/memorial_casa_", input$another_memo_number, ".html")
        
            tags$iframe(seamless="seamless",  src= path,  width='1000', height='1300')
            
        } else {
            
            path = paste0("tmpuser/www/memorial_casa_", react_list$selec, ".html")
            
            tags$iframe(seamless="seamless",  src= path,  width='1000', height='1300')
        }
    })

    output$file_topo_html <- renderUI( {
        
        if(input$another_topo){
            
            path = paste0("tmpuser/www/topografico_casa_", input$another_topo_number, ".html")
            
            tags$iframe(seamless="seamless",  src= path,  width='1000', height='1300')
            
        } else {
            
            path = paste0("tmpuser/www/topografico_casa_", react_list$selec, ".html")
            
            tags$iframe(seamless="seamless",  src= path,  width='1300', height='1000')
        }
    })
  
# server functions for TABLE EDITOR
    
    observe({
        
        req(input$upload)
        
        react_list$tab2_edit = read.csv(input$upload$datapath, header = TRUE, sep = ",", stringsAsFactors = FALSE,  row.names = NULL, check.names = FALSE)
        
    })
    
    output$tab2_name = renderText(input$upload$name)
    
    output$tab2 = renderDT( react_list$tab2_edit # %>% DT::formatStyle( lineHeight='70%' ) # tryed to use DT::datatable(react_list$tab2_edit)
                            ,  rownames = F,   editable = 'cell', server = TRUE  ) # editable = TRUE, selection = 'none',
    
    # this is the 'EDITOR'
    
    proxy = dataTableProxy( 'tab2' )
    
    output$proxy = renderText(str(dataTableProxy( 'tab2' )))
    
    observeEvent(input$tab2_cell_edit, {
        info = input$tab2_cell_edit
        str(info)
        i = info$row
        j = info$col + 1  # column index offset by 1
        v = info$value
        
        react_list$tab2_edit[i, j] <- DT::coerceValue(v, react_list$tab2_edit[i, j])
        
        replaceData(proxy, react_list$tab2_edit, resetPaging = FALSE, rownames = FALSE)
    })
    
    # save to file
    
    output$download <- downloadHandler("example.csv",
                                       content = function(file){ write.csv(react_list$tab2_edit, file, row.names = F) },
                                       contentType = "text/csv")
}      

# Normal Run App ----

shinyApp( ui = ui, server = server, options = list()) #width = 100, lauch_browser = TRUE) )

# Run the application with themer

# run_with_themer( shinyApp( ui = ui, server = server, options = list(width = 100) ) )


# runApp('Dabukuri_espacial')






# output$texto <- renderText( file.path(getwd(),'www', input$memo) )
# MODULE select_html is NOT working as
# output$memo_out <- server_select_html(id = 'memo')
# 
# output$topo_out <- server_select_html(id = 'topo')


# Download
# output$downloadReport <- downloadHandler(

#     filename = function() {
#         paste('my-report', sep = '.', switch(
#             input$format, PDF = 'pdf', HTML = 'html', Word = 'docx'
#         ))
#     },
#     
#     content = function(file) {
#         src <- normalizePath('report.Rmd')
#         
#         # temporarily switch to the temp dir, in case you do not have write
#         # permission to the current working directory
#         owd <- setwd(tempdir())
#         on.exit(setwd(owd))
#         file.copy(src, 'report.Rmd', overwrite = TRUE)
#         
#         library(rmarkdown)
#         out <- render('report.Rmd', switch(
#             input$format,
#             PDF = pdf_document(), HTML = html_document(), Word = word_document()
#         ))
#         file.rename(out, file)
#     }
# )
