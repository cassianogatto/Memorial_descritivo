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


# ui -----
ui <- 
    
    tagList(tags$head(tags$style(HTML(" 
              
       body{
          align: center;
          text-size:14px;
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
        
        #
        tabPanel("Apresentação",
                 
                 fluidRow(  column(2),  column(8, includeMarkdown("instrucoes.Rmd")  ), column(2),  )
        ),
        
        # comunidade ----
        
        tabPanel("Comunidade",
                 
                fluidRow(
                     
                     column(width = 4,
                         
                        div(align = 'justify', img(width = "80px", src = "DABUKURI.png" ), 
                                                
                                                img(width = "80px", src = "COPIME.png" )),
                     
                        radioButtons('comunidade', 'Escolha a comunidade', c('Kokama', 'Ipixuna'), inline = TRUE),
                        
                        checkboxInput("box_select_tab","Escolher a tabela com os dados da comunidade?", value = FALSE),
                        
                        conditionalPanel(condition = "input.box_select_tab == true",
                                         
                              fileInput( inputId = "filetab",  label = "Comunidade (tabela '.csv') ", accept = c(".csv"), multiple=TRUE),
                        )
                    ),
                     
                    column(width = 8,
                        
                        uiOutput("comunidade_intro"),
                    )
                ),
                
                fluidPage(
                    
                    tags$h3("Tabela Geral"),
                    
                    tags$h5("verifique os dados e escolha uma casa (id)"),
                    
                    DTOutput("tab"), 
                )
        ),
        
        
        # dados individuais ----
        
        tabPanel("Dados individuais",
                 
                br(),
                
                tags$h5("casa selecionada:"),
                
                textOutput("casa_selecionada") ,
                
                checkboxInput('select_column',"Escolher pela ID?", value = FALSE),
                
                conditionalPanel(condition = 'input.select_column == true',
                                 
                    # selectInput('coluna_select', 'Selecione o critério de escolha', choices = c("ID", "nome", "cpf", "endereço")),
                    
                    numericInput(inputId = "lista_de_id", label = "Escolha a ID", value = NULL),
                ),
                
                tags$h5("Detalhes"),
                
                textOutput('test'),
                
                fluidRow(
                    
                    column(5,
                        
                        p("Posição do terreno na comunidade"),
                        
                        imageOutput("inset") 
                    ),
                    
                    column(5,
                        
                        p('Esquema do terreno'),
                        
                        imageOutput("image")
                    ),
                ),
                
                div(class = 'container', style = "border: 1px solid black; width: 100%",
                    
                    tableOutput("V_tab")
                ),
                
                tags$h5("Use os botôes pra gerar os docs baseados nos templates base para Memoriais e Levantamentos Topográficos."),
                tags$h5("Os documentos gerados estarão disponíveis nos respectivos links 
                        e poderão ser abertos no seu browser, ou na aba 'Documentos' deste App"),
                
                # HTML("<br>"),
                
                # box(
                    
                    checkboxInput('input_templates',"Escolher outros templates?", value = FALSE),
                # ),
                
                conditionalPanel( condition = "input.input_templates == true",
                    
                    tags$h5("Após selecionar os templates gere os documentos e verifique o link."),
                    
                    br(),
                    
                    fluidRow(
                        
                        div(class = 'container',
                            
                            column(6,    
                                   
                                   selectInput(inputId = "memorial_template", label = "Arquivo memorial template", 
                                               choices = dir()[dir() %>% grep(pattern =  "*template_memorial*")],
                                               selected = "template_memorial_4_SHINY.Rmd"),
                            )),
                        
                        div(class = 'container',
                            
                            column(6,
                                   
                                   selectInput(inputId = "topografico_template", label = "Topográfico template", 
                                               choices = dir()[dir() %>% grep(pattern = "*template_topografico*")],
                                               selected = "topografico_template1.Rmd"),
                            )),
                    ),
                    
                ),
                
                fluidRow(
                    
                    div(class = 'container',
                        
                        column(6,    
                               
                               actionButton('get_memorial',"gerar memorial"),
                               
                               tags$h3("o arquivo Memorial gerado está em:"),
                               
                               uiOutput("markdown_memorial"),
                        )),
                    
                    div(class = 'container',
                        
                        column(6,
                               
                               actionButton("get_topografico","gerar topografico"),
                               
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
                        tags$code("Se desejar consultar para outra casa, clique e escolha na pasta /www; se não encontar tente gerá-lo na aba 'Dados Individuais'"),
                           
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
    )
)

addResourcePath("tmpuser", getwd())


# server -----
server <- function(input, output, session) {
    
    options(shiny.maxRequestSize=1000*1024^2) # this is required for uploading large files.
  
    tab_react <- reactive(  {
        
        if(input$box_select_tab){
            
            file <- input$filetab
            
            ext <- tools::file_ext(file$datapath)
            
            req(file)
            
            validate(need(ext == "csv", "Please upload a csv file"))
            
            tab <- read.csv(file$datapath, header = TRUE, check.names = FALSE) %>% as_tibble()
            
        } else {
            
            switch(input$comunidade, Kokama = read.csv("TAB_Kokama6.csv"), Ipixuna = read.csv("Ipixuna3.csv")) 
            
            # if (input$comunidade == "Kokama") { tab <- read.csv("TAB_Kokama6.csv") } else {data.frame(Importante = "escolha uma tabela válida")}
        }
    }  )
    
    V_react <- reactive(  {
        
        req(input$tab_rows_selected)
        
        req( tab_react() )
        
        row_slice <- input$tab_rows_selected
    
        # col <- which( names( tab_react() == input$coluna_select ) )
        
        # row_slice <- which( tab_react()[,col] == input$lista_de_id )
        
        V <- tab_react() %>% slice( row_slice ) 
    
    }  )
    
<<<<<<< HEAD
    output$tab <- renderDT( {  tab_react() # %>%  select(id, nome, cpf, rua, casa, area, perim, dist_frente, dist_lateral, observacoes, obs_frente, obs_lat_dir, obs_lat_esq, obs_fundos, X1 = dms_x_M01, Y1 = dms_y_M01, X2 = dms_x_M02, Y2 = dms_y_M02, X3 = dms_x_M03, Y3 = dms_y_M03,  X4 = dms_x_M04, Y4 = dms_y_M04)
=======
    output$test <- renderText(input$tab_row_selected)
    
    output$tab <- renderDataTable(   tab_react(), 
                options = list(scrollX = TRUE, pageLength = 30, autoWidth = TRUE, 
                            columnDefs = list(list( targets = 2, width = '600px' ) ) )
     )
    
    output$casa_selecionada <- renderText(input$tab_rows_selected)
    
    output$V_tab <- renderTable( { 
        
        row_slice <- which(tab_react()$id == input$lista_de_id)    
                    
        tab_react() %>% 
                                      
                select(id, nome, cpf, rua, casa, contains("dist_"), escala, observacoes, area, perim) %>% 
                    
                slice( row_slice  )  
>>>>>>> 844e38aa4035f35a8e033894231b919b1023ca6c
    } )
    
    output$comunidade_intro <- renderUI( { includeMarkdown( switch(input$comunidade, Kokama = "www/kokama_intro.Rmd", Ipixuna = "www/ipixuna_intro.Rmd") ) })
    
    output$inset <- renderImage({
        
            file1 <- normalizePath(file.path( './figures/inset', paste("inset__", input$lista_de_id, ".png", sep = '')))
        
                # normalizePath(file.path( './figures', paste0("casa___",input$lista_de_id, ".png")))
            
            list(src = file1, width = '450px')
            
    },   deleteFile = FALSE )
            
    output$image <- renderImage({
    
            file2 <- normalizePath(file.path( './figures', paste0("casa___",input$lista_de_id, ".png")))
            
            list(src = file2, width = '450px')
    
    },  deleteFile = FALSE )

# SALVE MEMORIAL E TOPOGRAFICO
    
    output$markdown_memorial <- renderUI(  {
            
            req( input$get_memorial)
        
            rmarkdown::render(input$"memorial_template",
                      output_format = "html_document",
                      output_file = paste0("memorial_casa_", input$lista_de_id), 
                      output_dir = paste0(getwd(),'/www'),
                      params = list(tab = tab_react(), casa = input$lista_de_id, V = V_react() )  )
    } )
    
    output$markdown_topografico <- renderUI(  {
            
            req(input$get_topografico)
            
            rmarkdown::render(input$"topografico_template",
                      output_format = "html_document",
                      output_file = paste0("topografico_casa_", input$lista_de_id), 
                      output_dir = paste0(getwd(),'/www'),
                      params = list(tab = tab_react(), casa = input$lista_de_id, V = V_react() )  )
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
            
            path = paste0("tmpuser/www/memorial_casa_", input$lista_de_id, ".html")
            
            tags$iframe(seamless="seamless",  src= path,  width='1000', height='1300')
        }
    })

    output$file_topo_html <- renderUI( {
        
        if(input$another_topo){
            
            path = paste0("tmpuser/www/topografico_casa_", input$another_topo_number, ".html")
            
            tags$iframe(seamless="seamless",  src= path,  width='1000', height='1300')
            
        } else {
            
            path = paste0("tmpuser/www/topografico_casa_", input$lista_de_id, ".html")
            
            tags$iframe(seamless="seamless",  src= path,  width='1300', height='1000')
        }
    })
    

}      



# Normal Run App ----

shinyApp( ui = ui, server = server, options = list()) #width = 100, lauch_browser = TRUE) )


# Run the application with themer

# run_with_themer(  shinyApp( ui = ui, server = server))#, options = list(width = 100) ) )


# runApp('Dabukuri_espacial')










# 
# output$texto <- renderText( file.path(getwd(),'www', input$memo) )
# MODULE select_html is NOT working as
# output$memo_out <- server_select_html(id = 'memo')
# 
# output$topo_out <- server_select_html(id = 'topo')

# # Define a reactiveFileReader to monitor the HTML file

# output$myhtml <- reactiveFileReader(
#     intervalMillis = 5000, # Check every second
#     filePath =   "C:/Users/Cliente/Documents/Cassiano/Shiny/Memorial_markdown-shiny/Memorial_descritivo/Dabukuri_espacial/www/memorial_casa_4.html",
#     session = NULL ,
#     readFunc = function(filePath) {
#         includeHTML(filePath)
#     }
# )
# UI
# uiOutput("myhtml")



# load figures in Mdown through R

# ```{r, out.width=='350px', fig.align='right'}
# 
# figure_path <- paste0('figures/casa__', V$id, '.png')  ## CHECK FIGURES' ID !!
# 
# knitr::include_graphics(figure_path)
# 
# ```

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
