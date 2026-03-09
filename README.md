# BDC Harmonized Variables

LinkML-Map transformation specifications for BDC harmonized variables.

## Overview

This repository contains transformation specification (trans-spec) YAML files across 9 cohorts, used by [dm-bip](https://github.com/linkml/dm-bip) to harmonize phenotypic variables from dbGaP studies into a common data model.

Upstream curation happens in [RTIInternational/NHLBI-BDC-DMC-HV](https://github.com/RTIInternational/NHLBI-BDC-DMC-HV). This repo adds versioned directory structure, enrichments (age fields, visit specs), and serves as the release gate for the pipeline.

## Structure

```
trans_specs/<COHORT>/<COHORT-version>/*.yaml
```

Each cohort directory contains one or more data version subdirectories named `<COHORT>-<version>`. The cohort prefix ensures directories are self-describing even when extracted in isolation (e.g., tar archives). Each version corresponds to the dbGaP dataset version the trans-specs target.

## Data Versions

| Cohort | phs | BDC Version | Directory | Files |
|--------|-----|-------------|-----------|-------|
| ARIC | phs000280 | v8 | `ARIC/ARIC-v8/` | 102 |
| CARDIA | phs000285 | v3 | `CARDIA/CARDIA-v3/` | 67 |
| CHS | phs000287 | v7 | `CHS/CHS-v7/` | 82 |
| COPDGene | phs000179 | v6 | `COPDGene/COPDGene-v6/` | 36 |
| FHS | phs000007 | v33 | `FHS/FHS-v33-base/` | 124 |
| FHS | phs000007 | v33 | `FHS/FHS-v33/` | 129 |
| FHS | phs000007 | v35 | `FHS/FHS-v35/` | 124 |
| HCHS/SOL | phs000810 | v2 | `HCHS/HCHS-v2/` | 60 |
| JHS | phs000286 | v7 | `JHS/JHS-v7/` | 85 |
| MESA | phs000209 | v13 | `MESA/MESA-v13/` | 103 |
| WHI | phs000200 | v12 | `WHI/WHI-v12/` | 65 |

### FHS Variants

- **`FHS/FHS-v33-base/`** — Exact upstream v1.0.0 baseline (no longitudinal additions). Used as a reference and for testing.
- **`FHS/FHS-v33/`** — Enriched v33 with `visit.yaml`, `person.yaml`, `age_at_*` fields, and expression fixes. Also includes 5 files from the stata pipeline.
- **`FHS/FHS-v35/`** — Upstream v35 with uuid5 longitudinal identifiers, updated PHV fields, and bug fixes.

## Upstream Sources

Trans-specs in this repo come from two distinct pipelines in [RTIInternational/NHLBI-BDC-DMC-HV](https://github.com/RTIInternational/NHLBI-BDC-DMC-HV):

### 1. Hand-curated (`priority_variables_transform/`)

The original trans-specs, manually curated per cohort. These are in `priority_variables_transform/<COHORT>/` (and `<COHORT>-ingest/` variants). All 9 cohorts have files here. This was the sole source for our initial import.

### 2. Stata/Python pipeline (`stata_gen_yaml/`)

A newer automated pipeline that generates trans-specs from Stata-curated mappings. Output is in `stata_gen_yaml/Output/<cohort>/good/` (Stata) and `stata_gen_yaml/Python/Output/<cohort>/good/` (Python port, ARIC only). A `fixed/` subdirectory contains corrected versions of files that needed post-generation fixes.

This pipeline currently covers ARIC, CARDIA, FHS, JHS, and WHI. It produces files with more longitudinal coverage (more visit blocks per variable) than the hand-curated versions, but has systematic YAML bugs from the generator (see [Known Issues](#known-issues)).

### What came from where

| Cohort | Hand-curated | Stata/Python pipeline | Notes |
|--------|--------------|-----------------------|-------|
| ARIC | 40 files | 62 files | Python port used where available |
| CARDIA | 64 files | 3 files | 2 more in upstream `fixed/` need reconciliation |
| CHS | 82 files | — | |
| COPDGene | 36 files | — | Has a separate `copdgene-linkml-map/` upstream |
| FHS | 124 base + enrichments | 5 files | v35 is fully longitudinal with uuid5 visits |
| HCHS/SOL | 60 files | — | |
| JHS | 31 files | 54 files | 3 more in upstream `fixed/` need reconciliation |
| MESA | 103 files | — | |
| WHI | 65 files | — | WHI stata output matched existing files |

## Longitudinal Status

FHS-v35 is the only cohort fully implemented with longitudinal support (participant-specific uuid5 visit identifiers, `age_at_observation` from cross-table PHV lookups). All other cohorts use static visit strings (e.g., `value: CARDIA YEAR 7`) without participant-specific visit IDs.

| Cohort | Visit style | age_at_observation coverage |
|--------|-------------|---------------------------|
| FHS-v35 | uuid5 per participant | ~28% of blocks |
| FHS-v33 | static strings | ~32% of blocks |
| ARIC | static strings | ~29% (many commented out — broken upstream placeholders) |
| JHS | static strings | ~39% (many commented out — broken upstream placeholders) |
| MESA | static strings | ~30% |
| CHS | static strings | ~10% |
| HCHS/SOL | static strings | ~36% |
| COPDGene | static strings | ~26% |
| CARDIA | static strings | <1% |
| WHI | static strings | 0% |

## Known Issues

### Upstream YAML generator bugs ([#376](https://github.com/RTIInternational/NHLBI-BDC-DMC-HV/issues/376))

Files from the stata/Python pipeline had systematic bugs that were fixed on import into this repo:

- **Missing underscores:** `populated from:` and `class derivations:` instead of `populated_from:` / `class_derivations:` — invalid keys that cause silent data loss in linkml-map
- **Empty age placeholders:** `expr: {} * 365` (610 occurrences) and `expr: {nan} * 365` (384 occurrences) — the generator emits these when no age PHV mapping exists for a table. These have been commented out pending upstream resolution.
- **Unquoted expressions:** `expr: {phv...} * 365` without quotes breaks YAML parsing (YAML interprets `{` as a flow mapping). These were quoted on import.

### Pending reconciliation

5 files in upstream `stata_gen_yaml/Output/*/fixed/` conflict with our curated versions and were not imported:

- **CARDIA:** `alcohol_servings.yaml` (upstream has more visits + aggregation expressions), `bdy_wgt.yaml` (upstream has fewer visits but adds `age_at_observation`)
- **JHS:** `albumin_urine.yaml`, `alcohol_servings.yaml`, `bnp.yaml` (upstream fixes broken age expressions, adds range_low/range_high, but our versions have curator edits)

## Versioning

This repo uses [CalVer](https://calver.org/) with the format `YYYY.MM` (e.g., `2026.02`). Tags are applied to releases on `main`.

## Validation

```bash
pip install -e .
python validate_trans_specs.py
```

CI runs validation on every push and PR to `main`.
