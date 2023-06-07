# https://github.com/rstudio/DT/pull/480

library(shiny)
library(DT)
shinyApp(
    ui = fluidPage(
        
        fileInput("upload", "Choose CSV File",
                  multiple = FALSE,
                  accept = c("text/csv",
                             "text/comma-separated-values,text/plain",
                             ".csv")),
        # actionButton('save', 'save', class = 'danger'),
        downloadButton('download', class = 'btn-primary'),
        
        code( style = "font-size: 26px",
        
            textOutput("tab2_name"),
        ),
        
        DTOutput('tab2')
    ),
    
    
    server = function(input, output, session) {
        
        react_list = reactiveValues(tab2_edit = NULL)
        
        observe({
            
            req(input$upload)
            
            react_list$tab2_edit = #read.csv('TAB_Kokama9.csv', check.names = F)
                read.csv(input$upload$datapath, header = TRUE, sep = ",", stringsAsFactors = FALSE,  row.names = NULL)
        
        })
        
        output$tab2_name = renderText(input$upload$name)
        
        output$tab2 = renderDT(react_list$tab2_edit, selection = 'none', rownames = F, editable = T)
        
        
        # this is the 'EDITOR'
        
        proxy = dataTableProxy('tab2')
        
        observeEvent(input$tab2_cell_edit, {
            info = input$tab2_cell_edit
            str(info)
            i = info$row
            j = info$col + 1  # column index offset by 1
            v = info$value
            react_list$tab2_edit[i, j] <<- DT::coerceValue(v, react_list$tab2_edit[i, j])
            replaceData(proxy, react_list$tab2_edit, resetPaging = FALSE, rownames = FALSE)
        })
        
        # save to file
        
        output$download <- downloadHandler("example.csv",
            content = function(file){ write.csv(react_list$tab2_edit, file, row.names = F) },
            contentType = "text/csv")
        
        # this did not work
        # observeEvent( input$save ,{ write.csv(react_list$tab_edit, input$upload$name, row.names = F) })
        
    }
)


# original
# library(shiny)
# library(DT)
# shinyApp(
#     ui = fluidPage(
#         DTOutput('x1')
#     ),
#     server = function(input, output, session) {
#         x = iris
#         x$Date = Sys.time() + seq_len(nrow(x))
#         output$x1 = renderDT(x, selection = 'none', rownames = F, editable = T)
#         
#         proxy = dataTableProxy('x1')
#         
#         observeEvent(input$x1_cell_edit, {
#             info = input$x1_cell_edit
#             str(info)
#             i = info$row
#             j = info$col + 1  # column index offset by 1
#             v = info$value
#             x[i, j] <<- DT::coerceValue(v, x[i, j])
#             replaceData(proxy, x, resetPaging = FALSE, rownames = FALSE)
#         })
#     }
# )