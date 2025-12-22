library(teal)
library(dplyr)
library(ggplot2)

my_custom_module_ui <- function(id) {
  ns <- NS(id)
  tags$div(
    # Exercise 7.3: Add dataset selector --------------------------------------

    # -------------------------------------------------------------------------
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
    # Exercise 7.5: Add dataset selector ----------------------------------------
    #  - Update dataset selector choices
    #  - Update variable selector choices based on selected dataset

    updateSelectInput( # update variable selector by names of data
      inputId = "variable",
      choices = data()[["ADSL"]] |> select(where(is.numeric)) |> names()
    )

    # Exercise 7.5: Update validation and plot call ---------------------------
    #  - Validate that dataset is selected
    #  - Validate input$variable is present in dataset
    #  - Update plot call with
    result <- reactive({
      validate(
        need(input$variable, "Select a variable"),
        need(input$binwidth > 0, "Binwidth must be greater than 0")
      )
      q <- data()
      teal.reporter::teal_card(q) <- c(
        teal.reporter::teal_card(q),
        "### Histogram of Selected Variable"
      )
      within(
        q,
        {
          plot <- ggplot(ADSL, aes(x = .data[[variable]])) +
            geom_histogram(binwidth = binwidth)
          plot
        },
        variable = input$variable,
        binwidth = input$binwidth
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
  ADAE <- pharmaverseadam::adae
})

app <- init(
  data = data,
  modules = list(my_custom_module)
)

shinyApp(app$ui, app$server)
