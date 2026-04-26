# Changelog

## 2026-04-26

### Completed
- Initialized R package skeleton: DESCRIPTION, LICENSE, .gitignore
- Created R/ with `get_boundaries.R` (giscoR-based Ireland boundary fetching) and `sea_distance.R` (adjacency graph + BFS sea-distance computation)
- Created tests/testthat/test-sea_distance.R with unit tests for distance classification
- Created default.R for rix-based Nix environment (sf, giscoR, sfdep, igraph, leaflet, osmdata)
- Researched package stack: giscoR (NUTS/LAU), osmdata (deep hierarchy), sfdep (adjacency), igraph (BFS)

### Failed Approaches
- None yet (greenfield project)

### Accuracy / Metrics
- Tests: 2 test cases written (not yet run, pending nix env build)

### Known Limitations
- NAMESPACE not yet generated (needs roxygen2 in nix shell)
- default.nix not yet generated (needs rix in nix shell)
- GitHub repo not yet created
- OSM deep hierarchy (baronies, parishes, townlands) not yet implemented — giscoR covers NUTS0-3 only
- T language integration TBD (issue to be raised)
