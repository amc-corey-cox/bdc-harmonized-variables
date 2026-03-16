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
| ARIC | phs000280 | v8 | `ARIC/ARIC-v8/` | 101 |
| CARDIA | phs000285 | v3 | `CARDIA/CARDIA-v3/` | 66 |
| CHS | phs000287 | v7 | `CHS/CHS-v7/` | 82 |
| COPDGene | phs000179 | v6 | `COPDGene/COPDGene-v6/` | 36 |
| FHS | phs000007 | v35 | `FHS/FHS-v35/` | 124 |
| HCHS/SOL | phs000810 | v2 | `HCHS/HCHS-v2/` | 60 |
| JHS | phs000286 | v7 | `JHS/JHS-v7/` | 82 |
| MESA | phs000209 | v13 | `MESA/MESA-v13/` | 103 |
| WHI | phs000200 | v12 | `WHI/WHI-v12/` | 65 |

## Upstream Source

Trans-specs are sourced from the `<COHORT>-ingest/` directories in [RTIInternational/NHLBI-BDC-DMC-HV](https://github.com/RTIInternational/NHLBI-BDC-DMC-HV) (`priority_variables_transform/`). These directories are the consolidated single source of truth upstream, containing both hand-curated and pipeline-generated specs.

## Longitudinal Status

FHS-v35 is the only cohort fully implemented with longitudinal support (participant-specific uuid5 visit identifiers, `age_at_observation` from cross-table PHV lookups). All other cohorts use static visit strings (e.g., `value: CARDIA YEAR 7`) without participant-specific visit IDs.

| Cohort | Visit style | age_at_observation coverage |
|--------|-------------|---------------------------|
| FHS-v35 | uuid5 per participant | ~28% of blocks |
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

Some upstream trans-specs have systematic bugs from the YAML generator that were fixed on import:

- **Missing underscores:** `populated from:` and `class derivations:` instead of `populated_from:` / `class_derivations:` — invalid keys that cause silent data loss in linkml-map
- **Empty age placeholders:** `expr: {} * 365` and `expr: {nan} * 365` — emitted when no age PHV mapping exists for a table. These have been commented out pending upstream resolution.
- **Unquoted expressions:** `expr: {phv...} * 365` without quotes breaks YAML parsing (YAML interprets `{` as a flow mapping). These were quoted on import.

## Versioning

This repo uses [CalVer](https://calver.org/) with the format `YYYY.MM-N` (e.g., `2026.03-1`). The `YYYY.MM` portion is the date of the release content and `-N` is a sequence number for multiple releases within the same month. Tags are applied to validated releases on `main`.

Release candidates use the suffix `-rcN` (e.g., `2026.03-2-rc1`) for testing against dependent repos. RC tags are transient and deleted once the final tag is created.

## Validation

```bash
pip install -e .
python validate_trans_specs.py
```

CI runs validation on every push and PR to `main`.
