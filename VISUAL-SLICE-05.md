# TITAN BALL: MUTANT X — VISUAL VERTICAL SLICE 0.5

## What this build is
A single uploadable Xogot / Godot 4.6 project designed to match the presentation
language of the target mockup as closely as possible before final authored art exists.

## Flow
TITLE SCREEN
→ CHARACTER SELECT
→ ENTER THE PIT LOADING
→ GAMEPLAY

## Playable mutants
- Dex Volt #7 — balanced / Volt Storm
- Nikki Nitro #94 — speed & dodge / Nitro Break
- Mack Maul #99 — power tank / Earthquake

## Gameplay
- Touch + controller + keyboard input
- dash
- smash
- mutation
- HP
- mutation meter
- five live defenders with speed/chaser/bruiser archetypes
- tackles
- knockback
- smash launches
- dash tackle protection
- four-down structure
- first downs
- turnovers
- touchdowns
- scoring
- drives
- Skull Juice health pickup
- Mutant Loops mutation pickup
- game over + restart
- event callouts
- camera FOV kick
- camera shake
- impact screen flashes

## The Pit / Sludge Stadium
Procedural environment includes:
- toxic dark field
- neon yard lines and hash marks
- hot-pink end zones
- cyan goal structures
- industrial stands
- toxic sludge tanks
- animated neon lighting
- giant THE PIT / SLUDGE STADIUM wall
- Skull Juice and Mutant Loops signage
- optional auto-loaded field and backdrop images

## Asset auto-wiring
Drop future art into the exact paths listed in `art/ASSET-SLOTS.txt`.
The project checks those paths automatically.

## Important graphics reality
This build targets the *layout, camera, presentation, lighting language and gameplay*
of the supplied PS5-style mockup.

True PS5-class final character rendering requires authored 3D assets:
high-detail meshes, UVs, PBR texture sets, skeletal rigs, animation, VFX,
crowd assets and higher-end desktop/console rendering.

This project is deliberately structured so those assets can replace the procedural
placeholders without redesigning the game loop.
