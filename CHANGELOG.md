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

- Created Quarto dashboard: 2-page leaflet choropleth + summary table/bar chart
- Fixed nix environment: udunits -std=gnu89 overlay + R_LIBS_SITE shellHook isolation
- All core packages now load in nix shell: sf, giscoR, igraph, dplyr
- Added index.qmd and _quarto.yml (docs/ output for gh-pages)

### Failed Approaches
- udunits on Apple Silicon: K&R C function definitions rejected by Clang C17 default. Fixed with -std=gnu89 overlay.
- R segfault on library(sf) in nested nix-shell: R_LIBS_SITE ABI contamination from outer shell. Fixed with shellHook rebuilding paths from derivation closure.
- NOTE: Running `Rscript default.R` will overwrite the manual nix patches. Must re-apply after regeneration.

- Implemented true 32 Irish counties via GADM: 26 ROI (level 1) + 6 NI (dissolved from 26 district councils)
- Rendered and deployed dashboard to gh-pages: https://johngavin.github.io/maps/
- Dashboard shows interactive leaflet choropleth with sea-distance colouring

### Failed Approaches (continued)
- giscoR NUTS3 gives only 8 Irish planning regions, not 32 counties. GADM via direct URL is the solution.
- giscoR LAU gives 166 Irish local electoral areas, not counties.
- No standard dataset has pre-built 6 traditional NI counties — 2015 reform replaced them with 11 councils everywhere. Dissolving GADM level 3 districts via lookup table works.
- `gisco_get_coastallines(year = 2021)` fails — only years 2006/2010/2013/2016 available. Changed to 2016.
- Multi-line `!expr paste0(...)` in Quarto `fig-cap` causes YAML parse error. Pre-compute captions in setup chunk.
- `orientation: pages` not valid in Quarto dashboard format. Changed to `orientation: rows`.

## 2026-04-27 to 2026-05-03

### Completed
- Multi-country dashboard: Ireland, England, Scotland, Wales, Great Britain (single page, tabbed)
- Parameterized R functions: `crs_projected` arg, generic `get_country_boundaries(iso3, level)`
- Fixed sea-distance bug: GISCO coastline polygons→boundary linestrings (was all-coastal)
- Fixed island bug: `Inf→0` for disconnected coastal islands (Orkney, Shetland, IoW)
- Fixed GADM GBR name quality: 78-entry HASC→name lookup + camel-case cleaning
- DT::datatable() for neighbour + summary tables (sortable, filterable)
- Dark theme: black background plots, white captions, DarkMatter tiles, legend contrast CSS
- Base R `%||%` cached fallback on ALL remote fetches (GADM + GISCO)
- Cached boundary data in inst/extdata/ (1.2MB: IRL_1, GBR_2, GBR_3, coastline)
- Ireland snapshot regression test (18 coastal counties, all 32 distances verified)
- Coastline resolution sanity check: warns if <30% counties detected as coastal
- Raised issues: #2 (layout), #3 (coastline regression), #4 (legend clipping)
- Tagged v0.1.0-ireland as revert point

### Failed Approaches
- GISCO coastline res "03" returned 404 (transient). Fell back to res "20" which lost Leitrim + Limerick. Fixed by restoring "03" when API recovered + adding cached fallback.
- GADM GBR level 2: 67 rows have NAME_2 = literal string "NA", 1 row has all fields NA (junk). Fixed with HASC lookup + drop junk rows.
- Leaflet legend bottomright overlapped by adjacent table column. Moved to topleft.
- Leaflet legend bottomleft clipped at plot edge. Moved to topleft with CSS margin.
- Markdown `[text](url)` links in kable captions render as literal text. Changed to `<a href>` HTML tags.

## 2026-05-04 to 2026-05-06

### Completed
- UK snapshot regression tests: England (115 counties), Scotland (32), Wales (22) — 24 new assertions
- Deduplicated dashboard: removed ~236 lines of inline helpers, now uses `pkgload::load_all()`
- Fixed GADM name cleaning: "Blackburn with Darwen", "Brighton and Hove", "Kingston upon Hull",
  "Isle of Wight", "Argyll and Bute", "City of Edinburgh" etc. (12 preposition substitutions)
- Fixed GADM England polygon gaps (#5): new `buffer_m` param (10km for UK, 200m for Ireland)
  - Blackburn with Darwen: distance 4→2 (correct per Wikipedia geography)
  - Herefordshire: distance 4→3
- Wider coastline cache (bbox ymin 51→49) covers Isles of Scilly
- Raised issues: #5 (GADM gaps), #6 (new country checklist + alternative distance metrics)

### Failed Approaches
- Regex `([a-z])(and)([A-Z ])` for preposition fixing broke "Shetland" → "Shetl and". Fixed with explicit substitutions per compound name instead of generic regex.
- 200m buffer insufficient for GADM GBR level 2 (gaps up to 28km between UAs and county councils). Fixed with 10km buffer.
- `here::here()` in `pkgload::load_all()` failed during quarto render. Fixed with `rprojroot::find_root("DESCRIPTION")`.

### Accuracy / Metrics
- Tests: 36 passing [ FAIL 0 | WARN 4 | SKIP 0 | PASS 36 ]
- Ireland: 7 snapshot assertions (18 coastal, all 32 distances, Laois=2)
- England: 8 assertions (115 counties, 47 coastal, max distance now 3 with 10km buffer)
- Scotland: 8 assertions (32 councils, 26 coastal, max distance 1)
- Wales: 8 assertions (22 authorities, 15 coastal, max distance 2)

### Known Limitations
- OSM deep hierarchy (baronies, parishes, townlands) not yet implemented
- Belfast assigned to County Antrim (straddles Antrim/Down but canonically Antrim)
- Running `Rscript default.R` overwrites manual nix patches (udunits + shellHook)
- GADM GBR level 2 name quality: 78+ entries require manual HASC lookup — fragile if GADM updates
- 10km buffer for UK may create false adjacencies for very small UAs
- UK snapshot tests use default buffer_m (200) not dashboard buffer (10000) — values may differ
- T language integration TBD (JohnGavin/maps#1)
- Legend clipping in some viewports (JohnGavin/maps#4)
- New country validation checklist documented in JohnGavin/maps#6
