# Spec: Solar System Data Center — Systems & Networks Simulation

## Original Prompt

> start with spec.md - add what we are building - we are going to build a simulation that will feed a 3d model - this 3d model will be a system of space sattalites that will be connnected with lasers and powered by the sun. we want to start with the physics engine, and we are only worried about gravity, dots - the sattalites, the laser connections as lines, and orbit paths which will be the shape of the orbit around what the object is around - we want all the plantes in the sun - commmit this statement as original prompt to the spec.md and also flush out the spec.md with what language etc would be required to build something like this - we will add attributes to the orbiting devices in space we are going to simulate

## Addendum (verbatim)

> we are going to put any device in space, and we are also never going to bring anything back down unless we need to - once something is up in space, we keep it there, and use it for later, if we have to build a scrap yard somewhere we will - also the devices we are launching can be anything - an entire device could be a mirror - or a piece of a giant antenna

## Overview

We are building a simulation of a solar-system-scale space infrastructure network: satellites connected to each other via laser links, powered by the sun, orbiting planets which themselves orbit the sun. The simulation is the data source ("physics engine") that feeds a separate 3D visualization layer. The two are decoupled — the physics engine computes state, the 3D model renders it.

## Design Principles

- **One-way logistics**: once a device is launched into space, it stays there. Nothing is brought back down to a planet/Earth unless explicitly required by a future scenario. This is a simulation of accumulation, not round-trip logistics.
- **Retirement, not recovery**: a device that reaches end-of-life isn't deorbited or removed from the simulation — its status changes (e.g. `active` → `retired`) and it may be relocated to a designated "scrapyard" — a graveyard orbit or region set aside for decommissioned devices. Where/what the scrapyard is (a specific orbit band, a location near a specific planet, etc.) is a future decision; the data model should just allow a device's status/location to change without deleting it.
- **Devices are heterogeneous, not just "satellites"**: an object placed in orbit isn't necessarily a complete, self-contained satellite. It can be anything — a single mirror, one segment of a larger multi-part antenna array, a solar collector panel, a relay node, etc. Several devices may conceptually form a larger structure (e.g. an antenna assembled from many orbiting pieces), but each device is still its own independently tracked physics object (own position, velocity, mass). "Satellite" in this spec is shorthand for "orbiting device," not a claim about its form factor or completeness.

## Goals

### Goal 1 — Reconfigurable Network (verbatim)

> we want to be able to reconfigure the entire network at will - we will also build things - things like a chain of devices to the moon - or millions of static space telescopes - turning them into one, and different devices by moving them around and reconfiguring the

**Implications for the spec:**

- **Active maneuvering, not just orbital drift**: to reconfigure "at will," devices need to be able to move under something other than pure gravity — a thrust/maneuvering force layered onto the N-body integrator. Phase 1 is gravity-only (see below); active repositioning is a capability the physics engine will need to grow into, not something the data model should preclude.
- **Dynamic network topology**: `LaserLink` connections must be freely addable/removable/redirectable at runtime as devices move, not fixed at launch. The network is meant to be restructured continuously, not just initially configured.
- **Devices can be regrouped into different logical structures over time**: the same set of physical devices can be combined into one larger virtual structure, then later reconfigured into something else entirely. Two examples called out explicitly: a chain of devices forming a relay link to the moon, and a swarm of millions of independently-built, static space telescopes that can act as one combined instrument — then be reconfigured into different devices/formations. This means grouping (`structureId` in the data model) must be reassignable, not a permanent label set once at launch.

## Phase 1 Scope: Physics Engine Only

Phase 1 is deliberately narrow. It covers only:

1. **Gravity** — N-body gravitational attraction between the sun, planets, and devices (or a simplified two-body/patched-conic model per orbiting object, see Open Questions).
2. **Dots** — point-mass representations of devices in orbit (position + velocity, no geometry/mesh yet). A device can be a full satellite or just a piece of one (see Design Principles).
3. **Laser connections** — lines between devices representing active laser links (purely geometric/topological at this stage — no bandwidth, power, or beam-physics modeling yet).
4. **Orbit paths** — the geometric shape (ellipse/circle) traced by each orbiting body around its parent (planets around the sun, devices around planets), derived from current position/velocity/mass.
5. **Bodies included**: the sun and all planets of the solar system. Devices are placed in orbit around planets (and/or the sun) as the objects of primary interest.

Explicitly out of scope for Phase 1: solar power modeling, device attributes/subsystems, laser link physics (range, occlusion, data throughput), collision detection, relativistic effects, moons/asteroids (unless trivially free to include), UI/controls, the 3D renderer itself, and the scrapyard (device retirement is a data-model concern only — no logic to move a device there yet).

## Future Scope (not Phase 1, but shapes the data model now)

- Attributes on orbiting devices: e.g. power generation/storage, mass, orientation/attitude, link capacity, health/status, mission role, sensor payloads, device type (satellite, mirror segment, antenna segment, solar collector, relay, etc.).
- Laser link constraints: line-of-sight/occlusion by planetary bodies, max range, sun interference.
- Power system: solar panel exposure vs. sun angle, eclipse periods (behind a planet).
- Moons, asteroids, other minor bodies.
- Real-time interactivity (time controls: pause, rewind, speed up).
- Device lifecycle: active → retired/scrap transitions, and a scrapyard orbit/region where retired devices accumulate rather than being removed from the simulation.
- Active reconfiguration / maneuvering (Goal 1): devices moved deliberately (thrust, not just gravity) and regrouped into different structures at will — e.g. a relay chain to the moon, or a swarm of independent devices combined into one larger virtual instrument and later reconfigured. Requires a maneuvering force model on top of the gravity integrator, plus dynamic, reassignable device grouping and freely editable `LaserLink` topology.

Because attributes are coming later, the data model should represent devices (and other bodies) as extensible entities from day one, not just bare position/velocity structs. Devices are never deleted on retirement — only reassigned status and (eventually) relocated to a scrapyard — so the model must support a persistent lifecycle rather than add/remove semantics.

## Core Data Model (draft)

```
CelestialBody
  id, name
  mass
  radius            (for rendering / future occlusion checks)
  parent            (id of body it orbits; null for the sun)
  position (x, y, z)
  velocity (vx, vy, vz)
  kind              ("star" | "planet" | "device")
  attributes: {}     (open bag for device-specific data, e.g.:
                        deviceType   ("satellite" | "mirror" | "antenna-segment" | "solar-collector" | ...)
                        status       ("active" | "retired")
                        structureId  (optional: links multiple devices that form one larger assembly, e.g. antenna pieces)
                     )

OrbitPath
  bodyId             (which body this path belongs to)
  parentId           (what it's orbiting)
  shape              (semi-major axis, eccentricity, inclination, etc. OR sampled point array)

LaserLink
  id
  fromDeviceId
  toDeviceId
  active             (bool, for now always true if defined)

Scrapyard (future)
  location           (orbit/region reserved for retired devices; TBD)
  deviceIds           (devices currently retired there)
```

The physics engine's job each simulation tick: integrate gravity to update `position`/`velocity` for every body, then derive/refresh `OrbitPath` for orbiting bodies. `LaserLink` topology is defined separately (not physics-derived) and simply carries the two endpoint positions each tick. Devices are launched into the simulation and persist indefinitely — retirement changes `attributes.status` and (later) moves the device toward the scrapyard, it never removes the device from the simulation.

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
- When does active maneuvering (Goal 1) get introduced — a later phase after gravity-only Phase 1 is working, or should the integrator be built from the start to accept an extra force term (thrust) alongside gravity? How is reconfiguration triggered — a scripted sequence, live user interaction, or both?
