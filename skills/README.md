# skills

Place custom Codex skills here.

Suggested workflow:
- Keep each skill in its own subdirectory under `skills/`
- Add a `SKILL.md` file for the skill instructions
- Symlink the skill directory into your local Codex skills location when you want it active



## `single-paper-review`
Credit to Seokhyun Moon for the original code (found in his [github repo](https://github.com/mseok/dot/tree/9c476b7df72b622de7f311e80bb3e0363c095752/ai/codex/skills/single-paper-review)). AI was used to transform the review process from Korean to English.

This skill creates an Obsidian-friendly English note for reviewing a single paper. It is meant to produce a reusable study note rather than an accept/reject review: it emphasizes the method and results, explains the paper's metrics, keeps exact figure and table references, and includes a required `Main-Paper Figure Atlas` section that embeds every main-paper figure saved under `Attachments/<paper-slug>/`.

Use it when you want Codex to turn a paper into a structured note. Give Codex the paper itself (for example a PDF, link, or citation) and, if you care about the destination, the exact `.md` path to write. If you do not provide a path, the skill is supposed to create a new note based on the paper title while keeping the structure aligned with the bundled template at `single-paper-review/assets/review_template.md`.

## `grilling`

This skill relentlessly stress-tests a plan, decision, or idea through a one-question-at-a-time interview. Each question includes a recommended answer, and the session continues until there is a shared understanding. Use it when you want to expose assumptions, dependencies, tradeoffs, and unresolved branches before taking action.

Source: [mattpocock/skills — `grilling/SKILL.md`](https://github.com/mattpocock/skills/blob/main/skills/productivity/grilling/SKILL.md)

## `grill-me`

This is a manual-invocation shortcut for `/grilling`. Use `/grill-me` when you want Codex to start a grilling session about a plan or design without invoking the longer skill name directly.

Source: [mattpocock/skills — `grill-me/SKILL.md`](https://github.com/mattpocock/skills/blob/main/skills/productivity/grill-me/SKILL.md)
