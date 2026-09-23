# Godot engine guide

This is an **existing Godot 4.7 GDScript 2D** game. Do **not** convert it to C#/.NET, do **not** add a `.csproj`, and do **not** replace `project.godot` or wipe `assets/`.

Stack: **Godot 4.7.2 standard** (not Mono) + **GDScript**. The editor on this machine is `godot` → `C:\Users\PC\AppData\Local\Programs\Godot\godot.exe` (`4.7.2.stable.official`). Python here is `python` (3.11), not `python3`.

## This game

- Project name: `DogBoy(BatCho)-9/9/2026`
- Shape: pixel-art arcade dog-catching game, Vietnamese village backdrop, 1280×720
- Main scene: `main.tscn`
- Runtime scripts: `scripts/*.gd` (`auto_scroll_bg.gd`, `game_layout.gd`)
- Shared layout: `GameLayout` in `scripts/game_layout.gd` (dog lane Y, catch zone)
- Runtime art: `assets/HinhNen/`, `assets/Animal/`
- Shaders: `shaders/` when present
- Display: `window/stretch/mode="canvas_items"`, aspect `expand`
- Features in `project.godot` must stay `PackedStringArray("4.7", "Forward Plus")` — no C# feature flag

The player watches by running the project in the editor or `godot --path .`. Keep import/run clean so each launch matches current files.

## Cursor MCP (Godot)

Project MCP lives in `.cursor/mcp.json` and runs [`@coding-solo/godot-mcp`](https://github.com/Coding-Solo/godot-mcp) (`npx -y @coding-solo/godot-mcp`). `GODOT_PATH` is pinned to `C:\Users\PC\AppData\Local\Programs\Godot\godot.exe`. After the first clone, enable the **godot** server in Cursor Settings → MCP if tools do not appear.

## Project shape

- `project.godot` — preserve existing `config_version=5` and Godot 4.7 fields; add input actions as needed
- `scripts/*.gd` — runtime behavior
- `*.tscn` — scenes (edit in place; do not invent a parallel C# builder pipeline)
- `assets/` — **only** files the running game loads. Keep generation refs/workdir outside it (e.g. `screenshots/`, temp folders)
- After art changes: `godot --headless --import --quit`, then `godot --headless --quit` (RID-leak warnings on headless exit are benign)

## GDScript traps (silent or cryptic)

- `instantiate()`, `load()` without a type, and `abs`/`clamp`/`lerp`/`min`/`max` return Variant — do not use `:=` on those results; type the variable or use `=`
- Prefer `preload()` for known `res://` paths; `load()` when the path is computed
- Do not `await` during `--write-movie` (it advances the movie frame counter)
- `@onready` is not ready inside `_init()`; scene-tree work belongs in `_ready()`
- Do not name a method `get_path()` — it collides with `Node.get_path()`
- Frame-rate-independent damping: `speed *= exp(-rate * delta)`, not `speed *= (1 - drag)` per tick
- **`.gdignore`** makes the importer skip a folder silently — only `screenshots/` should have one, never `assets/`

## Packed-scene serialization (if you script a `.tscn` save)

These fail without a compile error:

- **Owner chain:** every node must have `owner` set to the scene root or it will not serialize. After building, walk descendants and set `child.owner = root`, but **do not recurse into instantiated `.tscn`/GLB nodes** (`scene_file_path` is set). Recursing inlines meshes and can blow the file up.
- **Validate the pack:** count nodes, `pack()`, `instantiate()`, compare counts; only `ResourceSaver.save()` if they match.
- Set scripts **last**, after the hierarchy exists.

## Capture (proof video)

This workstation is **Windows**. There is no `xvfb`. Use Godot's movie writer from a dedicated GDScript under `test/` (create `screenshots/.gdignore` so frames are not imported).

```bat
godot --path . --headless --import --quit
godot --path . --write-movie screenshots/result/frame.png --fixed-fps 30 --quit-after 450 --script test/presentation.gd
ffmpeg -y -framerate 30 -i screenshots/result/frame%%04d.png -c:v libx264 -pix_fmt yuv420p -movflags +faststart screenshots/result/video.mp4
```

`--fixed-fps` makes motion deterministic (450 frames @ 30fps = 15s). Pre-position the camera before the first movie frame (it renders before `_process`). Drive capture input from the script, not live keys. The clip must show behavior progressing across the window — no dead time, no single looped frame.

If `ffmpeg` is missing, stills from the running game are the fallback; say so instead of claiming a video.
