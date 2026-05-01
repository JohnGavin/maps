# Regression test: Ireland sea-distance snapshot
#
# This test catches coastline resolution regressions (e.g. switching from
# res "03" to "20" silently drops Leitrim and Limerick from the coastal set).
# See JohnGavin/maps#3 for the incident that motivated this test.

test_that("Ireland has exactly 18 coastal counties at resolution 03", {
  skip_on_cran()
  skip_if_offline()

  counties <- get_ireland_32_counties()
  coast <- giscoR::gisco_get_coastallines(year = 2016, resolution = "03")
  skip_if(is.null(coast), "GISCO coastline API unavailable")

  counties <- compute_sea_distance(counties, coast, crs_projected = 2157L)

  # No NA in sea_distance

  expect_false(any(is.na(counties$sea_distance)),
               info = "sea_distance contains NA — check for disconnected islands")

  # No NA or literal "NA" in county_name
  expect_false(any(is.na(counties$county_name)))
  expect_false(any(counties$county_name == "NA"))

  # Exactly 32 counties
  expect_equal(nrow(counties), 32L)

  # --- Coastal snapshot (distance 0) ---
  expected_coastal <- c(
    "Antrim", "Clare", "Cork", "Donegal", "Down", "Dublin",
    "Galway", "Kerry", "Leitrim", "Limerick", "Londonderry",
    "Louth", "Mayo", "Meath", "Sligo", "Waterford", "Wexford", "Wicklow"
  )
  actual_coastal <- sort(counties$county_name[counties$sea_distance == 0L])
  expect_equal(actual_coastal, expected_coastal,
               info = "Coastal county set changed — check coastline resolution")

  # --- Distance snapshot ---
  expected_distances <- c(
    Antrim = 0L, Armagh = 1L, Carlow = 1L, Cavan = 1L,
    Clare = 0L, Cork = 0L, Donegal = 0L, Down = 0L,
    Dublin = 0L, Fermanagh = 1L, Galway = 0L, Kerry = 0L,
    Kildare = 1L, Kilkenny = 1L, Laois = 2L, Leitrim = 0L,
    Limerick = 0L, Londonderry = 0L, Longford = 1L, Louth = 0L,
    Mayo = 0L, Meath = 0L, Monaghan = 1L, Offaly = 1L,
    Roscommon = 1L, Sligo = 0L, Tipperary = 1L, Tyrone = 1L,
    Waterford = 0L, Westmeath = 1L, Wexford = 0L, Wicklow = 0L
  )
  actual <- setNames(counties$sea_distance, counties$county_name)
  actual <- actual[sort(names(actual))]
  expect_equal(actual, expected_distances,
               info = "Sea-distance values changed — regression detected")

  # --- Laois is the only distance-2 county ---
  expect_equal(
    counties$county_name[counties$sea_distance == 2L],
    "Laois",
    info = "Laois should be the only distance-2 (most inland) county"
  )
})
