library(teal)
library(dplyr)
library(ggplot2)

my_custom_module_ui <- function(id) {
  ns <- NS(id)
  tags$div(
    # Exercise 7.2: Add select UI for variable  -------------------------------

    # -------------------------------------------------------------------------
    plotOutput(ns("plot")) # Output for the plot
  )
}

my_custom_module_srv <- function(id, data) {
  moduleServer(id, function(input, output, session) {

    # Exercise 7.2: Update select choices -------------------------------------
    # - hint: use updateSelectInput()

    # -------------------------------------------------------------------------

    # Exercise 7.2: Use selected variable in plot -----------------------------
    # - hint: within accepts named arguments that inject values from session
    #   - var1 = input$var1 allows to use var1 inside code block
    result <- reactive({

      within(
        data(),
        {
          plot <- ggplot(ADSL, aes(x = .data[["AGE"]])) + geom_histogram()
          plot
        }
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
