# Changelog

All notable changes to Flare are documented here.

## [0.1.0]: We're getting there.

### Added

- **`flare.core.gamesubstate`**: modal substate system for overlaying UI layers (pause menus, popups, etc.) on top of the active gamestate without tearing it down
- **`flare.core.group`**: container that batch-updates and draws a collection of objects; simplifies scene composition
- **`flare.core.timer`**: one-shot and repeating callbacks with optional delay; wraps `fl.timer.after` and `fl.timer.every`
- **`flare.graphics.animatedsprite`**: animated sprite renderer supporting sparrow atlas (you gotta set the offsets yourself)
- **`flare.graphics.trail`**: afterimage/trail effect that can be attached to any sprite
- **`flare.input.inputaction`**: action-based input mapping layer on top of `keyboard`; bind named actions to keys and query by action name rather than raw key
- **`flare.utils.color`**: color conversion and manipulation (RGB/HSV/hex) and blending helpers
- **`flare.utils.locale`**: string localization; load locale files and look up translated strings by key
- **`flare.utils.pool`**: object pool for performance-critical spawning patterns; pre-allocates and recycles instances to avoid per-frame GC pressure

### Changed

- **Requirements**: bumped minimum LÖVE2D version from 11.4 to **12**

---

## [0.0.1]: initial release

### Added

- `flare.core.gamestate`: stack-based state management with fade transitions and hot reload
- `flare.core.object`: base physics object with velocity, acceleration, drag, and max velocity
- `flare.core.basic`: minimal base class for non-physics objects
- `flare.core.signal`: event/observer system
- `flare.graphics.camera`: 2D camera with shake, zoom, smoothing, and bounds clamping
- `flare.graphics.sprite`: image rendering with frame-based animation
- `flare.graphics.text`: bitmap and TTF text rendering
- `flare.graphics.shader`: shader loading and uniform helpers
- `flare.graphics.video`: OGV video playback with volume control
- `flare.audio.sound`: SFX and music playback with per-category volume control
- `flare.input.keyboard`: keyboard state helpers (pressed, released, held)
- `flare.math.math`: lerp, clamp, remap, approach, distance, angle, overlap, and more
- `flare.data.assets`: cached loader for images, sounds, fonts, shaders, video, JSON, and Lua data
- `flare.data.save`: encoded save data with a user-provided secret key
- `flare.data.json`: JSON encode/decode
- `flare.tweens.tweens`: tween any table field with 14 built-in easing functions
- `flare.utils.utils`: general-purpose utility functions
- `flare.utils.paths`: path string helpers
- `flare.discord`: Discord Rich Presence integration