# Current Work

## Status: Dashboard deployed to gh-pages with 32 Irish counties.

## Live Site
- Homepage: https://johngavin.github.io/maps/
- Dashboard: https://johngavin.github.io/maps/vignettes/articles/dashboard.html

## Completed
- [x] Package skeleton (DESCRIPTION, LICENSE, .gitignore)
- [x] default.R + default.nix via rix (R 4.5.3, patched for udunits + shellHook)
- [x] R/get_boundaries.R (GADM 32 counties: 26 ROI + 6 NI dissolved)
- [x] R/sea_distance.R (sf::st_touches + igraph BFS)
- [x] Tests pass: [ FAIL 0 | WARN 0 | SKIP 0 | PASS 5 ]
- [x] NAMESPACE + man pages generated
- [x] GitHub repo: https://github.com/JohnGavin/maps
- [x] Issue #1: T language evaluation
- [x] Nix environment fixed (udunits overlay + shellHook)
- [x] Quarto dashboard rendered and deployed to gh-pages
- [x] 32 traditional Irish counties (GADM, not NUTS3)

## Next Steps
1. Implement deeper OSM hierarchy (baronies, parishes, townlands) via osmdata
2. Add province-level map page to dashboard
3. Extend to other EU countries
4. Resolve JohnGavin/maps#1 (T language decision)
5. Add GitHub Actions CI for automated rendering

## Architecture
- `R/get_boundaries.R` — GADM 32 counties + giscoR NUTS for country/province
- `R/sea_distance.R` — adjacency graph via sf::st_touches + BFS via igraph
- `tests/testthat/test-sea_distance.R` — unit tests for distance computation
- `vignettes/articles/dashboard.qmd` — 2-page leaflet + summary dashboard
- `index.qmd` + `_quarto.yml` — Quarto website, output to docs/
- `docs/` — rendered site served by gh-pages
