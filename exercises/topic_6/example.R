library(teal.modules.clinical)

# Create sample data
data <- teal_data() |>
  within({
    ADSL <- pharmaverseadam::adsl

    ADSL$ARM <- as.factor(ADSL$ARM)
    ADSL$ARMCD <- as.factor(ADSL$ARMCD)
    ADSL$SEX <- as.factor(ADSL$SEX)
    ADSL$RACE <- as.factor(ADSL$RACE)

    attr(ADSL$ARM, "label") <- "Actual Treatment Arm"
    attr(ADSL$ARMCD, "label") <- "Actual Treatment Arm Code"
    attr(ADSL$SEX, "label") <- "Sex"
    attr(ADSL$RACE, "label") <- "Race"
})

join_keys(data) <- default_cdisc_join_keys[names(data)]

# Basic application using choices_selected
app <- init(
  data = data,
  modules = modules(
    tm_t_summary(
      label = "Demographic Table",
      dataname = "ADSL",
      arm_var = choices_selected(c("ARM", "ARMCD"), "ARM"),
      add_total = TRUE,
      summarize_vars = choices_selected(
        c("SEX", "RACE", "AGE"),
        selected = c("SEX", "RACE", "AGE")
      ),
      useNA = "ifany"
    )
  )
)

runApp(app)
