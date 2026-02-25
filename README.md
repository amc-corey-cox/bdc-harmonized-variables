# BDC Harmonized Variables

LinkML-Map transformation specifications for BDC harmonized variables.

## Overview

This repository contains transformation specification (trans-spec) YAML files across 9 cohorts, used by [dm-bip](https://github.com/linkml/dm-bip) to harmonize phenotypic variables from dbGaP studies into a common data model.

Upstream curation happens in [RTIInternational/NHLBI-BDC-DMC-HV](https://github.com/RTIInternational/NHLBI-BDC-DMC-HV). This repo adds versioned directory structure, enrichments (age fields, visit specs), and serves as the release gate for the pipeline.

## Structure

```
trans_specs/<COHORT>/<data_version>/*.yaml
```

Each cohort directory contains one or more data version subdirectories. Each version corresponds to the dbGaP dataset version the trans-specs target.

## Data Versions

| Cohort | phs | BDC Version | Directory | Files |
|--------|-----|-------------|-----------|-------|
| ARIC | phs000280 | v8 | `ARIC/v8/` | 40 |
| CARDIA | phs000285 | v3 | `CARDIA/v3/` | 64 |
| CHS | phs000287 | v7 | `CHS/v7/` | 82 |
| COPDGene | phs000179 | v6 | `COPDGene/v6/` | 36 |
| FHS | phs000007 | v33 | `FHS/v33-base/` | 124 |
| FHS | phs000007 | v33 | `FHS/v33/` | 124 |
| HCHS/SOL | phs000810 | v2 | `HCHS/v2/` | 60 |
| JHS | phs000286 | v7 | `JHS/v7/` | 31 |
| MESA | phs000209 | v13 | `MESA/v13/` | 103 |
| WHI | phs000200 | v12 | `WHI/v12/` | 65 |

### FHS Variants

- **`FHS/v33-base/`** — Exact upstream v1.0.0 baseline (no longitudinal additions). Used as a reference and for testing.
- **`FHS/v33/`** — Enriched version with `visit.yaml`, `person.yaml`, `age_at_*` fields, and expression fixes.

## Versioning

This repo uses [CalVer](https://calver.org/) with the format `YYYY.MM` (e.g., `2026.02`). Tags are applied to releases on `main`.

## Validation

```bash
pip install -e .
python validate_trans_specs.py
```

CI runs validation on every push and PR to `main`.
