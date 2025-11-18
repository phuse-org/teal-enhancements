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
    # Exercise 7: Add slider UI for binwidth ----------------------------------

    # -------------------------------------------------------------------------
    plotOutput(ns("plot")) # Output for the plot
  )
}

my_custom_module_srv <- function(id, data) {
  moduleServer(id, function(input, output, session) {

    updateSelectInput( # update variable selector by names of data
      inputId = "variable",
      choices = data()[["ADSL"]] |> select(where(is.numeric)) |> names()
    )

    # add plot call to qenv
    result <- reactive({
      req(input$variable)
      # Exercise 7.2: Add heading for plot code & output ----------------------
      # - Store data in a temporary variable
      # - Add markdown header
      # - Evaluate ggplot2 code to create histogram with selected variable


      within(
        data(),
        {
          plot <- ggplot(ADSL, aes(x = input_var)) + geom_histogram()
          plot
        },
        input_var = as.name(input$variable) # Pass the selected variable as a symbol
      )
      # -----------------------------------------------------------------------
    })

    # -------------------------------------------------------------------------
    # render to output the object from qenv
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
