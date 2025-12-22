library(teal)
library(dplyr)
library(ggplot2)

my_custom_module_ui <- function(id) {
  ns <- NS(id)
  tags$div(
    # Exercise 7.2: Add select UI for variable  -------------------------------
    selectInput( # variable selector
      inputId = ns("variable"),
      label = "Select variable",
      choices = NULL # initialize empty - to be updated from within server
    ),
    # -------------------------------------------------------------------------
    plotOutput(ns("plot")) # Output for the plot
  )
}

my_custom_module_srv <- function(id, data) {
  moduleServer(id, function(input, output, session) {

    # Exercise 7.2: Update select choices -------------------------------------
    # - hint: use updateSelectInput()
    updateSelectInput( # update variable selector by names of data
      inputId = "variable",
      choices = data()[["ADSL"]] |> select(where(is.numeric)) |> names()
    )
    # -------------------------------------------------------------------------

    # Exercise 7.2: Use selected variable in plot -----------------------------
    # - hint: within accepts named arguments that inject values from session
    #   - var1 = input$var1 allows to use var1 inside code block
    result <- reactive({
      validate(need(input$variable, "Select a variable"))
      within(
        data(),
        {
          plot <- ggplot(ADSL, aes(x = .data[[variable]])) + geom_histogram()
          plot
        },
        variable = input$variable
      )
    })
    # -------------------------------------------------------------------------

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
