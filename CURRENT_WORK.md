# Current Work

## Status: Core R functions working, tests pass. Dashboard pending.

## Completed
- [x] Package skeleton (DESCRIPTION, LICENSE, .gitignore)
- [x] default.R + default.nix via rix (R 4.5.3)
- [x] R/get_boundaries.R (giscoR NUTS levels)
- [x] R/sea_distance.R (sf::st_touches + igraph BFS)
- [x] Tests pass: [ FAIL 0 | WARN 0 | SKIP 0 | PASS 5 ]
- [x] NAMESPACE + man pages generated
- [x] GitHub repo: https://github.com/JohnGavin/maps
- [x] Issue #1: T language evaluation

## Next Steps
1. Fix nix shell (udunits regression on Apple Silicon — try later nixpkgs pin)
2. Implement deeper OSM hierarchy (baronies, parishes) via osmdata
3. Build Quarto dashboard with leaflet maps showing Ireland hierarchy
4. Add sea-distance visualization (colour counties by distance 0/1/2)
5. Deploy to gh-pages
6. Resolve JohnGavin/maps#1 (T language decision)

## R Package Versions Needed (ctx tracking)
| Package | Purpose | Status |
|---------|---------|--------|
| sf | Geometry engine | In DESCRIPTION Imports |
| giscoR | NUTS/LAU boundaries | In DESCRIPTION Suggests |
| igraph | BFS graph traversal | In DESCRIPTION Imports |
| osmdata | Deep OSM hierarchy | In DESCRIPTION Suggests |
| leaflet | Interactive maps | In DESCRIPTION Suggests |
| dplyr | Data wrangling | In DESCRIPTION Imports |
| quarto | Dashboard rendering | In default.R |
| sfdep | ~~Spatial adjacency~~ | REMOVED — sf::st_touches sufficient |

## Architecture
- `R/get_boundaries.R` — fetch Ireland admin boundaries via giscoR (NUTS levels)
- `R/sea_distance.R` — adjacency graph via sf::st_touches + BFS via igraph
- `tests/testthat/test-sea_distance.R` — unit tests for distance computation
- Dashboard: Quarto format with leaflet, deployed to gh-pages (TBD)

## Known Issues
- Nix shell build fails: udunits compile error on Apple Silicon (nixpkgs 2026-04-22 pin)
- giscoR NUTS3 gives 8 Irish regions, not 32 counties — may need GADM or OSM for true county level
