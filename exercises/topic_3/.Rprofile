if (!identical(Sys.getenv("QUARTO_PROJECT_ROOT"), "")) {
  local({
    old_wd <- getwd()
    setwd(Sys.getenv("QUARTO_PROJECT_ROOT"))
    source("renv/activate.R")
    setwd(old_wd)
  })
}
