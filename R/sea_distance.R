#' Compute Sea Distance for Counties
#'
#' Classify counties by their graph distance from the sea.
#' Distance 0 = touches the sea, distance 1 = neighbour of a coastal county, etc.
#'
#' ## Coastal Detection
#'
#' The `coastline` argument accepts either linestring geometries **or** polygon
#' geometries (as returned by `giscoR::gisco_get_coastallines()`).  When polygon
#' geometries are detected they are first converted to their exterior boundary
#' linestrings via `sf::st_boundary()`, then cropped to the bounding box of
#' `counties`, and finally dissolved into a single linestring with
#' `sf::st_union()`.  This prevents the "all counties coastal" bug that arises
#' when the raw polygon land-mass geometry spatially contains every county.
#'
#' ## Adjacency
#'
#' When `counties` has a geographic CRS (longitude/latitude or projected), the
#' adjacency matrix is built using a 200 m buffer in `crs_projected` to handle
#' the small coordinate gaps in GADM polygon boundaries that cause
#' `sf::st_touches()` to miss many shared edges.  For CRS-less synthetic
#' geometries (e.g. unit-square test data) `sf::st_touches()` is used directly.
#'
#' @param counties An sf object of county polygons (any CRS, or no CRS for
#'   planar test data).
#' @param coastline An sf object of coastlines — either LINESTRING/MULTILINESTRING
#'   geometries, or POLYGON/MULTIPOLYGON land-mass geometries (e.g. from
#'   `giscoR::gisco_get_coastallines()`).
#' @param crs_projected Integer. EPSG code for a projected (metre-based) CRS
#'   used to build the 200 m adjacency buffer. Default 3035L (ETRS89-LAEA),
#'   which covers all EU/UK countries. Use 2157L for Ireland-only datasets.
#' @return The input sf object with an added `sea_distance` integer column.
#' @export
compute_sea_distance <- function(counties, coastline, crs_projected = 3035L) {
  old_s2 <- sf::sf_use_s2()
  on.exit(sf::sf_use_s2(old_s2), add = TRUE)
  sf::sf_use_s2(FALSE)

  # ── Adjacency matrix ──────────────────────────────────────────────────────
  # st_touches() misses shared edges in GADM data due to tiny coordinate gaps.
  # Use a 200 m buffer in crs_projected when a geographic CRS is present.
  # For CRS-less planar geometries (unit-test synthetic data), fall back to
  # st_touches() which works correctly for exact-boundary tile data.
  has_crs <- !is.na(sf::st_crs(counties))
  if (has_crs) {
    counties_m  <- sf::st_transform(counties, crs_projected)
    counties_buf <- sf::st_buffer(counties_m, 200)
    nb_mat      <- sf::st_intersects(counties_buf, counties_m, sparse = FALSE)
    diag(nb_mat) <- FALSE
    adj_matrix  <- nb_mat * 1L
  } else {
    adj_matrix <- sf::st_touches(counties, sparse = FALSE) * 1L
  }

  # ── igraph from adjacency ─────────────────────────────────────────────────
  g <- igraph::graph_from_adjacency_matrix(adj_matrix, mode = "undirected",
                                            diag = FALSE)

  # ── Coastline preparation ─────────────────────────────────────────────────
  # giscoR::gisco_get_coastallines() returns POLYGON land-mass features, not
  # linestrings.  When all geometry types are POLYGON/MULTIPOLYGON, convert to
  # boundary linestrings first.  LINESTRING input is used as-is.
  coast_geom  <- sf::st_geometry(coastline)
  geom_types  <- unique(as.character(sf::st_geometry_type(coast_geom)))
  is_polygon_type <- all(geom_types %in% c("POLYGON", "MULTIPOLYGON"))

  if (is_polygon_type) {
    # Crop to counties bounding box (+ 1 degree buffer) before boundary
    # conversion to avoid processing global land masses unnecessarily.
    bbox_buf     <- sf::st_bbox(counties) + c(-1, -1, 1, 1)
    coast_cropped <- sf::st_crop(coastline, bbox_buf)
    coast_lines  <- sf::st_boundary(sf::st_geometry(coast_cropped))
    coastline_use <- sf::st_union(coast_lines)
  } else {
    coastline_use <- sf::st_union(sf::st_geometry(coastline))
  }

  # Reproject coastline to match counties CRS for intersection
  if (has_crs && !is.na(sf::st_crs(coastline_use))) {
    coastline_use <- sf::st_transform(coastline_use, sf::st_crs(counties))
  }

  # ── Identify coastal counties (distance 0) ───────────────────────────────
  coastal     <- lengths(sf::st_intersects(counties, coastline_use)) > 0
  coastal_idx <- which(coastal)

  # ── BFS from all coastal counties simultaneously ──────────────────────────
  n    <- nrow(counties)
  dist <- rep(NA_integer_, n)
  dist[coastal_idx] <- 0L

  if (length(coastal_idx) > 0 && length(coastal_idx) < n) {
    sp       <- igraph::distances(g, v = coastal_idx)
    min_dist <- apply(sp, 2, min)
    dist     <- as.integer(min_dist)
  } else if (length(coastal_idx) == n) {
    dist <- rep(0L, n)
  }

  counties$sea_distance <- dist
  counties
}

#' Summarise Sea Distance Counts
#'
#' Count counties at each sea distance level.
#'
#' @param counties An sf object with `sea_distance` column.
#' @return A data.frame with columns `sea_distance` and `n`.
#' @export
summarise_sea_distance <- function(counties) {
  dplyr::count(sf::st_drop_geometry(counties),
               .data$sea_distance,
               name = "n")
}

#' Compute County Neighbour Table
#'
#' For each county, compute the number of neighbours (counties sharing a
#' boundary), their names, and the total shared boundary length in km.
#'
#' Adjacency is detected using a 200 m buffer in `crs_projected` to handle
#' small coordinate gaps in GADM polygon boundaries that cause
#' `sf::st_touches()` to miss shared edges.
#'
#' @param counties An sf object of county polygons with a `county_name` column.
#' @param crs_projected Integer. EPSG code for a projected (metre-based) CRS
#'   used to build the 200 m adjacency buffer and measure boundary lengths.
#'   Default 3035L (ETRS89-LAEA), which covers all EU/UK countries.
#' @return A data.frame with columns:
#'   \describe{
#'     \item{county_name}{County name.}
#'     \item{n_neighbours}{Number of neighbouring counties.}
#'     \item{neighbour_names}{Comma-separated, alphabetically sorted neighbour names.}
#'     \item{boundary_length_km}{Total shared boundary length in km (rounded to 1 dp).}
#'   }
#'   Rows are ordered by decreasing `n_neighbours`, ties broken by decreasing
#'   `boundary_length_km`.
#' @export
compute_neighbour_table <- function(counties, crs_projected = 3035L) {
  stopifnot(
    "counties must be an sf object"           = inherits(counties, "sf"),
    "counties must have a county_name column" = "county_name" %in% names(counties)
  )

  old_s2 <- sf::sf_use_s2()
  on.exit(sf::sf_use_s2(old_s2), add = TRUE)
  sf::sf_use_s2(FALSE)

  counties_m <- sf::st_transform(counties, crs_projected)
  n          <- nrow(counties_m)

  # Neighbour detection via 200 m buffer
  counties_buf <- sf::st_buffer(counties_m, 200)
  nb_mat       <- sf::st_intersects(counties_buf, counties_m, sparse = FALSE)
  diag(nb_mat) <- FALSE

  results <- lapply(seq_len(n), function(i) {
    nb_idx   <- which(nb_mat[i, ])
    nb_names <- counties_m$county_name[nb_idx]

    # Shared boundary length: buffer county i boundary by 100 m, intersect
    # with each neighbour boundary, sum resulting line lengths.
    cb_i     <- sf::st_boundary(sf::st_geometry(counties_m)[i])
    cb_i_buf <- sf::st_buffer(cb_i, 100)

    total_km <- sum(vapply(nb_idx, function(j) {
      cb_j  <- sf::st_boundary(sf::st_geometry(counties_m)[j])
      inters <- tryCatch(
        sf::st_intersection(cb_i_buf, cb_j),
        error = function(e) NULL
      )
      if (is.null(inters) || all(sf::st_is_empty(inters))) return(0)
      sum(as.numeric(sf::st_length(inters)), na.rm = TRUE) / 1000
    }, numeric(1L)))

    data.frame(
      county_name        = counties_m$county_name[i],
      n_neighbours       = length(nb_idx),
      neighbour_names    = paste(sort(nb_names), collapse = ", "),
      boundary_length_km = round(total_km, 1L)
    )
  })

  out <- do.call(rbind, results)
  out[order(-out$n_neighbours, -out$boundary_length_km), ]
}
