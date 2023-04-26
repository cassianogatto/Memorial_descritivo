library(shiny)

ui <- shinyUI(
    
    fluidPage(
        
        fileInput( inputId = "filetab",  label = "Selecione a tabela '.csv' ", accept = c(".csv"), multiple=TRUE), #width = '500px', 
        
        actionButton(inputId = "get_tab", label =  "Carregar tabela!",  class = "btn-warning", color = 'black'), #class = "danger"),/8520
        
        numericInput(inputId = "lista_de_id", label = "Escolha a ID", value = 10),
        
        includeHTML('C:/Users/HUMANITAS-FAPEAM - 4/Documents/Cassiano/Memorial_descritivo2/outputs/Memorial_casa_102.html')
    )
)
server <- function(input, output) {  }

shinyApp(ui, server)
