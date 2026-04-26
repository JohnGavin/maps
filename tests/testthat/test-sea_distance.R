test_that("compute_sea_distance returns integer sea_distance column", {
  # Create simple test geometry: 3 squares in a row
  # [coastal] - [inland1] - [inland2]
  s1 <- sf::st_polygon(list(matrix(c(0,0, 1,0, 1,1, 0,1, 0,0), ncol = 2, byrow = TRUE)))
  s2 <- sf::st_polygon(list(matrix(c(1,0, 2,0, 2,1, 1,1, 1,0), ncol = 2, byrow = TRUE)))
  s3 <- sf::st_polygon(list(matrix(c(2,0, 3,0, 3,1, 2,1, 2,0), ncol = 2, byrow = TRUE)))

  counties <- sf::st_sf(
    name = c("coastal", "inland1", "inland2"),
    geometry = sf::st_sfc(s1, s2, s3)
  )


  # Coastline along left edge of s1
  coast <- sf::st_sf(
    geometry = sf::st_sfc(sf::st_linestring(matrix(c(0,0, 0,1), ncol = 2, byrow = TRUE)))
  )

  result <- compute_sea_distance(counties, coast)

  expect_true("sea_distance" %in% names(result))
  expect_type(result$sea_distance, "integer")
  expect_equal(result$sea_distance, c(0L, 1L, 2L))
})

test_that("summarise_sea_distance returns correct counts", {
  df <- sf::st_sf(
    sea_distance = c(0L, 0L, 1L, 2L),
    geometry = sf::st_sfc(
      sf::st_point(c(0, 0)),
      sf::st_point(c(1, 0)),
      sf::st_point(c(2, 0)),
      sf::st_point(c(3, 0))
    )
  )
  result <- summarise_sea_distance(df)
  expect_equal(result$sea_distance, c(0L, 1L, 2L))
  expect_equal(result$n, c(2L, 1L, 1L))
})
