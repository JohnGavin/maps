#' Fix GADM GBR Level 2 County Names
#'
#' GADM 4.1 GBR level 2 has 67 counties where NAME_2 is the literal
#' string "NA" and many others have no spaces (e.g. "BathandNorthEastSomerset").
#' This function applies a HASC_2 lookup for the missing names and cleans
#' camel-case formatting.
#'
#' @param sf_data An sf object from GADM GBR level 2 with columns NAME_2 and HASC_2.
#' @return The sf object with corrected NAME_2 column.
#' @export
fix_gadm_gbr_names <- function(sf_data) {
  # HASC_2 -> county name lookup for the 67 literal-"NA" entries
  # Source: statoids.com/ygb.html (HASC codes) + GADM 4.1 GBR level 2
  hasc_lookup <- c(
    "GB.TM" = "Tameside",
    "GB.TD" = "Trafford",
    "GB.WZ" = "Walsall",
    "GB.WT" = "Warrington",
    "GB.WR" = "Warwick",
    "GB.WN" = "Wigan",
    "GB.WL" = "Wiltshire",
    "GB.WA" = "Windsor and Maidenhead",
    "GB.WO" = "Wokingham",
    "GB.WC" = "Worcestershire",
    "GB.BS" = "Bristol",
    "GB.BU" = "Buckinghamshire",
    "GB.BR" = "Bury",
    "GB.CM" = "Cambridgeshire",
    "GB.CB" = "Central Bedfordshire",
    "GB.CQ" = "Cheshire East",
    "GB.BX" = "Barnsley",
    "GB.CO" = "Cornwall",
    "GB.CT" = "Coventry",
    "GB.DB" = "Derbyshire",
    "GB.DO" = "Devon",
    "GB.DC" = "Doncaster",
    "GB.DS" = "Dorset",
    "GB.DY" = "Dudley",
    "GB.EY" = "East Riding of Yorkshire",
    "GB.ES" = "East Sussex",
    "GB.EX" = "Essex",
    "GB.GL" = "Greater London",
    "GB.HA" = "Hampshire",
    "GB.HT" = "Hertfordshire",
    "GB.KN" = "Knowsley",
    "GB.BI" = "Birmingham",
    "GB.LC" = "Leicester",
    "GB.LE" = "Leicestershire",
    "GB.LI" = "Lincolnshire",
    "GB.MN" = "Manchester",
    "GB.MB" = "Middlesbrough",
    "GB.NU" = "Newcastle upon Tyne",
    "GB.NF" = "Norfolk",
    "GB.NL" = "North Lincolnshire",
    "GB.NS" = "North Somerset",
    "GB.NI" = "North Tyneside",
    "GB.NA" = "Northamptonshire",
    "GB.NB" = "Northumberland",
    "GB.NG" = "Nottingham",
    "GB.NT" = "Nottinghamshire",
    "GB.OX" = "Oxfordshire",
    "GB.PS" = "Portsmouth",
    "GB.RG" = "Reading",
    "GB.RC" = "Redcar and Cleveland",
    "GB.RD" = "Rochdale",
    "GB.RH" = "Rotherham",
    "GB.RL" = "Rutland",
    "GB.BT" = "Bolton",
    "GB.ZF" = "Salford",
    "GB.ZW" = "Sandwell",
    "GB.SE" = "Sefton",
    "GB.SP" = "Shropshire",
    "GB.ZL" = "Slough",
    "GB.SI" = "Solihull",
    "GB.SX" = "South Tyneside",
    "GB.ZH" = "Southampton",
    "GB.ST" = "Staffordshire",
    "GB.SK" = "Stockport",
    "GB.SO" = "Stoke-on-Trent",
    "GB.SD" = "Sunderland",
    # Scotland
    "GB.NR" = "North Ayrshire",
    # Wales
    "GB.GD" = "Gwynedd",
    "GB.MT" = "Merthyr Tydfil",
    "GB.NP" = "Newport",
    "GB.SW" = "Swansea",
    "GB.TF" = "Torfaen",
    "GB.VG" = "Vale of Glamorgan",
    "GB.WX" = "Wrexham",
    "GB.BG" = "Bridgend",
    "GB.BJ" = "Blaenau Gwent",
    "GB.DI" = "Denbighshire"
  )

  # Fix literal "NA" entries (and true NA) using HASC_2 lookup
  is_na_str <- is.na(sf_data$NAME_2) | sf_data$NAME_2 == "NA"
  if (any(is_na_str)) {
    sf_data$NAME_2[is_na_str] <- hasc_lookup[sf_data$HASC_2[is_na_str]]
  }

  # Clean camel-case formatting: insert space before each capital following a lower
  sf_data$NAME_2 <- gsub("([a-z])([A-Z])", "\\1 \\2", sf_data$NAME_2)

  # Fix specific compound preposition names that camel-case regex misses.
  # These are known GADM patterns — explicit substitutions avoid breaking
  # real words like "Shetland", "Northumberland", "Sunderland".
  sf_data$NAME_2 <- gsub("Blackburnwith", "Blackburn with", sf_data$NAME_2)
  sf_data$NAME_2 <- gsub("Kingstonupon", "Kingston upon", sf_data$NAME_2)
  sf_data$NAME_2 <- gsub("Brightonand", "Brighton and", sf_data$NAME_2)
  sf_data$NAME_2 <- gsub("Telfordand", "Telford and", sf_data$NAME_2)
  sf_data$NAME_2 <- gsub("Isleof", "Isle of", sf_data$NAME_2)
  sf_data$NAME_2 <- gsub("Islesof", "Isles of", sf_data$NAME_2)
  sf_data$NAME_2 <- gsub("Argylland", "Argyll and", sf_data$NAME_2)
  sf_data$NAME_2 <- gsub("Dumfriesand", "Dumfries and", sf_data$NAME_2)
  sf_data$NAME_2 <- gsub("Perthand", "Perth and", sf_data$NAME_2)
  sf_data$NAME_2 <- gsub("Cityof", "City of", sf_data$NAME_2)
  # Clean double spaces from chained fixes

  sf_data$NAME_2 <- gsub("\\s+", " ", trimws(sf_data$NAME_2))

  # Remove trailing ", County of" / ",Countyof" suffixes
  sf_data$NAME_2 <- gsub(",\\s*County\\s*of$|,Countyof$", "", sf_data$NAME_2)

  # Remove trailing ", City of" / ",Cityof" suffixes
  sf_data$NAME_2 <- gsub(",\\s*City\\s*of$|,Cityof$", "", sf_data$NAME_2)

  # Fix specific truncated/malformed multi-word names
  sf_data$NAME_2 <- gsub(
    "Bournemouth,\\s*Christchurch and Po$",
    "Bournemouth, Christchurch and Poole",
    sf_data$NAME_2
  )

  sf_data
}
