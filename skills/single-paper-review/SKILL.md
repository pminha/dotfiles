---
name: single-paper-review
description: >
  Create an Obsidian-friendly English single-paper review note with YAML
  frontmatter, method-first summaries, metric definitions, reusable
  figure/table anchors, and a section that embeds every main-paper figure
  saved under `Attachments/`. Use when asked for an English paper review,
  single-paper deep summaries, or a reusable research note that should
  prioritize methods over background and preserve exact figure/table
  references.
---

# Single Paper Review

This skill produces a single-paper review note with the following properties.
- Obsidian-friendly Markdown (`YAML frontmatter + headings`)
- Not an accept/reject review, but a method-and-results-centered study note
- Gives more weight to methods than to background by default
- Metric-literate writing that explains formulas and interpretation
- Leaves reusable figure/table anchors for later notes
- Embeds every main-paper figure in one note for quick scanning

## Template Usage
- Default template: `assets/review_template.md`
- If the vault already has `Templates/Single Paper Review Template (English).md`, it can be used instead
- Keep the structure aligned with the bundled template even when using a vault template

## Workflow
1. Fix the target note path first.
   - If the user gives a specific `.md` path, update that file.
   - Otherwise, create a new note based on the paper title.
   - If the user has already linked a path, keep that exact filename and location.

2. Lock down the main-paper figure inventory before drafting prose.
   - The minimum set is every numbered Figure that appears in the main paper body.
   - Only add supplementary/appendix figures when the user asks for them or when they are necessary to understand the method/results.
   - Save each figure as a PNG under `Attachments/<paper-slug>/`.
   - Per-panel crops are optional readability aids, but they must not replace the full original figure.
   - The note must include one dedicated section that embeds the main-paper figures in paper order.

3. Keep frontmatter minimal but accurate.
   - Always fill `author`, `venue`, `year`, and `url`.
   - Add `doi`, `arxiv`, `code`, and `aliases` when available.
   - Unless the user asks otherwise, keep `categories: [[Papers]]`.
   - Use English frontmatter keys and write the note body in English.

4. Write the summary as a reusable study note.
   - `TL;DR`: 2-5 sentences centered on mechanism and headline result. Aim to italicize (via *text*) important parts of the TL;DR.
   - `Contributions in One Line`: 3-5 claim-like bullets on what changed relative to prior work.
   - `Problem Setup`: clarify the task, inputs/outputs, assumptions, and where earlier approaches break.
   - If space is limited, reduce background/related-work detail before cutting method novelty or design choices.

5. Describe the method in enough detail to support reimplementation-level understanding.
   - Start with a high-level pipeline, then unpack the main components.
   - For each component, explain what goes in, what comes out, and why it is needed.
   - When useful, specify notation and tensor/object shapes to remove ambiguity.
   - Do not omit key losses, objectives, sampling logic, or inference procedures.
   - Separate what differs from prior work at the architecture, training-signal, and data-flow levels.
   - If the paper has an algorithm box, rewrite it into short pseudo-steps instead of copying it verbatim.

6. Always include a `Metrics (Formula + Meaning)` section.
   - Cover every key metric actually used in Methods/Results.
   - For each metric, include:
     - a LaTeX definition
     - how it is computed in this paper
     - what it means and how it can mislead
   - Use `$$ ... $$` for block equations and `$ ... $` for inline equations.
   - In LaTeX, use single `\`.
   - Escape angle brackets such as `\<` and `\>` when you need them literally in prose.

7. Write experiments around figure/table anchors.
   - State the important claim in plain language first.
   - Immediately attach the exact Figure/Table number and reported value.
   - Prioritize results that matter for interpretation and downstream reuse.
   - Even if you summarize selectively, the dedicated figure-atlas section must still embed every main-paper figure in order.

8. Leave outputs in a reusable state.
   - Default attachment folder: `Attachments/<paper-slug>/`
   - Preserve figure numbering in filenames such as `fig-1.png`, `fig-2.png`
   - The `Main-Paper Figure Atlas` section is mandatory.
   - Save and embed every main-paper figure, regardless of perceived importance.
   - For tables, convert simple ones to Markdown and embed complex ones as images.
   - The `Reusable Figures / Tables` section is selective, not exhaustive: keep only the anchors worth reusing in other notes.
   - For each figure/table, always include:
     - Source: exact Figure/Table number + page
     - Why it matters: what conclusion it supports
     - How to read it: axes, legend, comparison points
   - If any body figure is missing, state the missing figure number and the reason in the note.

## Output Rules
- Write the note prose in English. Prefer to use American English for consistency.
- Preserve original paper notation for metric names, model names, and dataset names.
- Keep figure/table anchors tied to exact paper numbering whenever possible.
- Prefer denser method explanation even when the user does not explicitly ask for it.
- Do not write validation claims that assume code execution.
- Embed every main-paper body figure without omission.
- Keep one `Main-Paper Figure Atlas` section that shows body figures in paper order.
- If supplementary/appendix figures are omitted, say so explicitly.
- When using bullet-point listings (`-` or `#.` for numbered lists), indent the sublists using tabspaces, not single spaces

## Constraints
- Do not include any workflow for converting the note to PDF.
- Do not include any workflow for drawing new schematic/diagram figures.
- Write the prose in English and prefer ASCII quotes `" "` when practical.
