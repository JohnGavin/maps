# Changelog

## 2026-04-26

### Completed
- Initialized R package skeleton: DESCRIPTION, LICENSE, .gitignore
- Created R/ with `get_boundaries.R` (giscoR-based Ireland boundary fetching) and `sea_distance.R` (adjacency graph + BFS sea-distance computation)
- Created tests/testthat/test-sea_distance.R with unit tests for distance classification
- Created default.R for rix-based Nix environment (sf, giscoR, sfdep, igraph, leaflet, osmdata)
- Researched package stack: giscoR (NUTS/LAU), osmdata (deep hierarchy), sfdep (adjacency), igraph (BFS)

- Fixed `sea_distance.R`: replaced nonexistent `sfdep::st_nb_as_matrix()` with `sf::st_touches(sparse=FALSE) * 1L`
- Removed sfdep from Imports (unnecessary), moved giscoR to Suggests
- Generated NAMESPACE and man pages via roxygen2
- Created GitHub repo: https://github.com/JohnGavin/maps
- Pushed initial structure + bug fix
- Raised issue #1: Evaluate T language for Python pipeline nodes
- Generated default.nix via rix (R 4.5.3, pinned 2026-04-22)

### Failed Approaches
- `sfdep::st_nb_as_matrix()` does not exist in sfdep 0.2.5. Replaced with pure sf approach.
- Nix shell build fails: `udunits-unstable-2021-03-17` compile error on Apple Silicon (nixpkgs regression). Tests run via global shell R instead.
- rix `ide = "other"` deprecated in v0.15.0, replaced with `ide = "none"`
- rix `r_ver = "2025-04-14"` (date format) rejected, must use version string `"4.5.3"`

### Accuracy / Metrics
- Tests: 2 test cases, 5 assertions, all passing [ FAIL 0 | WARN 0 | SKIP 0 | PASS 5 ]

### Known Limitations
- Nix shell cannot build on Apple Silicon (udunits regression) — needs later nixpkgs pin
- OSM deep hierarchy (baronies, parishes, townlands) not yet implemented — giscoR covers NUTS0-3 only
- Quarto dashboard not yet created
- T language integration TBD (JohnGavin/maps#1)
