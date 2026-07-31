# dotfiles
Dotfiles and Codex skills for my local macOS setup.

## repository layout

### config/

Shared app configs live under `config/`. These are the files I symlink into my local machine.

Current config directories:
- `config/aerospace` for AeroSpace
- `config/linearmouse` for LinearMouse
- `config/sketchybar` for SketchyBar

### skills/

Custom Codex skills live under `skills/`. Each skill can have its own `SKILL.md`, prompts, assets, and other support files, then be symlinked into the local Codex skills directory when needed.

Current skills:
- [`skills/single-paper-review`](skills/single-paper-review) for creating structured, Obsidian-friendly English paper review notes
- [`skills/grilling`](skills/grilling) for stress-testing plans, decisions, and ideas through a one-question-at-a-time interview
- [`skills/grill-me`](skills/grill-me) as a manual `/grill-me` shortcut for starting a grilling session

## aerospace
[project link](https://github.com/nikitabobko/AeroSpace)

Tiling windows manager for macOS.
I have aerospace set to a maximum of 10 spaces: 1 ~ 10 (0) to be accessed easily with the number row (or the corresponding QWER row).


## sketchybar
[project link](https://github.com/FelixKratz/SketchyBar)

The SketchyBar configuration includes a Codex quota item. It displays the remaining Codex usage percentage and countdown until the quota resets. Clicking the item opens a popup with the predicted probability of a reset within the next 48 hours, retrieved from [willcodexquotareset.com](https://www.willcodexquotareset.com/).

The quota display requires the Codex CLI, `jq`, `perl`, and `curl`. If usage data is unavailable, the item falls back to `—`.
