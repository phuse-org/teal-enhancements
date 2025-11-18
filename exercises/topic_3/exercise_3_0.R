# Launching a simple `teal` application

## Task 0
## Try launching the below application
library(teal)

app <- teal::init(
  data = teal.data::teal_data(iris = iris),
  modules = teal::example_module(
    label = "example teal module",
    datanames = "all",
    transformators = list(),
    decorators = list()
  )
)

# Launch the application
if (interactive()) {
  shiny::shinyApp(app$ui, app$server)
}

# Task 1:
# 1. Add another dataset to the application - `mtcars`
# 2. Launch the application and check if the dataset is available in the application

# Task 2:
# 1. Add a new module to the application - `teal.modules.general::tm_data_table()`.
# 2. Launch the application and check if the module is available in the application
# Hint: you will need to load the `teal.modules.general` package to use the module.
# via `library(teal.modules.general)`. If you feel lost, please check out the
# manual at: https://insightsengineering.github.io/teal.modules.general/latest-tag/reference/tm_data_table.html
