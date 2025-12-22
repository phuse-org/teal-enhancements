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
  # data: reactive()
  # teal_data() object
  moduleServer(id, function(input, output, session) {
    # Exercise 7.1: Use within to create plot ---------------------------------
    # - Create a reactive variable that modifies data()
    #   - hint: use within(data(), ggplot_code)
    #   - within code should keep plot in a variable and print it
    # - renderPlot() should access modified reactive data variable

    data_modified <- reactive({
      within(
        data(),
        {
          plot <- ggplot2::ggplot(ADSL, ggplot2::aes(x = .data[["AGE"]])) + ggplot2::geom_histogram()
          plot
        }
      )
    })

    output$plot <- renderPlot({
      data_modified()[["plot"]]
    })

    data_modified
  })
}

my_custom_module <- teal::module(
  label = "My Custom Module",
  ui = my_custom_module_ui,
  server = my_custom_module_srv
)

data <- teal_data()
data <- within(
  data,
  {
    ADSL <- pharmaverseadam::adsl
  }
)
app <- init(
  data = data,
  modules = list(my_custom_module)
)

shinyApp(app$ui, app$server)
