# DogBoy (Bắt Chó) — 9/9/2026

Godot 4.7.2 GDScript arcade: bắt chó trên nền làng Việt pixel-art, viewport 1280×720.

Godogen ([htdt/godogen](https://github.com/htdt/godogen)) is configured in this repo for asset generation and visual iteration. Stack stays **GDScript** (see `godot.md`). License of the published skills: `GODOGEN_LICENSE.md`.

## Built

- `project.godot` — 1280×720, canvas_items stretch, Forward Plus
- `main.tscn` — root scene (Background + ChoCo dog + Catcher)
- `scripts/auto_scroll_bg.gd` — cover-fit background (`assets/HinhNen/HinhNen1.png`)
- `scripts/parallax_bg.gd` — parallax scrolling 4 lớp (mountains → village_mid → main → foreground_grass)
- `scripts/wind_effect.gd` — hiệu ứng gió: lá bay + bụi cuộn từ phải sang trái
- `scripts/game_layout.gd` — shared dog-lane / catch-zone layout
- `scripts/dog_runner.gd` — dog crosses R→L on an 8-frame sheet canter; jumps on a miss; turns and sits while being reeled
- `scripts/catcher.gd` — first-person lasso: idle, ready, windup, swing, catch, miss
- `scripts/hud.gd` — pixel HUD: score (bone), 60s clock, 3 paw lives, catch spark / miss stamp, play to retry
- `scripts/main.gd` — injects the 15s throw driver only while Movie Maker is recording
- `assets/Avatar/swing/` — curated frames: setup from `dong-tac-tay.png`, spin from the 14–23 sheet (15 poses)
- `assets/HinhNen/layers/` — parallax layers: mountains, village_mid, foreground_grass, wind_particles
- `test/capture_catcher.gd` — throwaway still-capture helper (globalized-path PNGs)
- `screenshots/result/video.mp4` — 15s proof clip (miss → catch → miss → catch, HUD score/lives)

## Left

- Coin-op attract loop / title screen (play button art is in `assets/UI/btn_play.png`)

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
| Mountains | Distant mountains parallax layer | 1280×720 | `assets/HinhNen/layers/mountains.jpg` | planned |
| Village Mid | Mid-ground village parallax layer | 1280×720 | `assets/HinhNen/layers/village_mid.jpg` | planned |
| Foreground Grass | Foreground grass & flowers layer | 1280×720 | `assets/HinhNen/layers/foreground_grass.jpg` | planned |
| Wind Particles | Wind leaf/dust overlay | 1280×720 | `assets/HinhNen/layers/wind_particles.jpg` | planned |
| ChoCo walk | 8-frame left canter rearranged from the Animal sheet | 400×280 | `assets/Animal/frames/` (sprint/jump/run), `choco_frames.tres` | user sheet |
| Catcher sheet | Curated first-person lasso (15 poses) | 256×256 | `assets/Avatar/dong-tac-tay.png`, `assets/Avatar/swing/`, `catcher_frames.tres` | user sheet, local slice |
| icon_bone | Golden dog-bone score icon | 64×64 HUD | `assets/UI/icon_bone.png` | PixelLab trial |
| icon_clock | Round analog clock / timer | 64×64 HUD | `assets/UI/icon_clock.png` | PixelLab trial |
| icon_miss | Red miss stamp | 64×64 flash | `assets/UI/icon_miss.png` | PixelLab trial |
| vfx_catch_spark | Gold catch burst | 128×128 VFX | `assets/UI/vfx_catch_spark.png` | PixelLab trial |
| hud_plaque | Wooden score plaque | 256×64 HUD | `assets/UI/hud_plaque.png` | PixelLab trial |
| icon_lasso | Hemp lasso loop (ready pulse) | 64×64 HUD | `assets/UI/icon_lasso.png` | PixelLab trial |
| icon_paw | Paw-print lives | 48×48 HUD | `assets/UI/icon_paw.png` | PixelLab trial |
| btn_play | Wooden play disc | 96×96 retry | `assets/UI/btn_play.png` | PixelLab trial |
| leaf_banana | Banana leaf for wind particles | 32×32 wind | `assets/HieuUng/leaf_banana.png` | PixelLab trial |
