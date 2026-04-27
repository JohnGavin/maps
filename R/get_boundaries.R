#' Get Country Administrative Boundaries from GADM
#'
#' Download administrative boundary polygons for any country using the
#' GADM 4.1 database.
#'
#' @param iso3 Character. ISO 3166-1 alpha-3 country code (e.g. "IRL", "GBR", "FRA").
#' @param level Integer. GADM administrative level (0=country, 1=regions,
#'   2=districts, etc.).
#' @param name_filter Character vector or NULL. If provided, filter to rows where
#'   `name_col` matches one of these values.
#' @param name_col Character. Column name to filter on. Default "NAME_1".
#' @return An sf object with boundary polygons.
#' @export
get_country_boundaries <- function(iso3, level = 1L, name_filter = NULL,
                                   name_col = "NAME_1") {
  url <- sprintf(
    "https://geodata.ucdavis.edu/gadm/gadm4.1/json/gadm41_%s_%d.json",
    toupper(iso3), as.integer(level)
  )
  sf_data <- sf::st_read(url, quiet = TRUE)
  if (!is.null(name_filter)) {
    sf_data <- sf_data[sf_data[[name_col]] %in% name_filter, ]
  }
  sf_data
}

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

  if (level == "county") {
    return(get_ireland_32_counties())
  }

  nuts_level <- switch(level,
    country  = 0L,
    province = 1L
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
  }

  nuts
}

#' Get All 32 Traditional Irish Counties
#'
#' Fetches 26 Republic of Ireland counties from GADM level 1 and
#' 6 Northern Ireland traditional counties by dissolving GADM level 3
#' district councils.
#'
#' @return An sf object with 32 rows and columns `county_name`, `country`,
#'   `geometry`.
#' @export
get_ireland_32_counties <- function() {
  # ROI: 26 counties from GADM IRL level 1
  irl <- get_country_boundaries("IRL", level = 1L)
  # GADM has NAME_1 = NA for Cork (HASC_1 = "IE.CK")
  irl$county_name <- ifelse(
    irl$HASC_1 == "IE.CK", "Cork", as.character(irl$NAME_1)
  )
  irl$country <- "Republic of Ireland"
  irl <- irl[, c("county_name", "country", "geometry")]

  # NI: dissolve 26 pre-2015 district councils -> 6 traditional counties
  gbr3 <- get_country_boundaries("GBR", level = 3L)
  ni3 <- gbr3[!is.na(gbr3$NAME_1) & gbr3$NAME_1 == "NorthernIreland", ]

  ni_lookup <- c(
    Antrim = "Antrim", Newtownabbey = "Antrim", Ballymena = "Antrim",
    Ballymoney = "Antrim", Carrickfergus = "Antrim", Larne = "Antrim",
    Moyle = "Antrim", Belfast = "Antrim",
    Armagh = "Armagh", Banbridge = "Armagh", Craigavon = "Armagh",
    Ards = "Down", NorthDown = "Down", Castlereagh = "Down",
    Down = "Down", Lisburn = "Down", NewryandMourne = "Down",
    Fermanagh = "Fermanagh",
    Coleraine = "Londonderry", Derry = "Londonderry",
    Limavady = "Londonderry", Magherafelt = "Londonderry",
    Cookstown = "Tyrone", Dungannon = "Tyrone", Omagh = "Tyrone",
    Strabane = "Tyrone"
  )

  ni3$county_name <- ni_lookup[ni3$NAME_3]
  ni3 <- ni3[!is.na(ni3$county_name), ]

  # Dissolve districts into 6 traditional counties
  ni_counties <- stats::aggregate(
    ni3["geometry"],
    by = list(county_name = ni3$county_name),
    FUN = function(x) sf::st_union(x)
  )
  ni_counties$country <- "Northern Ireland"
  ni_counties <- ni_counties[, c("county_name", "country", "geometry")]

  rbind(irl, ni_counties)
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
