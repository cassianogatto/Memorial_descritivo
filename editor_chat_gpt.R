library(shiny)
library(DT)

# Save module
saveModule <- function(input, output, session) {
  observeEvent(input$saveButton, {
    # Get the edited table data
    data <- input$table_editing_all_rows
    
    # Save the edited table to a CSV file
    write.csv(data, file.choose(), row.names = FALSE)
  })
}

# Define UI
ui <- fluidPage(
  titlePanel("Table Editor"),
  
  # Input: Select a file
  fileInput("file", "Choose a CSV file"),
  tabsetPanel(
        # Tab 1: View the loaded table
        tabPanel("View Table", DT::dataTableOutput("table")),
        
        # Tab 2: Edit the table
        tabPanel("Edit Table", DT::dataTableOutput("editableTable"), 
                 actionButton("saveButton", "Save Table"))
      )
)


# Define server
server <- function(input, output, session) {
  # Load the CSV file
  loadedData <- reactive({
    req(input$file)
    read.csv(input$file$datapath)
  })
  
  # Render the loaded table
  output$table <- DT::renderDataTable({
    DT::datatable(loadedData())
  })
  
  # Render the editable table
  output$editableTable <- DT::renderDataTable({
    DT::datatable(loadedData(), editable = TRUE,
                  options = list(dom = 't', paging = FALSE, ordering = FALSE))
  })
  
  # Call the save module
  callModule(saveModule, "table_module")
}

# Run the app
shinyApp(ui, server)
