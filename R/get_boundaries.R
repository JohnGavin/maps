#' Get Ireland Administrative Boundaries
#'
#' Fetch hierarchical administrative boundaries for Ireland
#' at various NUTS/LAU levels using giscoR.
#'
#' @param level Character. One of "country", "province", "county".
#' @param year Numeric. Reference year for GISCO data. Default 2021.
#' @return An sf object with boundary polygons.
#' @export
get_ireland_boundaries <- function(level = c("country", "province", "county"),
                                   year = 2021) {
  level <- match.arg(level)

  nuts_level <- switch(level,
    country  = 0L,
    province = 1L,
    county   = 3L
  )

  # GISCO NUTS regions for Ireland (IE) + UK Northern Ireland (UKN)
  nuts <- giscoR::gisco_get_nuts(
    year = year,
    resolution = "10",
    nuts_level = nuts_level,
    country = c("IE", "UK")
  )

  # Filter to island of Ireland
  if (nuts_level == 0L) {
    nuts <- nuts[nuts$CNTR_CODE %in% c("IE", "UK"), ]
  } else if (nuts_level == 1L) {
    # IE0 = Ireland, UKN = Northern Ireland
    nuts <- nuts[nuts$NUTS_ID %in% c("IE0", "UKN"), ]
  } else if (nuts_level == 3L) {
    # All IE NUTS3 + UKN0 (Northern Ireland)
    nuts <- nuts[grepl("^IE|^UKN", nuts$NUTS_ID), ]
  }

  nuts
}

#' Get Ireland Coastline
#'
#' Fetch coastline geometry for intersection with county boundaries.
#'
#' @param year Numeric. Reference year. Default 2021.
#' @return An sf linestring object of coastlines.
#' @export
get_coastline <- function(year = 2021) {
  giscoR::gisco_get_coastallines(year = year, resolution = "10")
}
