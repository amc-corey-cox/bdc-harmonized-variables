# BDC Harmonized Variables

LinkML-Map transformation specifications for BDC harmonized variables.

## Overview

This repository contains 605 transformation specification (trans-spec) YAML files across 9 cohorts, used by [dm-bip](https://github.com/RTIInternational/dm-bip) to harmonize phenotypic variables from dbGaP studies into a common data model.

## Cohorts

| Cohort   | Files |
|----------|-------|
| ARIC     | 40    |
| CARDIA   | 64    |
| CHS      | 82    |
| COPDGene | 36    |
| FHS      | 124   |
| HCHS     | 60    |
| JHS      | 31    |
| MESA     | 103   |
| WHI      | 65    |

## Structure

Each file under `trans_specs/<COHORT>/` is a YAML list of `class_derivations` blocks that define how source variables map to harmonized target classes.

## Validation

```bash
pip install -e .
python validate_trans_specs.py
```

CI runs validation on every push and PR to `main`.
