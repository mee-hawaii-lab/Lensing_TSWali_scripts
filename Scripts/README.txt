README — R ANALYSIS SCRIPTS
Tropical Storm Wali Impacts on He'eia Fishpond Physicochemistry and Microbial Communities
================================================================================

This file describes the 19 numbered R Markdown scripts used to produce the
data, statistics, and figures for the manuscript. Scripts are organized in
pipeline order: hydrodynamics/meteorology (01-02), physicochemistry (03-05),
16S bacterioplankton (06-11), 18S microeukaryotes (12-18), and cross-domain
coupling (19). Later scripts generally depend on outputs from earlier ones
within their own track (e.g., 07-11 depend on 06; 13-18 depend on 12-13).

--------------------------------------------------------------------------------
01_tidal_dynamics.rmd
--------------------------------------------------------------------------------
Purpose: Assigns tidal stage to every sampling event and characterizes
hydrodynamic behavior at He'eia Fishpond (HFP) relative to the open-ocean
NOAA reference station (Moku o Lo'e).

Key contents:
- Loads NOAA verified 6-min water levels and harmonic High/Low predictions;
  detects tidal extrema and classifies them as major/minor constituents of
  the mixed semi-diurnal tide.
- Loads in-pond CTD pressure data and independently detects local extrema
  (rolling-window peak detection), avoiding search-window bias from simply
  matching to NOAA event times.
- Assigns tidal stage (e.g., flood/ebb, high/low) to each sampling event and
  merges onto the full sample dataset.
- Computes moon phase, lunar perigee, and tidal regime (Spring/Neap) for
  every date in the CTD record.
- Storm Wali disruption analysis: propagation lag (NOAA -> HFP), per-cycle
  tidal excursion, asymmetric flux (flood vs. ebb rate), and residence/
  flushing time, each stratified by tidal regime and storm phase
  (Pre-storm/Storm/Post-storm).
- Builds Supplementary Table S3 (tidal dynamics summary: lag, flux,
  excursion, residence time) and runs associated statistical tests
  (Wilcoxon rank-sum for flood vs. ebb rates; nested Gamma GLMs with log
  link for storm effects on residence time).
- Assembles Figure S1 (5-panel combined tidal dynamics figure: continuous
  pressure traces, detided anomaly comparison, and lag/flux/residence
  boxplots by regime).
- Drafts supplementary Methods/Results/Discussion text with live-value
  handles pulled directly from the analysis objects.

Outputs feed: physicochemical tidal-stage matching (02, 05), Table S3,
Figure S1.

--------------------------------------------------------------------------------
02_hydromet_summary.rmd
--------------------------------------------------------------------------------
Purpose: Summarizes meteorological, hydrological, and CTD (temperature/
salinity/pressure/current) data around the storm window and quantifies
recovery timing.

Key contents:
- Helper functions for circular statistics (circular mean/SD, minimum
  circular difference) needed for wind and current direction data.
- A generalized "first recovery day" function: for each variable, finds the
  first post-storm date on which the daily mean falls back within the
  pre-storm mean ± 1 SD (scalar variables) or circular mean ± circular SD
  (directional variables).
- Processes NOAA buoy wind data, HIMB rain gauge, USGS stream gauge, and CTD
  salinity/temperature/pressure/current speed and direction.
- Computes absolute and fold-change values for each variable across storm
  phases.
- Re-derives tidal-stage matching (copied verbatim from 01_tidal_dynamics.rmd
  Sections 2a/2b, kept intentionally self-contained/duplicated for this
  notebook, with a note to update both if changed).

Outputs feed: the hydrometeorological narrative in the manuscript (storm
chronology, recovery timing) and cross-checks against Powell (2015).

--------------------------------------------------------------------------------
03_pchem_qc_imputation.rmd
--------------------------------------------------------------------------------
Purpose: Quality-control and gap-fill (imputation) of physicochemical (pchem)
field and lab data prior to spatial/summary analysis.

Key contents:
- Loads and reshapes raw YSI sonde and Hach kit nutrient data into long
  format.
- Two-stage flagging: Stage 1 (MAD-based outlier detection) and Stage 2
  (spatial leave-one-out IDW cross-validation), joined together for a
  combined flag per observation.
- Summarizes flags by variable, site, and date, and checks whether flagged
  values violate physical plausibility.
- Removes/overwrites flagged Hach values; YSI data passed through unchanged.
- IDW-based imputation of remaining missing values, with a summary of how
  many values were imputed per variable.
- Recombines with the OM2 (organic matter/nutrient) dataset for the matching
  date window and calculates molecular ratios (e.g., nutrient stoichiometry).
- Saves the final QC'd/imputed physicochemical dataset used by all
  downstream pchem scripts (04, 05).

--------------------------------------------------------------------------------
04_pchem_spatial_interpolation.rmd
--------------------------------------------------------------------------------
Purpose: Produces spatial (IDW) interpolation maps of physicochemical
variables across the fishpond for each sampling date.

Key contents:
- Loads sample site coordinates and fishpond shapefile.
- Runs inverse-distance-weighted (IDW) spatial interpolation for YSI sonde
  variables (temperature, salinity, DO, pH) and Hach kit nutrients (nitrate,
  nitrite, ammonia, phosphate, silica, turbidity).
- Builds and assembles heatmap panels for each variable/date into composite
  figures.
- Produces supplementary stoichiometric-ratio heatmaps (TIN:TIP, TIN:SiO2,
  SiO2:Salinity) with diverging color scales centered on ecologically
  meaningful reference points (e.g., Redfield ratio), including capping of
  extreme interpolated values and reporting of missing/capped-value counts.
- Saves final composite spatial figures (main and supplementary).

--------------------------------------------------------------------------------
05_pchem_summary_stats.rmd
--------------------------------------------------------------------------------
Purpose: Core statistical summary of physicochemistry across the full
nine/ten-date sampling record; the authoritative source for Table 1 and
associated Results/Discussion numbers.

Key contents:
- Tabulates regional x storm-phase summaries: means, SDs, percent change,
  medians, and ranges.
- Computes fold-changes relative to a defined pre-storm baseline.
- Calculates date of recovery (first date each variable returns to
  pre-storm range) and stratification metrics.
- Analyzes temporal and spatial variation in physicochemistry.
- Builds boxplot figures (Figure 4 house style: grey storm-date rectangle
  drawn first, capped-whisker boxplots, Dunn's test significance brackets)
  for YSI variables, log-transformed Hach nutrients, and stoichiometric
  ratios, using the full discrete-sampling date set (not just the five
  microbially co-registered dates).
- Uses Dunn's test (FSA::dunnTest, BH-corrected) as the Kruskal-Wallis
  post-hoc throughout.

Outputs feed: Table 1, Figure 4, and all physicochemical narrative claims in
Results/Discussion.

--------------------------------------------------------------------------------
06_s16_postprocessing.Rmd
--------------------------------------------------------------------------------
Purpose: Builds the master 16S (bacterioplankton) phyloseq object from raw
ASV count/taxonomy/sample tables and prepares it for all downstream 16S
analyses.

Key contents:
- Loads count table, SILVA taxonomy table, and sample metadata; recodes
  date-group (DM) values to canonical labels (Pre/Storm/Post, etc.) and sets
  factor levels.
- Subsets, filters, and transforms the phyloseq object (e.g., prevalence/
  abundance filtering).
- Explores subsampling (rarefaction) depth options, plots sequence-depth
  distributions, flags samples below chosen thresholds, and subsamples to a
  common depth.
- Exports finalized OTU/ASV tables used by scripts 07-11.

--------------------------------------------------------------------------------
07_s16_alpha_diversity.Rmd
--------------------------------------------------------------------------------
Purpose: Alpha diversity analysis for 16S bacterioplankton communities.

Key contents:
- Loads the normalized ASV table from 06.
- Calculates Hill-number alpha diversity (⁰D richness, ¹D Shannon-equivalent,
  ²D Simpson-equivalent).
- Runs statistical comparisons across dates/regions/storm phases.
- Saves alpha diversity plots and summary tables used in the manuscript's
  16S results and Figure panels.

--------------------------------------------------------------------------------
08_s16_beta_diversity.Rmd
--------------------------------------------------------------------------------
Purpose: Beta diversity, ordination, and community-environment coupling
analysis for 16S bacterioplankton — the most analytically dense 16S script.

Key contents:
- Calculates beta diversity (Bray-Curtis/Hellinger-based) and runs PERMANOVA.
- nMDS ordination, taxa biplot, and environmental-variable biplot.
- Beta-dispersion (homogeneity of multivariate dispersions) testing.
- "Recovery distance" analysis: distance of each sample to its own site's
  pre-storm centroid over time, with Friedman rank-sum and pairwise Wilcoxon
  signed-rank tests (with significance brackets) to assess trajectory back
  toward baseline.
- Distance-based linear modeling (dbRDA-style) of assemblage structure.
- Mantel test (community vs. environment).
- Multiple Procrustes analyses: global community-environment concordance
  (with Dunn's post-hoc pairwise tests on residuals), dynamic/stepwise
  procrustes between consecutive date pairs (assemblage reorganization),
  dynamic temporal environment-community coupling, and global temporal
  continuity of assemblage composition.
- Variance partitioning of the assemblage matrix by explanatory matrices.

Outputs feed: 16S beta-diversity figures/statistics reported in Results and
compared against the 18S equivalents (15) and cross-domain synthesis (19).

--------------------------------------------------------------------------------
09_s16_community_composition.Rmd
--------------------------------------------------------------------------------
Purpose: Taxonomic composition summaries and stacked barplot for 16S.

Key contents:
- Builds relative-abundance summary tables at multiple taxonomic ranks and
  exports them to Excel.
- Customized tabulations exploring specific taxa of interest (Archaea,
  Alphaproteobacteria, Gammaproteobacteria, Flavobacteriia), including the
  Saprospiraceae reclassification (post-storm increaser, not stable
  baseline degrader).
- Builds the stacked composition barplot (sites ordered by region, custom
  color palette/legend) and saves it to file.

--------------------------------------------------------------------------------
10_s16_disturbance_response.Rmd
--------------------------------------------------------------------------------
Purpose: Classifies ASV-level disturbance responses and quantifies
resilience/turnover for 16S — produces Table 2 (ASV fate classification).

Key contents:
- Assigns each ASV a fate category (Persistent, Recovered, Displaced,
  Introduced, Transient, Post-storm arrival) based on presence/absence
  across storm phases.
- Plots abundance share by fate x date and per-fate abundance trajectories
  (median trajectory per fate, log-scale with floored zeros).
- Abundance-based resilience: custom functions to calculate percent change,
  count valid comparisons, run Wilcoxon tests, and compute effect sizes per
  ASV/genus across the disturbance.
- Membership-based resilience and turnover: presence/absence matrices,
  prevalence filtering, pairwise Jaccard beta diversity partitioned into
  turnover (species replacement) and nestedness (gain/loss) components,
  computed pairwise between storm phases.
- Tabulates storm-introduced ASVs: how many appear during the storm, their
  relative abundance, and how many persist one and two weeks later.
- Species Indicator Analysis (indicspecies::multipatt, generalized IndVal.g)
  identifying ASVs/genera significantly associated with single dates or
  date combinations.

Outputs feed: Table 2, 16S disturbance/resilience figures, and indicator
taxa reported in Results.

--------------------------------------------------------------------------------
11_s16_figure_assembly.Rmd
--------------------------------------------------------------------------------
Purpose: Assembles final composite 16S figures from objects generated in
07-10.

Key contents:
- Combines alpha and beta diversity panels into the main diversity figure.
- Builds the composition heatmap (log-abundance, genus-level, with
  dendrogram-matched column ordering; row-wise z-scoring available but
  currently disabled).
- Builds the "taxa response" main figure and an associated supplemental
  figure.
- Uses a shared `patchwork`/`theme_panel()` styling convention consistent
  with the 18S figure-assembly script (18) for visual parity between
  domains.

--------------------------------------------------------------------------------
12_s18_classify_pr2.Rmd
--------------------------------------------------------------------------------
Purpose: Taxonomic classification of 18S OTU representative sequences
against the PR2 v5.1.1 reference database using mothur (classify.seqs).

Key contents:
- Defines paths to the gzipped PR2 reference files, the C-MAIKI OTU
  representative sequences (input), and the mothur executable.
- Decompresses reference files as needed (safe to re-run; skips gunzip if
  already decompressed) and sanity-checks that both files exist.
- Runs mothur's classify.seqs with defined parameters.
- Documents output files, which feed into 13_s18_postprocessing.Rmd for the
  PR2 genus-backfill correction described in project conventions
  (genus == family filter + informal clade pattern masking, applied
  immediately after tax_glom()).

--------------------------------------------------------------------------------
13_s18_postprocessing.Rmd
--------------------------------------------------------------------------------
Purpose: Builds the master 18S (microeukaryote) phyloseq object, parallel to
06 for 16S, with 18S-specific filtering considerations.

Key contents:
- Loads count table, PR2 taxonomy table, and sample metadata; recodes date
  groups and sets factor levels.
- Subsets and filters, including a note on Cryptista handling (Cryptista
  nucleomorphs are a red-algal endosymbiont remnant, taxonomically distinct
  from the Cryptista 18S gene signal, and are treated accordingly in
  filtering).
- Transforms and subsamples (rarefies) to a common depth after exploring
  subsampling-level tradeoffs.
- Exports finalized OTU tables used by 14-18.

--------------------------------------------------------------------------------
14_s18_alpha_diversity.Rmd
--------------------------------------------------------------------------------
Purpose: Alpha diversity analysis for 18S microeukaryotic communities
(structurally parallel to 07).

Key contents:
- Loads normalized OTU table from 13.
- Calculates Hill-number alpha diversity (⁰D/¹D/²D).
- Runs statistical comparisons and saves plots/summary tables.
- Source of the "no significant change" 18S alpha-diversity framing flagged
  as an open item for the abstract.

--------------------------------------------------------------------------------
15_s18_beta_diversity.Rmd
--------------------------------------------------------------------------------
Purpose: Beta diversity, ordination, and community-environment coupling for
18S microeukaryotes (structurally parallel to 08).

Key contents: Same analytical structure as 08_s16_beta_diversity.Rmd —
PERMANOVA, nMDS/taxa/environmental biplots, beta-dispersion testing,
recovery-distance-to-centroid analysis with Friedman/Wilcoxon tests,
distance-based linear modeling, Mantel test, global and dynamic Procrustes
analyses (community-environment and temporal continuity), and variance
partitioning — applied to the 18S OTU table instead of 16S ASVs.

Outputs feed: 18S beta-diversity results, and (together with 08) the inputs
to cross-domain coupling (19).

--------------------------------------------------------------------------------
16_s18_community_composition.Rmd
--------------------------------------------------------------------------------
Purpose: Taxonomic composition summaries and stacked barplot for 18S
(structurally parallel to 09).

Key contents:
- Relative-abundance summary tables by rank, exported to Excel.
- Customized tabulations exploring taxa of interest, including corrected
  ecological framing for Gambierdiscus (thecate, autotrophic, epibenthic —
  not athecate/oligotrophic/bacterivore as in an earlier draft).
- Stacked composition barplot (region-ordered sites, custom palette),
  saved to file.

--------------------------------------------------------------------------------
17_s18_disturbance_response.Rmd
--------------------------------------------------------------------------------
Purpose: Classifies OTU-level disturbance responses and quantifies
resilience/turnover for 18S (structurally parallel to 10) — produces the
18S OTU fate classification table.

Key contents: Same structure as 10_s16_disturbance_response.Rmd — fate
classification (Persistent/Recovered/Displaced/Introduced/Transient/
Post-storm arrival), abundance-share and trajectory plots, abundance-based
resilience testing (Wilcoxon per OTU/genus), membership-based
resilience/turnover (Jaccard partitioned into turnover and nestedness),
tabulation of storm-introduced OTUs and their persistence, and Species
Indicator Analysis (multipatt/IndVal.g) — applied to 18S OTUs.

--------------------------------------------------------------------------------
18_s18_figure_assembly.Rmd
--------------------------------------------------------------------------------
Purpose: Assembles final composite 18S figures from objects generated in
14-17 (structurally parallel to 11).

Key contents:
- Combines alpha/beta diversity panels into the main diversity figure.
- Builds the composition heatmap using the PR2 genus-resolution mask (drops
  backfilled genus == family placeholders and curated informal clade/
  lineage names, NA-safe) so that genus definitions are identical between
  this figure and the indicator-species results (Figure 7 / S11 parity, per
  project conventions).
- Builds the main "taxa response" figure and an associated supplemental
  figure, matching 16S figure styling.

--------------------------------------------------------------------------------
19_cross-domain_coupling.Rmd
--------------------------------------------------------------------------------
Purpose: Quantifies coupling between the 16S bacterioplankton and 18S
microeukaryote assemblages, and their joint relationship to environmental
variation — the basis for Supplementary Section S7.

Key contents:
- Loads both phyloseq objects and generates the shared-sample, complete-case
  subset needed for paired 16S/18S comparison.
- Computes shared-set nMDS scores for both domains.
- Whole-community coupling via Mantel and partial Mantel tests (partialling
  out environmental variation).
- Global Procrustes analysis between the two domains' ordinations, including
  the residual distribution used for manuscript text (median residual
  reported plainly, not compared to asymmetric-Procrustes scale).
- Variance partitioning with three explanatory matrices: X1 =
  physicochemical, X2 = nutrients, X3 = opposing-domain community structure
  — yielding the pure/shared/residual variance fractions for each domain.
- Builds and assembles the Procrustes superimposition plot, Procrustes
  residuals plot (by date, with KW/Dunn's post-hoc), and variance
  partitioning plot into the final cross-domain coupling figure.

Outputs feed: Supplementary Section S7 (cross-domain coupling), including
the Mantel/partial Mantel statistics, Procrustes r/SS values, residual KW/
Dunn's results, and variance-partitioning fractions cited in the manuscript.

================================================================================
NOTES ON PIPELINE STRUCTURE
================================================================================
- Scripts 01-05 (hydrodynamics, hydrometeorology, physicochemistry) are
  independent of the microbial pipeline but supply environmental covariates
  used in 08, 15, and 19.
- Scripts 06-11 (16S) and 12-18 (18S) are structurally parallel pipelines:
  postprocessing -> alpha diversity -> beta diversity -> community
  composition -> disturbance response -> figure assembly, with the 18S
  pipeline additionally requiring the PR2 classification step (12) before
  postprocessing (13).
- Script 19 is the terminal synthesis step, requiring finished phyloseq
  objects from both domain pipelines (06/13) and environmental data from
  the physicochemistry pipeline (05).
- Two distinct date frames are used throughout: the full discrete
  physicochemical sampling set (used in 01-05) versus the five microbially
  co-registered dates (used in 06-19). These are not interchangeable.
