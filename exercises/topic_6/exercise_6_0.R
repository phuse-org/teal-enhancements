library(dplyr)
library(forcats)
library(teal.transform)
library(teal.modules.clinical)

data <- teal_data()
data <- within(data, {
  ADSL <- pharmaverseadam::adsl

  ADSL$ARM <- as.factor(ADSL$ARM)
  ADSL$ARMCD <- as.factor(ADSL$ARMCD)
  ADSL$ACTARMCD <- as.factor(ADSL$ACTARMCD)

  ADLB <- pharmaverseadam::adlb |>
    mutate(
      AVISIT = as.factor(AVISIT),
      AVISIT == fct_reorder(AVISIT, AVISITN, min),
      AVALU = "DAYS"
    )

  ADLB$ARM <- as.factor(ADLB$ARM)
  ADLB$ARMCD <- as.factor(ADLB$ARMCD)
  ADLB$ACTARMCD <- as.factor(ADLB$ACTARMCD)
})
join_keys(data) <- default_cdisc_join_keys[names(data)]

app <- init(
  data = data,
  modules = modules(
    tm_g_lineplot(
      label = "Line Plot",
      dataname = "ADLB",
      group_var = choices_selected(), # Select Treatment variable,
      y = choices_selected(), # Select Analysis variable,
      param = choices_selected() # Select Parameter of Interest
    )
  )
)
runApp(app)