library(teal.modules.clinical)
library(pharmaverseadam)

data <- teal.data::cdisc_data(
  ADSL = pharmaverseadam::adsl,
  ADAE = pharmaverseadam::adae,
  code = "
    ADSL <- pharmaverseadam::adsl
    ADAE <- pharmaverseadam::adae
  "
)

ADSL <- data[["ADSL"]]
ADAE <- data[["ADAE"]]

app <- teal::init(
  data = data,
  modules = teal::modules(
    teal.modules.clinical::tm_t_events(
      label = "Adverse Event Table",
      dataname = "ADAE",
      arm_var = teal.modules.clinical::choices_selected(c("ARM", "ARMCD"), "ARM"),
      llt = teal.transform::choices_selected(
        choices = teal.transform::variable_choices(ADAE, c("AETERM", "AEDECOD")),
        selected = c("AEDECOD")
      ),
      hlt = teal.modules.clinical::choices_selected(
        choices = teal.transform::variable_choices(ADAE, c("AEBODSYS", "AESOC")),
        selected = "AEBODSYS"
      ),
      add_total = TRUE,
      event_type = "adverse event"
    )
  )
)
if (interactive()) {
  shiny::shinyApp(app$ui, app$server)
}
