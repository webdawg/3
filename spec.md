# Spec: Solar System Data Center — Systems & Networks Simulation

## Original Prompt

> start with spec.md - add what we are building - we are going to build a simulation that will feed a 3d model - this 3d model will be a system of space sattalites that will be connnected with lasers and powered by the sun. we want to start with the physics engine, and we are only worried about gravity, dots - the sattalites, the laser connections as lines, and orbit paths which will be the shape of the orbit around what the object is around - we want all the plantes in the sun - commmit this statement as original prompt to the spec.md and also flush out the spec.md with what language etc would be required to build something like this - we will add attributes to the orbiting devices in space we are going to simulate

## Overview

We are building a simulation of a solar-system-scale space infrastructure network: satellites connected to each other via laser links, powered by the sun, orbiting planets which themselves orbit the sun. The simulation is the data source ("physics engine") that feeds a separate 3D visualization layer. The two are decoupled — the physics engine computes state, the 3D model renders it.

## Phase 1 Scope: Physics Engine Only

Phase 1 is deliberately narrow. It covers only:

1. **Gravity** — N-body gravitational attraction between the sun, planets, and satellites (or a simplified two-body/patched-conic model per orbiting object, see Open Questions).
2. **Dots** — point-mass representations of satellites (position + velocity, no geometry/mesh yet).
3. **Laser connections** — lines between satellites representing active laser links (purely geometric/topological at this stage — no bandwidth, power, or beam-physics modeling yet).
4. **Orbit paths** — the geometric shape (ellipse/circle) traced by each orbiting body around its parent (planets around the sun, satellites around planets), derived from current position/velocity/mass.
5. **Bodies included**: the sun and all planets of the solar system. Satellites are placed in orbit around planets (and/or the sun) as the objects of primary interest.

Explicitly out of scope for Phase 1: solar power modeling, satellite attributes/subsystems, laser link physics (range, occlusion, data throughput), collision detection, relativistic effects, moons/asteroids (unless trivially free to include), UI/controls, and the 3D renderer itself.

## Future Scope (not Phase 1, but shapes the data model now)

- Attributes on orbiting devices (satellites): e.g. power generation/storage, mass, orientation/attitude, link capacity, health/status, mission role, sensor payloads.
- Laser link constraints: line-of-sight/occlusion by planetary bodies, max range, sun interference.
- Power system: solar panel exposure vs. sun angle, eclipse periods (behind a planet).
- Moons, asteroids, other minor bodies.
- Real-time interactivity (time controls: pause, rewind, speed up).

Because attributes are coming later, the data model should represent satellites (and other bodies) as extensible entities from day one, not just bare position/velocity structs.

## Core Data Model (draft)

```
CelestialBody
  id, name
  mass
  radius            (for rendering / future occlusion checks)
  parent            (id of body it orbits; null for the sun)
  position (x, y, z)
  velocity (vx, vy, vz)
  kind              ("star" | "planet" | "satellite")
  attributes: {}     (open bag for future satellite-specific data)

OrbitPath
  bodyId             (which body this path belongs to)
  parentId           (what it's orbiting)
  shape              (semi-major axis, eccentricity, inclination, etc. OR sampled point array)

LaserLink
  id
  fromSatelliteId
  toSatelliteId
  active             (bool, for now always true if defined)
```

The physics engine's job each simulation tick: integrate gravity to update `position`/`velocity` for every body, then derive/refresh `OrbitPath` for orbiting bodies. `LaserLink` topology is defined separately (not physics-derived) and simply carries the two endpoint positions each tick.

## Output / Interface to the 3D Model

The physics engine must "feed" the 3D model — meaning it needs a clean state-export boundary regardless of what language either side is written in:

- Per-tick (or per-frame) snapshot: array of body positions + array of active laser links (endpoint positions) + orbit path geometry (recomputed only when orbital elements change, not every frame).
- Format: JSON for interop simplicity, or an in-memory shared structure if physics and rendering run in the same process/language.
- Time-stepping: fixed timestep numerical integration (e.g. Velocity Verlet or RK4) decoupled from render framerate.

## Language & Stack Recommendation

Two viable paths, depending on priorities:

### Option A — Unified JavaScript/TypeScript stack (recommended for this project)
- **Physics engine**: TypeScript, using plain vector math (or a small library like `gl-matrix`) implementing Newtonian gravity + Velocity Verlet integration.
- **3D model**: Three.js (WebGL), consuming the physics engine's state directly in-process (same runtime, no serialization boundary).
- **Why**: satellites, laser lines, and orbit paths map directly onto Three.js primitives (`Points`/small spheres, `Line`, `EllipseCurve`/`Line` loops). Running physics and rendering in the same language means the "feed" is just a function call or shared state object — no IPC/serialization layer needed for an interactive, real-time simulation. Also gives a natural path to a browser-based, shareable demo.
- **Numerics note**: JS doubles (IEEE 754) are precise enough for this scale if positions are stored in consistent units (e.g. AU or km, not meters, to avoid huge floats) — worth deciding units early.

### Option B — Python physics core + separate renderer
- **Physics engine**: Python, using `numpy` for vectorized N-body math, optionally `astropy`/`poliastro` for validated orbital mechanics (Kepler elements, orbit propagation) if scientific accuracy matters more than raw from-scratch gravity integration.
- **3D model**: Three.js (or a game engine) consuming exported JSON/NDJSON state per tick, or a precomputed trajectory file for cinematic (non-interactive) playback.
- **Why**: Python's scientific ecosystem is stronger for orbital mechanics validation and rapid prototyping/analysis (e.g. Jupyter notebooks to sanity-check orbits). Tradeoff: introduces a language boundary and a serialization/streaming layer between physics and rendering, which adds complexity if real-time interactivity is a goal.

**Recommendation**: start with **Option A** (TypeScript + Three.js) since the end goal is a live, feedable 3D model and the physics needs here (Newtonian gravity, Verlet integration, Kepler-shaped orbit paths) are straightforward to implement from scratch without needing Python's scientific libraries. Revisit Option B only if orbital-mechanics accuracy requirements grow beyond basic N-body/two-body gravity.

## Open Questions

- N-body gravity (every body attracts every other body) vs. simplified model (planets follow fixed/Keplerian orbits around the sun, satellites do real N-body relative to their parent planet + sun perturbation)? N-body is more "correct" but more expensive and harder to keep numerically stable at solar-system scale over long simulated time.
- Units and scale: real-world AU/km/kg or a stylized scaled-down unit system for visualization purposes?
- How many satellites, and around which planets, for the initial test scenario?
- Time controls (pause/speed/rewind) — Phase 1 or later?
