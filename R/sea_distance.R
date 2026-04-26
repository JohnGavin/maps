#' Compute Sea Distance for Counties
#'
#' Classify counties by their graph distance from the sea.
#' Distance 0 = touches the sea, distance 1 = neighbour of a coastal county, etc.
#'
#' @param counties An sf object of county polygons.
#' @param coastline An sf linestring of coastlines.
#' @return The input sf object with an added `sea_distance` integer column.
#' @export
compute_sea_distance <- function(counties, coastline) {
  # Build adjacency graph
  nb <- sfdep::st_contiguity(counties)
  adj_matrix <- sfdep::st_nb_as_matrix(nb)

  # Create igraph from adjacency
  g <- igraph::graph_from_adjacency_matrix(adj_matrix, mode = "undirected",
                                            diag = FALSE)

  # Identify coastal counties (distance 0)
  coastal <- lengths(sf::st_intersects(counties, coastline)) > 0
  coastal_idx <- which(coastal)

  # BFS from all coastal counties simultaneously
  n <- nrow(counties)
  dist <- rep(NA_integer_, n)
  dist[coastal_idx] <- 0L

  # Use igraph shortest paths from coastal nodes
  if (length(coastal_idx) > 0 && length(coastal_idx) < n) {
    sp <- igraph::distances(g, v = coastal_idx)
    min_dist <- apply(sp, 2, min)
    dist <- as.integer(min_dist)
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
