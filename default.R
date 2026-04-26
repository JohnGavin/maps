# default.R for maps package
# Generate default.nix using rix::rix()

library(rix)

r_pkgs <- c(
  # Core dependencies (from DESCRIPTION Imports)
  "sf",
  "giscoR",
  "sfdep",
  "igraph",
  "dplyr",
  "rlang",

  # Suggested packages
  "osmdata",
  "leaflet",
  "targets",
  "tarchetypes",

  # Testing and development
  "testthat",
  "covr",
  "devtools",
  "gert",
  "roxygen2",
  "knitr",
  "rmarkdown",

  # Documentation
  "pkgdown",
  "quarto"
)

system_pkgs <- c(
  "gdal",
  "geos",
  "proj",
  "quarto"
)

rix(
  r_ver = "4.5.3",
  r_pkgs = r_pkgs,
  system_pkgs = system_pkgs,
  ide = "none",
  project_path = ".",
  overwrite = TRUE
)
