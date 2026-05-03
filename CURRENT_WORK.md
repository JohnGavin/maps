# Current Work

## Status: 5-tab dashboard deployed. Snapshot tests in place.

## Live Site
- Dashboard: https://johngavin.github.io/maps/vignettes/articles/dashboard.html
- Tabs: Ireland, England, Scotland, Wales, Great Britain

## Open Issues
- JohnGavin/maps#1 — T language evaluation (TBD)
- JohnGavin/maps#2 — Layout fixes (partially addressed)
- JohnGavin/maps#3 — Coastline regression (fixed, snapshot test added)
- JohnGavin/maps#4 — Legend clipping (partially addressed)

## Next Session
1. Add snapshot regression tests for England/Scotland/Wales
2. Cache pre-computed region data to speed up dashboard render
3. Deduplicate inline helpers (Phase 4: replace with library(maps) calls)
4. Consider OSM deep hierarchy for Ireland (baronies, parishes)
5. Resolve legend clipping edge cases (#4)
6. Consider parameterized QMD template (Phase 3 of plan)
