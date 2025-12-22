library(teal)
library(dplyr)
library(ggplot2)

my_custom_module_ui <- function(id) {
  ns <- NS(id)
  tags$div(
    teal.reporter::simple_reporter_ui(ns("reporter")),
    # Exercise 7.3: Add dataset selector --------------------------------------
    selectInput(
      inputId = ns("dataset"),
      label = "Select dataset",
      choices = NULL
    ),
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

my_custom_module_srv <- function(id, data, reporter, filter_panel_api) {
  moduleServer(id, function(input, output, session) {
    with_filter <- !rlang::is_missing(filter_panel_api) && inherits(filter_panel_api, "FilterPanelApi")

    # Exercise 7.3: Add dataset selector ----------------------------------------
    #  - Update dataset selector choices
    #  - Update variable selector choices based on selected dataset
    updateSelectInput(
      inputId = "dataset",
      choices = names(data())
    )


    observeEvent(
      input$dataset,
      {
        req(input$dataset)
        updateSelectInput(
          inputId = "variable",
          choices = data()[[input$dataset]] |> select(where(is.numeric)) |> names()
        )
      }
    )
    # -------------------------------------------------------------------------

    # Exercise 7.3: Add dataset selector --------------------------------------
    #  - Update reactive function
    result <- reactive({
      req(input$dataset)
      req(input$variable)
      req(input$variable %in% names(data()[[input$dataset]]))
      req(input$binwidth)
      within(
        data(),
        {
          plot <- ggplot(input_dataset, aes(x = input_var)) +
            geom_histogram(binwidth = input_binwidth)
          plot
        },
        input_dataset = as.name(input$dataset),
        input_var = as.name(input$variable),
        input_binwidth = input$binwidth
      )
    })
    # -------------------------------------------------------------------------

    # render to output the object from qenv
    output$plot <- renderPlot({
      result()[["plot"]]
    })

    card_fun <- function(card = teal.reporter::ReportCard$new(), comment) {
      card$set_name("My custom module")
      card$append_text(filter_panel_api$get_filter_state(), "verbatim")
      card$append_text(paste("Selected var:", input$variable))
      card$append_text(paste("Selected binwidth:", input$binwidth))
      card$append_plot(result()$plot)
    }
    teal.reporter::simple_reporter_srv(
      id = "reporter",
      reporter = reporter,
      card_fun = card_fun
    )

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
