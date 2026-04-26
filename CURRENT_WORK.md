# Current Work

## Status: Package skeleton created, pending nix env + GitHub setup

## Next Steps
1. Generate default.nix via `nix-shell ~/docs_gh/rix.setup/default.nix --run "Rscript default.R"`
2. Build nix shell and verify packages load
3. Run `devtools::document()` to generate NAMESPACE + man pages
4. Create GitHub repo (`gh repo create JohnGavin/maps --public`)
5. Initial commit + push
6. Raise GitHub issue: T language for Python pipeline nodes
7. Implement deeper OSM hierarchy (baronies, parishes) via osmdata
8. Build Quarto dashboard with leaflet maps
9. Deploy to gh-pages

## R Package Versions Needed (ctx tracking)
| Package | Purpose | Status |
|---------|---------|--------|
| sf | Geometry engine | In default.R |
| giscoR | NUTS/LAU boundaries | In default.R |
| sfdep | Spatial adjacency | In default.R |
| igraph | BFS graph traversal | In default.R |
| osmdata | Deep OSM hierarchy | In default.R |
| leaflet | Interactive maps | In default.R |
| dplyr | Data wrangling | In default.R |
| quarto | Dashboard rendering | In default.R |

## Architecture
- `R/get_boundaries.R` — fetch Ireland admin boundaries via giscoR (NUTS levels)
- `R/sea_distance.R` — adjacency graph + BFS for coastal proximity
- `tests/testthat/test-sea_distance.R` — unit tests for distance computation
- Dashboard: Quarto format with leaflet, deployed to gh-pages
