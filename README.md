# DogBoy (Bắt Chó) — 9/9/2026

Godot 4.7.2 GDScript arcade: port sát luật [Shiba Catch](GameThamKhao/source/logic.js) trên nền làng Việt pixel, viewport 1280×720.

Godogen ([htdt/godogen](https://github.com/htdt/godogen)) is configured in this repo for asset generation and visual iteration. Stack stays **GDScript** (see `godot.md`). License of the published skills: `GODOGEN_LICENSE.md`.

## Built

- `project.godot` — 1280×720, canvas_items stretch, Forward Plus
- `main.tscn` — Background + LassoBehind + ChoCo + LassoFront + Catcher + HUD
- `scripts/game_session.gd` — single source of truth (1/60s): ready/idle/windup/throw/close/tug/caught/retract/break/paused/over
- `scripts/dog_atlas.gd` — neck in 400×280 cell; `neck_world` after scale/rotate
- `scripts/dog_runner.gd` — follows session (run / sprint escape / turn / front tug / caught sit). No jump-on-miss
- `scripts/catcher.gd` — player aim (mouse / ← →), tap to throw or mash tug; no auto-aim
- `scripts/lasso_draw.gd` — two-half ellipse + pole + quadratic rope + idle reticle
- `scripts/hud.gd` — 4-digit score, combo +25, 60s clock, tug bars, overlay Sẵn sàng / Tạm dừng / Hết giờ (no paw lives)
- `scripts/auto_scroll_bg.gd` / `parallax_bg.gd` / `wind_effect.gd` / `game_layout.gd`
- `assets/Animal/choco_frames.tres` — run / walk / sprint / turn / front + idle/look/jump/caught/sit
- `assets/Avatar/swing/` — forearm poses with baked lasso stripped (`screenshots/strip_lasso.py`)
- `test/presentation_driver.gd` — 15s @ 30fps: miss, hit+mash tug, miss, hit+tug
- `screenshots/result/video.mp4` — proof clip

## Left

- PixelLab pass if topping up gens (cleaner pole tip, optional extra hand frames)
- Longer coin-op attract (overlay start is enough for now)

## Controls

- Aim: mouse X or ← → (100–1180)
- Throw / tug mash: click or Space (hold does not count; 0.065s rate)
- Pause: P or Esc
- Restart after over: play button or R

Scoring: `100 + combo*25` on a won tug. Round is 60s.

## Godogen

- Cursor: `.cursor/skills/asset-gen` and `.cursor/skills/godogen`; Godot MCP: `.cursor/mcp.json` (`@coding-solo/godot-mcp`)
- Claude Code: `CLAUDE.md` + `.claude/skills/asset-gen`
- Codex: `AGENTS.md` + `.agents/skills/asset-gen`
- Copy `.env.example` → `.env` and fill API keys before paid generation
- Python deps (project venv): `python -m venv .venv` then `.\.venv\Scripts\pip install -r .cursor/skills/asset-gen/tools/requirements-cpu.txt`
- Confirm cost with the user before the first paid call

## Asset table

| Name | Description | Size | Path | Cost |
|------|-------------|------|------|------|
| HinhNen1 | Village backdrop | 1280×720 fullscreen | `assets/HinhNen/HinhNen1.png` | existing |
| Mountains | Distant mountains parallax layer | 1280×720 | `assets/HinhNen/layers/mountains.jpg` | AI generated |
| Village Mid | Mid-ground village parallax layer | 1280×720 | `assets/HinhNen/layers/village_mid.jpg` | AI generated |
| Foreground Grass | Foreground grass & flowers layer | 1280×720 | `assets/HinhNen/layers/foreground_grass.jpg` | AI generated |
| Wind Particles | Wind leaf/dust overlay | 1280×720 | `assets/HinhNen/layers/wind_particles.jpg` | AI generated |
| ChoCo clips | run 8 / walk 6 / sprint 6 / front 6 / turn 3 from Animal sheet | 400×280 | `assets/Animal/frames/`, `choco_frames.tres` | user sheet |
| Catcher poses | Forearm + pole; lasso drawn in code | ~256×256 | `assets/Avatar/swing/`, `catcher_frames.tres` | user sheet, local strip |
| icon_bone | Golden dog-bone score icon | 64×64 HUD | `assets/UI/icon_bone.png` | PixelLab trial |
| icon_clock | Round analog clock / timer | 64×64 HUD | `assets/UI/icon_clock.png` | PixelLab trial |
| icon_miss | Red miss stamp | 64×64 flash | `assets/UI/icon_miss.png` | PixelLab trial |
| vfx_catch_spark | Gold catch burst | 128×128 VFX | `assets/UI/vfx_catch_spark.png` | PixelLab trial |
| hud_plaque | Wooden score plaque | 256×64 HUD | `assets/UI/hud_plaque.png` | PixelLab trial |
| icon_lasso | Hemp lasso loop (ready pulse) | 64×64 HUD | `assets/UI/icon_lasso.png` | PixelLab trial |
| icon_paw | Paw-print (unused this round) | 48×48 HUD | `assets/UI/icon_paw.png` | PixelLab trial |
| btn_play | Wooden play disc | 96×96 retry | `assets/UI/btn_play.png` | PixelLab trial |
| leaf_banana | Banana leaf for wind particles | 32×32 wind | `assets/HieuUng/leaf_banana.png` | PixelLab trial |
