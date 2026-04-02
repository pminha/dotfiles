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
- `skills/single-paper-review`

## aerospace
[project link](https://github.com/nikitabobko/AeroSpace)

Tiling windows manager for macOS.
I have aerospace set to a maximum of 10 spaces: 1 ~ 10 (0) to be accessed easily with the number row (or the corresponding QWER row).


## sketchybar
[project link](https://github.com/FelixKratz/SketchyBar)

Custom menu bar to be used in place of (or in conjunction with) the default macOS menu bar. Integrates well with aerospace (at least, in principle).
