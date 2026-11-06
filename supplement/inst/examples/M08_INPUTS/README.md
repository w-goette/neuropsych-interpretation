# M08 full-precision teaching inputs

All files are original constructed observations, not clinical norms or patient records. Scores use the units declared in the corresponding chapter experiment. Person/record IDs are artificial and do not link people across different experiments. No missing data are implied. Numerical values retain the original precision; fits should use these rows rather than six-decimal display cells.

| File | Fields | Experiment and units |
|---|---|---|
| factorial_records.csv | `time`, `exposure`, `formB`, `score` | Sixteen independent-person outcomes;binary time/exposure/formB are design codes,score is observed score points. |
| aliased_records.csv | `person`, `difference` | Eight independent paired-score differences;difference is in points;only the aliased sum is identified. |
| state-records.csv | `person`, `visit1`, `visit2`, `visit3`, `visit4` | 64 independent people with four retained visits;observed scores in common points,not latent components. |
| norm_observed.csv | `person`, `age_coordinate`, `score` | 12 independent reference people at fixed age coordinates;score points;no longitudinal pairing across ages. |
| personal_observed.csv | `time`, `score` | Six visits of one artificial person;time in years and score in points. |
| paired_records.csv | `person`, `baseline1`, `baseline2`, `retest1`, `retest2` | Eight independent paired-reference people,each with two baseline and retest coordinates;score points. |
| marginal_paired_records.csv | `baseline1`, `baseline2`, `retest1`, `retest2` | Six separate paired-reference people;two baseline/retest coordinates;the marginal difference experiment does not condition on baseline. |
| joint_observed_records.csv | `case_flag`, `person`, `occasion`, `W1`, `W2`, `item1`, `item2` | Four independent reference people and two occasions of the same case;W1/W2 are same-state anchor readings in anchored units;U1/U2 are binary responses. |
| trial_observed.csv | `person`, `treatment`, `baseline`, `followup` | 16 different randomized-arm people;binary treatment,baseline and followup in points;rows across arms are not pairs. |
| proxy_calibration_observed.csv | `repeat`, `W`, `Y` | Eight independent paired repetitions from the precision study;W/Y in points;pilot means unknown,transported error covariance assumed. |
| proxy_case_observed.csv | `W`, `Y` | One separate case with proxy W/current Y in points;not a new pilot row. |

The selected executable R examples are described in [M08_GUIDE.md](../M08_GUIDE.md). The complete [chapter](../../../../book/chapters/08-change.md) supplies the advanced likelihoods,priors and exact integral representations;not every such integration is packaged as an R entry point. All original teaching data follow the distribution’s author-selected license.
