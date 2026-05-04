# Regression tests: England, Scotland, Wales sea-distance snapshots
#
# These tests catch coastline resolution regressions and GADM name-fix
# regressions for the three GB nations at GADM level 2.
#
# Computed 2026-04-21 using:
#   giscoR::gisco_get_coastallines(year = 2016, resolution = "03")
#   get_country_boundaries("GBR", 2L)
#   fix_gadm_gbr_names()
#   compute_sea_distance(crs_projected = 27700L)
#
# Known GADM 4.1 data quirks preserved intentionally in these snapshots:
#   - England: "Bournemouth, Christchurch and Poole" appears twice (nrow = 115)
#   - Wales: "Newport" appears twice (nrow = 22)
#   - Camel-case name artifacts: "Blackburnwith Darwen", "Brightonand Hove",
#     "Isleof Wight", "Islesof Scilly", "Kingstonupon Hull", "Telfordand Wrekin",
#     "Argylland Bute", "Cityof Edinburgh", "Dumfriesand Galloway",
#     "Perthand Kinross", "Isleof Anglesey"
#   These are produced by fix_gadm_gbr_names() and are pinned here so any
#   change to the name-fixing logic is flagged by a failing test.

# Helper: prepare one nation's sf from the GBR level-2 data
prepare_nation <- function(gbr2, country, coast) {
  sub <- gbr2[gbr2$NAME_1 == country, ]
  sub <- fix_gadm_gbr_names(sub)
  sub$county_name <- sub$NAME_2
  sub$country     <- sub$NAME_1
  bad <- is.na(sub$county_name) | sub$county_name == "NA"
  if (any(bad)) sub <- sub[!bad, ]
  sub <- sub[, c("county_name", "country", "geometry")]
  compute_sea_distance(sub, coast, crs_projected = 27700L)
}

# ── England ──────────────────────────────────────────────────────────────────

test_that("England sea-distance snapshot at resolution 03", {
  skip_on_cran()

  coast <- giscoR::gisco_get_coastallines(year = 2016, resolution = "03") %||%
    readRDS(system.file("extdata", "coastline_03_ireland_uk.rds", package = "maps"))

  gbr2 <- get_country_boundaries("GBR", 2L)
  eng  <- prepare_nation(gbr2, "England", coast)

  # No NA in sea_distance or county_name
  expect_false(any(is.na(eng$sea_distance)),
               info = "sea_distance contains NA — check for disconnected regions")
  expect_false(any(is.na(eng$county_name)))
  expect_false(any(eng$county_name == "NA"))

  # Row count (115 includes one duplicate "Bournemouth, Christchurch and Poole")
  expect_equal(nrow(eng), 115L)

  # Coastal count
  expect_equal(sum(eng$sea_distance == 0L), 47L,
               info = "Coastal county count changed — check coastline resolution")

  # Max sea distance
  expect_equal(max(eng$sea_distance), 4L)

  # Distance-4 counties (most inland)
  deepest <- sort(eng$county_name[eng$sea_distance == 4L])
  expect_equal(deepest, c("Blackburnwith Darwen", "Herefordshire", "Sandwell"),
               info = "Distance-4 county set changed — regression detected")

  # Full distance snapshot (sorted by name)
  dt <- sf::st_drop_geometry(eng)
  dt <- dt[order(dt$county_name), ]
  actual <- setNames(dt$sea_distance, dt$county_name)

  expected_distances <- c(
    "Barnsley" = 2L,
    "Bathand North East Somerset" = 1L,
    "Bedford" = 1L,
    "Birmingham" = 3L,
    "Blackburnwith Darwen" = 4L,
    "Blackpool" = 0L,
    "Bolton" = 3L,
    "Bournemouth, Christchurch and Poole" = 0L,
    "Bournemouth, Christchurch and Poole" = 0L,
    "Bracknell Forest" = 1L,
    "Bradford" = 1L,
    "Brightonand Hove" = 0L,
    "Bristol" = 0L,
    "Buckinghamshire" = 1L,
    "Bury" = 3L,
    "Calderdale" = 2L,
    "Cambridgeshire" = 0L,
    "Central Bedfordshire" = 1L,
    "Cheshire East" = 2L,
    "Cornwall" = 0L,
    "County Durham" = 0L,
    "Coventry" = 3L,
    "Cumbria" = 0L,
    "Darlington" = 1L,
    "Derby" = 3L,
    "Derbyshire" = 2L,
    "Devon" = 0L,
    "Doncaster" = 1L,
    "Dorset" = 0L,
    "Dudley" = 3L,
    "East Riding of Yorkshire" = 0L,
    "East Sussex" = 0L,
    "Essex" = 0L,
    "Gateshead" = 1L,
    "Greater London" = 0L,
    "Halton" = 0L,
    "Hampshire" = 0L,
    "Hartlepool" = 0L,
    "Herefordshire" = 4L,
    "Hertfordshire" = 1L,
    "Isleof Wight" = 0L,
    "Islesof Scilly" = 0L,
    "Kent" = 0L,
    "Kingstonupon Hull" = 0L,
    "Kirklees" = 2L,
    "Knowsley" = 1L,
    "Leeds" = 1L,
    "Leicester" = 2L,
    "Leicestershire" = 1L,
    "Lincolnshire" = 0L,
    "Luton" = 2L,
    "Manchester" = 3L,
    "Medway" = 0L,
    "Middlesbrough" = 0L,
    "Milton Keynes" = 2L,
    "Newcastle upon Tyne" = 1L,
    "Norfolk" = 0L,
    "North Lincolnshire" = 0L,
    "North Somerset" = 0L,
    "North Tyneside" = 0L,
    "North Yorkshire" = 0L,
    "Northamptonshire" = 1L,
    "Northumberland" = 0L,
    "Nottingham" = 2L,
    "Nottinghamshire" = 1L,
    "Oldham" = 3L,
    "Oxfordshire" = 2L,
    "Peterborough" = 1L,
    "Plymouth" = 0L,
    "Portsmouth" = 0L,
    "Reading" = 2L,
    "Redcar and Cleveland" = 0L,
    "Rochdale" = 3L,
    "Rotherham" = 2L,
    "Rutland" = 1L,
    "Salford" = 2L,
    "Sandwell" = 4L,
    "Sefton" = 0L,
    "Sheffield" = 3L,
    "Shropshire" = 3L,
    "Slough" = 1L,
    "Solihull" = 3L,
    "Somerset" = 0L,
    "South Gloucestershire" = 0L,
    "South Tyneside" = 0L,
    "Southampton" = 0L,
    "Southend-on-Sea" = 0L,
    "St.Helens" = 1L,
    "Staffordshire" = 2L,
    "Stockport" = 3L,
    "Stockton-on-Tees" = 0L,
    "Stoke-on-Trent" = 3L,
    "Suffolk" = 0L,
    "Sunderland" = 0L,
    "Surrey" = 1L,
    "Swindon" = 2L,
    "Tameside" = 3L,
    "Telfordand Wrekin" = 3L,
    "Thurrock" = 0L,
    "Torbay" = 0L,
    "Trafford" = 2L,
    "Wakefield" = 1L,
    "Walsall" = 3L,
    "Warrington" = 1L,
    "Warwick" = 2L,
    "West Berkshire" = 1L,
    "West Sussex" = 0L,
    "Wigan" = 2L,
    "Wiltshire" = 1L,
    "Windsor and Maidenhead" = 2L,
    "Wirral" = 0L,
    "Wokingham" = 1L,
    "Wolverhampton" = 3L,
    "Worcestershire" = 3L,
    "York" = 1L
  )

  expect_equal(actual, expected_distances,
               info = "England sea-distance values changed — regression detected")
})

# ── Scotland ──────────────────────────────────────────────────────────────────

test_that("Scotland sea-distance snapshot at resolution 03", {
  skip_on_cran()

  coast <- giscoR::gisco_get_coastallines(year = 2016, resolution = "03") %||%
    readRDS(system.file("extdata", "coastline_03_ireland_uk.rds", package = "maps"))

  gbr2 <- get_country_boundaries("GBR", 2L)
  sco  <- prepare_nation(gbr2, "Scotland", coast)

  # No NA in sea_distance or county_name
  expect_false(any(is.na(sco$sea_distance)),
               info = "sea_distance contains NA — check for disconnected regions")
  expect_false(any(is.na(sco$county_name)))
  expect_false(any(sco$county_name == "NA"))

  # Row count
  expect_equal(nrow(sco), 32L)

  # Coastal count (Scotland is heavily coastal)
  expect_equal(sum(sco$sea_distance == 0L), 26L,
               info = "Coastal council count changed — check coastline resolution")

  # Max sea distance (only distance-0 and distance-1 in Scotland)
  expect_equal(max(sco$sea_distance), 1L)

  # Distance-1 councils (most inland)
  inland <- sort(sco$county_name[sco$sea_distance == 1L])
  expect_equal(
    inland,
    c("East Ayrshire", "East Dunbartonshire", "East Renfrewshire",
      "Midlothian", "North Lanarkshire", "South Lanarkshire"),
    info = "Distance-1 council set changed — regression detected"
  )

  # Full distance snapshot (sorted by name)
  dt <- sf::st_drop_geometry(sco)
  dt <- dt[order(dt$county_name), ]
  actual <- setNames(dt$sea_distance, dt$county_name)

  expected_distances <- c(
    "Aberdeen City"        = 0L,
    "Aberdeenshire"        = 0L,
    "Angus"                = 0L,
    "Argylland Bute"       = 0L,
    "Cityof Edinburgh"     = 0L,
    "Clackmannanshire"     = 0L,
    "Dumfriesand Galloway" = 0L,
    "Dundee City"          = 0L,
    "East Ayrshire"        = 1L,
    "East Dunbartonshire"  = 1L,
    "East Lothian"         = 0L,
    "East Renfrewshire"    = 1L,
    "Falkirk"              = 0L,
    "Fife"                 = 0L,
    "Glasgow City"         = 0L,
    "Highland"             = 0L,
    "Inverclyde"           = 0L,
    "Midlothian"           = 1L,
    "Moray"                = 0L,
    "Nah-Eileanan Siar"    = 0L,
    "North Ayrshire"       = 0L,
    "North Lanarkshire"    = 1L,
    "Orkney Islands"       = 0L,
    "Perthand Kinross"     = 0L,
    "Renfrewshire"         = 0L,
    "Scottish Borders"     = 0L,
    "Shetland Islands"     = 0L,
    "South Ayrshire"       = 0L,
    "South Lanarkshire"    = 1L,
    "Stirling"             = 0L,
    "West Dunbartonshire"  = 0L,
    "West Lothian"         = 0L
  )

  expect_equal(actual, expected_distances,
               info = "Scotland sea-distance values changed — regression detected")
})

# ── Wales ─────────────────────────────────────────────────────────────────────

test_that("Wales sea-distance snapshot at resolution 03", {
  skip_on_cran()

  coast <- giscoR::gisco_get_coastallines(year = 2016, resolution = "03") %||%
    readRDS(system.file("extdata", "coastline_03_ireland_uk.rds", package = "maps"))

  gbr2  <- get_country_boundaries("GBR", 2L)
  wales <- prepare_nation(gbr2, "Wales", coast)

  # No NA in sea_distance or county_name
  expect_false(any(is.na(wales$sea_distance)),
               info = "sea_distance contains NA — check for disconnected regions")
  expect_false(any(is.na(wales$county_name)))
  expect_false(any(wales$county_name == "NA"))

  # Row count (22 includes one duplicate "Newport")
  expect_equal(nrow(wales), 22L)

  # Coastal count
  expect_equal(sum(wales$sea_distance == 0L), 15L,
               info = "Coastal authority count changed — check coastline resolution")

  # Max sea distance
  expect_equal(max(wales$sea_distance), 2L)

  # Merthyr Tydfil is the only distance-2 (most inland) authority
  expect_equal(
    wales$county_name[wales$sea_distance == 2L],
    "Merthyr Tydfil",
    info = "Merthyr Tydfil should be the only distance-2 authority"
  )

  # Full distance snapshot (sorted by name)
  dt <- sf::st_drop_geometry(wales)
  dt <- dt[order(dt$county_name), ]
  actual <- setNames(dt$sea_distance, dt$county_name)

  expected_distances <- c(
    "Blaenau Gwent"    = 0L,
    "Bridgend"         = 1L,
    "Caerphilly"       = 1L,
    "Cardiff"          = 0L,
    "Carmarthenshire"  = 0L,
    "Ceredigion"       = 0L,
    "Conwy"            = 0L,
    "Denbighshire"     = 0L,
    "Flintshire"       = 0L,
    "Gwynedd"          = 0L,
    "Isleof Anglesey"  = 0L,
    "Merthyr Tydfil"   = 2L,
    "Monmouthshire"    = 0L,
    "Newport"          = 0L,
    "Newport"          = 0L,
    "Pembrokeshire"    = 0L,
    "Powys"            = 1L,
    "Rhondda Cynon Taf" = 1L,
    "Swansea"          = 0L,
    "Torfaen"          = 1L,
    "Vale of Glamorgan" = 0L,
    "Wrexham"          = 1L
  )

  expect_equal(actual, expected_distances,
               info = "Wales sea-distance values changed — regression detected")
})
