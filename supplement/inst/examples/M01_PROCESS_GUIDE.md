# M01: a rank is not a fraction selected

Run `Rscript supplement/inst/examples/m01-process-figure.R` from the repository root. Install the declared optional `ragg` package if needed for this PNG entry point.

The chapter supplies the probabilities: scores 0, 1, 2, 3 have masses .10, .20, .40, .30. They are assumptions for a synthetic example, not estimated patient or norming data. Counts out of 100 illustrate these proportions; they are not a sampled dataset.

First, `m01_process_data()` adds the masses in score order. Inclusive rank counts through the score, strict rank counts below it, and midpoint rank adds half the category mass to the strict rank. All three ranks are recorded for all four categories. Integer percentages avoid rounding at the cutoff in this example.

Next, each category's rank is compared with 5%, including equality. A selected category contributes its entire probability to the flagged population fraction. Summing those contributions gives the achieved fraction. Rank and flagged fraction must be calculated separately.

For score 0, inclusive rank 10% exceeds the cutoff. Midpoint rank 5% and strict rank 0% both meet it. The whole category contains 10% of people, so both latter rules flag 10%. No other category passes. Assigning a midpoint rank does not randomize or divide the category's members. Replacing “at most” with “strictly below” would change the midpoint result in this example.

The outputs directory retains all-category decisions, result summaries, source probabilities, three panel images, grayscale checks, composite PNG/PDF, alt text, caption, provenance and session information. The HTML chapter uses separate panels so they stack on narrow screens. PDF is a secondary vector master with its recorded Helvetica font fallback.

Figure: `fig-m01-rank-flagging`; section: `sec-m01-flagging`. Reproduction checks compare this arithmetic with independent exact rational calculations. This demonstrates reference-population flagging under a known law; it does not calculate disease sensitivity or estimation error in a fitted CDF.
