# Current Work

## Status: Dashboard created, nix fixed. Ready to render and deploy.

## Completed
- [x] Package skeleton (DESCRIPTION, LICENSE, .gitignore)
- [x] default.R + default.nix via rix (R 4.5.3)
- [x] R/get_boundaries.R (giscoR NUTS levels)
- [x] R/sea_distance.R (sf::st_touches + igraph BFS)
- [x] Tests pass: [ FAIL 0 | WARN 0 | SKIP 0 | PASS 5 ]
- [x] NAMESPACE + man pages generated
- [x] GitHub repo: https://github.com/JohnGavin/maps
- [x] Issue #1: T language evaluation
- [x] Nix environment fixed (udunits overlay + shellHook)
- [x] Quarto dashboard created (2-page leaflet + summary)
- [x] index.qmd + _quarto.yml

## Next Steps
1. Render dashboard: `nix-shell default.nix --run "quarto render"`
2. Deploy docs/ to gh-pages
3. Implement deeper OSM hierarchy (baronies, parishes) via osmdata
4. Investigate NUTS3 vs true 32 counties (GADM or OSM needed)
5. Resolve JohnGavin/maps#1 (T language decision)

## R Package Versions Needed (ctx tracking)
| Package | Purpose | Status |
|---------|---------|--------|
| sf | Geometry engine | In DESCRIPTION Imports, nix OK |
| giscoR | NUTS/LAU boundaries | In DESCRIPTION Suggests, nix OK |
| igraph | BFS graph traversal | In DESCRIPTION Imports, nix OK |
| osmdata | Deep OSM hierarchy | In DESCRIPTION Suggests |
| leaflet | Interactive maps | In DESCRIPTION Suggests |
| dplyr | Data wrangling | In DESCRIPTION Imports, nix OK |
| quarto | Dashboard rendering | In default.R |

## Architecture
- `R/get_boundaries.R` — fetch Ireland admin boundaries via giscoR (NUTS levels)
- `R/sea_distance.R` — adjacency graph via sf::st_touches + BFS via igraph
- `tests/testthat/test-sea_distance.R` — unit tests for distance computation
- `vignettes/articles/dashboard.qmd` — 2-page leaflet dashboard
- `index.qmd` — site homepage
- `_quarto.yml` — website config (output to docs/)

## Known Issues
- Running `Rscript default.R` overwrites manual nix patches (udunits overlay + shellHook)
- giscoR NUTS3 gives 8 Irish regions, not 32 counties — need GADM or OSM for true county boundaries
