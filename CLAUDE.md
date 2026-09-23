# Build Godot game from a description

- Keep durable project status in `README.md`: what is built, what is left, and an asset table.
- Generate visual assets with `/asset-gen`. Confirm the spend with the user before the first paid generation.
- Read `godot.md` for engine guidance: stack, project layout, how to run, and how to capture.

## Delivery

Judge progress from the running game, never from a clean build: verify the structural things yourself (it loads, no errors, assets present) and let what you see drive the next iteration.

Decide from how the task is framed how to work. A task that invites collaboration — open-ended, exploratory, phrased as a direction rather than a spec — gets the live game early: checkpoint at decisions of taste, scope, or cost, and build freely in between. A task handed over as a finished brief to execute gets reasonable calls and steady progress, no blocking. Either way the result is proven, not claimed — if the user hasn't seen it running, finish with a 15–20s video of the game in action, and watch it back before you call the work done.

## This repository

Existing **Godot 4.7.2 + GDScript 2D** arcade game (`DogBoy(BatCho)-9/9/2026`). Godogen is installed **into** this repo; it is not a blank generator target.

- Do not convert to C#/.NET, do not add `.csproj`, do not recreate `project.godot`.
- Do not run `publish.sh --force` here (it would wipe the game).
- Skills: `.claude/skills/asset-gen`. On Windows use `python`, not `python3`.
- Paid keys live in `.env` (see `.env.example`): `GOOGLE_API_KEY`, `XAI_API_KEY`, `TRIPO3D_API_KEY`. Never commit `.env`.
- Asset CLI (from repo root): `python .claude/skills/asset-gen/tools/asset_gen.py image --prompt "..." -o assets/...`
- Runtime files published from [htdt/godogen](https://github.com/htdt/godogen); license in `GODOGEN_LICENSE.md`.
