# Load the teal library
library(teal)

# Create the simplest possible teal application
app <- teal::init(
  data = teal.data::teal_data(iris = iris),
  modules = teal::module()
)

# Launch the application
if (interactive()) {
  shiny::shinyApp(app$ui, app$server)
}
