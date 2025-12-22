library(teal)
library(dplyr)
library(ggplot2)

my_custom_module_ui <- function(id) {
  ns <- NS(id)
  tags$div(
    selectInput( # variable selector
      inputId = ns("variable"),
      label = "Select variable",
      choices = NULL # initialize empty - to be updated from within server
    ),
    sliderInput(
      inputId = ns("binwidth"),
      label = "binwidth",
      min = 1,
      max = 10,
      step = 1,
      value = 3
    ),
    plotOutput(ns("plot")) # Output for the plot
  )
}

my_custom_module_srv <- function(id, data) {
  moduleServer(id, function(input, output, session) {

    updateSelectInput( # update variable selector by names of data
      inputId = "variable",
      choices = data()[["ADSL"]] |> select(where(is.numeric)) |> names()
    )

    result <- reactive({
      validate(
        need(input$variable, "Select a variable"),
        need(input$binwidth > 0, "Binwidth must be greater than 0")
      )
      # Exercise 7.4: Add heading for plot code & output ----------------------
      # - Store data in a temporary variable
      # - Add markdown header
      # - Then call within with temporary variable
      within(
        data(),
        {
          plot <- ggplot(ADSL, aes(x = .data[[variable]])) +
            geom_histogram(binwidth = binwidth)
          plot
        },
        variable = input$variable,
        binwidth = input$binwidth
      )
      # -----------------------------------------------------------------------
    })

    output$plot <- renderPlot(result()[["plot"]])

    result
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
