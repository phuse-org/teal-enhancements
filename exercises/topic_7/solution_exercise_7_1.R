library(teal)
library(dplyr)
library(ggplot2)

my_custom_module_ui <- function(id) {
  ns <- NS(id)
  tags$div(
    plotOutput(ns("plot")) # Output for the plot
  )
}

my_custom_module_srv <- function(id, data) {
  moduleServer(id, function(input, output, session) {
    # Exercise 7.1: Use within to create plot ---------------------------------
    # - Create a reactive variable that modifies data()
    #   - hint: use within(data(), ggplot_code)
    #   - within code should keep plot in a variable and print it
    # - renderPlot() should access modified reactive data variable

    result <- reactive({
      req(input$variable)
      within(
        data(),
        {
          plot <- ggplot(ADSL, aes(x = .data[["AGE"]])) + geom_histogram()
          plot
        }
      )
    })
    output$plot <- renderPlot(result()[["plot"]])
    # -------------------------------------------------------------------------

    # Exercise 7.1: Return modified data object -------------------------------
    result
    # -------------------------------------------------------------------------
  })
}

my_custom_module <- module(
  label = "My Custom Module",
  ui = my_custom_module_ui,
  server = my_custom_module_srv
)

data <- teal_data()
data <- within(data, {
  ADSL <- pharmaverseadam::adsl
})

app <- init(
  data = data,
  modules = list(my_custom_module)
)

shinyApp(app$ui, app$server)
