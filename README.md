# TITAN BALL: MUTANT X — THE PIT

## Playable stadium repair

Open `project.godot` in Godot 4.6 (or Xogot) and run the project. Choose a
character, then advance up the field with W / up or the touch arrow. A/D move
across the field; Space dashes, X smashes, and V mutates when the meter is full.
The gamepad left stick and face buttons use the same actions.

The Pit now has a real ground collision and four stadium boundary colliders.
The chase camera starts inside the rear wall, follows the runner, and receives
dash/mutation FOV and impact shake. The HUD advances from 0 to 100 yards at
the goal line and updates during the run. Existing title, roster, pickups,
sound, and TTD stadium art remain in use.

This is still a small single-player run-to-the-end-zone prototype. Character
art is billboard sprites until the authored GLB models are supplied; there is
no passing, team AI, full match rules, or console build in this repository.
PlayStation release requires a separate console port/build, platform approval,
and certification. Verify the feel in Godot before planning that production work.

This is the consolidated GitHub/Xogot redeploy build made from the user's deployed repository.

## Finished tonight
- existing title screen preserved
- existing character select preserved
- real 3D stadium bowl built around the field
- open procedural night sky
- physical sideline / far-end stadium collision
- concrete stadium apron around turf
- stepped sideline grandstands
- far-end stands / fortress / scoreboard architecture
- four light towers
- pink + acid stadium flood lighting
- stadium artwork integrated as an in-world architectural screen
- field image cropped to the exact 16:9 physical mesh ratio
- chase camera retuned to show field + stands + sky
- touch HUD layering preserved
- diagonal / multi-button touch movement added
- touch controls restyled
- player movement duplicate calculation fixed
- defender scale reduced and separation improved
- pickups visually upgraded
- GLB model hooks retained: dex.glb / nikki.glb / mack.glb

## Important
This build is designed to be uploaded FLAT to the GitHub repository root.
Xogot should download the repository directly.

## Next real graphical leap
True PS5-style player models require authored rigged GLB character models and animation.
The game already checks for those model files at the repository root.
