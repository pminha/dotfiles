---
author:
venue:
year:
url:
doi:
arxiv:
code:
keywords:
categories:
  - "[[Papers]]"
aliases:
---

## TL;DR
[Write 2-5 sentences covering the problem, the core mechanism/design choice, the headline result, and the main takeaway. If space is tight, prioritize method novelty over background.]

## Contributions in One Line
1. [Contribution 1]
2. [Contribution 2]
3. [Contribution 3]

## Problem Setup
- **Task**: [What is being predicted/generated/optimized?]
- **Inputs/outputs**: [Include notation and shape if useful]
- **Assumptions**: [Data, constraints, priors]
- **Why this matters / where prior approaches fail**: [Failure mode or gap]
- **Core method claim of this paper**: [What is structurally different from earlier methods?]

## Method Overview
[Explain the full pipeline in roughly 5-10 lines. If helpful, use a text-based mini diagram so the `input -> module -> output` flow is easy to follow.]

## Method Details
### Core Components
- [Module A: inputs, outputs, key operations/equations, and why it is needed]
- [Module B: what changes relative to prior work]
- [Module C: how it connects to the other blocks]

### Data Flow / Inputs and Outputs
- **Representation**: [token, graph, 3D coordinate, latent, etc.]
- **Per-stage I/O**: [Tensor/object shapes or structure per stage]
- **Information bottleneck / inductive bias**: [Where constraints are introduced]

### Training / Optimization
- **Objective**: [loss, regularizer]
- **Training signal**: [self-supervised / supervised / RL / contrastive, etc.]
- **Data**: [dataset, preprocessing]
- **Compute**: [GPU/TPU, steps, batch size if reported]
- **Hyperparameters**: [Only the important ones]

### Inference / Sampling
- **Inference procedure**: [test-time pipeline, refinement, reranking]
- **Sampling / decoding**: [beam, diffusion step, autoregressive rollout, etc.]
- **Failure mode**: [Where the method is brittle]

## Metrics (Formula + Meaning)
For each key metric used in Methods/Results, include:
1. the formula
2. how this paper computes it
3. the interpretation and caveats

### Metric: [Name]
- **Definition**:
	$$[Put the formula here]$$
- **How this paper computes it**:
	- [Averaging: per-sample / per-class / micro vs macro]
	- [Threshold, matching rule, postprocessing]
	- [Confidence interval / seed / repeat]
- **Interpretation**:
	- [What a high or low value means]
	- [What it is sensitive to]
	- [When it can be misleading]

## Experiments
### Experimental Setup
- **Datasets**: [name, size, split]
- **Baselines**: [Why each baseline matters]
- **Evaluation protocol**: [single-run / multi-run / tuning rule]

### Key Results
- [State the main claim in plain language, then attach the exact table/figure reference.]
- [When possible, include both the absolute number and the delta versus the baseline.]
- [Add one line linking the claim back to the method component it supports.]

### Ablations and Additional Analysis
- [What changed, what effect was expected, what actually happened]

### Qualitative Analysis
- [What the figure shows and what the reader should focus on]

## Main-Paper Figure Atlas
[This section should let the reader scan every Figure 1..N from the main paper body in order. If the note lives in a subfolder, adjust the attachment paths accordingly. Only include supplementary/appendix figures separately when needed.]

### Figure 1
![Figure 1](Attachments/[paper-slug]/fig-1.png)
- **Source**: Paper Figure 1 (page Y)
- **Why it matters**: [Which method/result claim this figure supports]
- **How to read it**: [Axes, legend, key panel-level comparisons]
- **Connection to the note**: [Which method/experiment section it directly supports]

### Figure 2
![Figure 2](Attachments/[paper-slug]/fig-2.png)
- **Source**: Paper Figure 2 (page Y)
- **Why it matters**: [Which method/result claim this figure supports]
- **How to read it**: [Axes, legend, key panel-level comparisons]
- **Connection to the note**: [Which method/experiment section it directly supports]

[Continue with Figure 3..N in the same format. If any body figure is missing, record the figure number and the reason.]

## Reusable Figures / Tables
`Main-Paper Figure Atlas` is exhaustive. Here, keep only the figures/tables that are especially worth reusing in other notes.

### Figure
![Fig. X: Caption](Attachments/[paper-slug]/fig-x.png)
- **Source**: Paper Figure X (page Y)
- **Why it matters**: [What conclusion it supports]
- **How to read it**: [Axes, legend, key comparison points]

### Table
#### Table X (paper)
- **Source**: Paper Table X (page Y)
- **Why it matters**: [What conclusion it supports]

Option A: if the table is simple, rewrite it in Markdown.
| Column | Column | Column |
|---|---|---|
| ... | ... | ... |

Option B: if the table is complex, embed it as an image.
![Table X](Attachments/[paper-slug]/table-x.png)

## Limitations and Interpretive Caveats
- [Limitations acknowledged by the paper]
- [Things the experiments do not test]
- [Where the claim may fail to generalize]

## Reproduction Notes
- **Code**: [repo + commit or release]
- **Config**: [entrypoint or configuration surface]
- **Gotchas**: [Implementation details that are easy to miss]
- **Method-sensitive knobs**: [Objectives, schedules, samplers, thresholds that matter a lot]

## Connections
- **Related papers / notes**: [[...]], [[...]]
- **My hypothesis**: [mechanism-level guess]
- **What to read next**: [concrete next action]

## Checklist
- [ ] TL;DR and contributions foreground method novelty
- [ ] Each core module exposes its input, output, and role
- [ ] Objective and inference procedure are both covered
- [ ] Every key metric includes a formula and interpretation
- [ ] Major claims are tied to specific figures/tables
- [ ] Main-paper body Figures 1..N are saved under `Attachments/[paper-slug]/` and embedded in the note
- [ ] Any missing body figure is listed with a reason
- [ ] Reusable figure/table anchors are preserved
