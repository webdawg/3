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

### Goal 2 — Solar Collector Array & Interactive Inspection (verbatim)

> okay, now add a set of orbiting energy collection satellites orbiting the sun - also make every object selectable, and when you click it you get the information about what it is, and what its function is

**Implications for the spec:**

- **New device type — energy collection satellite**: devices orbiting the sun itself (not a planet), whose purpose is harvesting solar energy. This was the first device type in the sun's own orbit rather than a planet's, and the seed of the whole sun-orbiting energy-infrastructure thread that Goals 3–5 build on (it's what later becomes the mirror array feeding the foundry).
- **Every body must be inspectable, not just visible**: any object in the simulation — celestial body or device — needs to support being selected (e.g. clicked in the 3D view) and, on selection, surfacing its identity and function to the user. This is a general interaction requirement across the whole simulation, not specific to one device type: the data model's per-body `attributes` bag (name, kind, deviceType, function/description, status) needs to be genuinely readable/presentable, not just internal simulation state.
- **Selection is presentation-layer, not physics-engine**: this is a 3D-model/UI concern (what happens when a user interacts with a rendered body) layered on top of the physics engine's state, consistent with the spec's physics/rendering split — the physics engine doesn't need to know a device is "selected," only the renderer does.

### Goal 3 — Concentrated Solar Foundry (verbatim)

> now we want to use 1cm thick dimond magnification lenses to focus light in a concentrated position that make sense close to the sun in space - we are going to use this as part of a foundry

**Addendum (verbatim) — correcting the pipeline:**

> the light from the sun - that is collected by the light collection sattalites - needs to be shared between them - connect them with lines of photons, then that light needs to be distritubed as they orbit to a central point that is static around the sun, the diamond concentrators inbetween this static point and these collection sattalites

**Addendum (verbatim) — a placement variant tried and then reverted:**

> close - there are lines going outside of the center of the static point, but the lenses should be rotating in the same orbit as the solar collection devices not around the static point

This was implemented (each lens riding the same orbital ring as its collector, offset by a fixed angle) but reverted shortly after, once the foundry's galactic-direction placement was settled, by the mirrors/"in line" correction further down — back to relational placement on the collector-to-foundry line. Kept here for a complete record even though the final behavior supersedes it — the net effect is captured in the "Lens placement is relational" and "in line" bullets below.

**Implications for the spec:**

- **New device type — diamond lens**: a flat, 1cm-thick diamond magnification optic. Its function is to bend/focus light toward a shared focal point rather than to generate or store power itself (distinct from a solar-collector device, which harvests energy directly). `thickness` and `material` become attributes worth tracking on a device, not just `deviceType`.
- **New device/structure type — foundry**: a single **static focal point near the sun** — fixed in space, not itself orbiting — that the light array concentrates light onto. Implies a high-temperature, light-powered industrial process (smelting/forging/material processing) rather than passive collection — a plausible downstream consumer for material eventually pulled from the scrapyard.
- **Collector-to-collector photon links**: solar collectors don't just harvest independently — they're connected to each other ("lines of photons"), sharing collected light across the orbiting ring before it's routed inward.
- **Lens placement is relational, not fixed**: each diamond lens sits geometrically *between* one (moving, orbiting) collector and the (static) foundry point — i.e. along that collector's line to the center — rather than orbiting independently in its own ring. As the collector orbits, its lens's position updates to stay on that line; the foundry itself never moves.
- **Multiple devices serving one shared function**: several independently tracked devices (collectors, and one lens per collector) all feed one static structure (the foundry) they don't individually constitute — reinforcing that `structureId`-style grouping needs to support "many devices, one functional target," not just "many devices, one merged object."
- **Foundry oriented toward galactic travel direction**: the static foundry point sits in front of the sun along its direction of travel relative to the galaxy (a simplified stand-in for the solar apex, roughly toward Cygnus/Hercules) rather than an arbitrary in-plane direction. Since the real galactic plane is inclined ~60° from the ecliptic, this places the foundry well outside the planets'/collectors' orbital plane, not just at some other angle within it. This direction is drawn explicitly as a dashed reference line running through the sun (both ahead of and behind it, like a path), with the foundry sitting on the forward half.
- **Energy-processing devices are mirrors, not power sources**: the devices orbiting close to the sun in this array are primarily mirrors — they reflect sunlight rather than generate/store power themselves (`deviceType: "mirror"`, not `"solar-collector"`). Each diamond lens sits **in line** on the straight path between its paired mirror and the static foundry (not beside the mirror on a shared orbit) and amplifies/focuses that mirror's reflected light onward.
- **Lens-to-mirror spacing is a real distance (500m), which exposes a scale problem**: each diamond lens sits a fixed 500m from its paired mirror, not a proportional fraction of the (much larger, interplanetary-scale) mirror-to-foundry distance. At this simulation's stylized unit scale (anchored off the sun: scene radius 4 units ≈ real 696,000 km, so 1 unit ≈ 174,000 km), 500m is far smaller than a rendered pixel — so the prototype clamps it up to a minimum visible offset rather than the true value. This is a real open question for the data model once actual units are decided (see Open Questions): small, real-world device-to-device distances and solar-system-scale orbital distances don't coexist in one linear unit system without either a non-uniform/logarithmic scale or a "true value vs. rendered value" split per attribute.

### Goal 4 — Foundry-to-Earth Power Delivery (verbatim)

> Okay, so we need a way to transmit - without using lasers as it would be dangerous to shoot a sun powered laser from the sun to earth - energy to earth from the sun - what do we use at each end? [...] go with microwave/rectenna, relayed through the mesh - so we will need a set of relay devices strategically placed to move energy around then lets put them everywhere and connect them with different lines

**Implications for the spec:**

- **Not a laser, by explicit safety constraint**: a direct high-power beam from the foundry straight to Earth is out — a single continuous beam over that distance, at power-delivery intensity, is a hazard. Power delivery uses a fundamentally different mechanism from the laser-based data links elsewhere in the network.
- **New device type — microwave transmitter**: co-located with the foundry/transmitter at the sun end. Converts the foundry's concentrated energy into a microwave beam and sends it into the relay mesh, rather than firing one beam all the way to Earth.
- **New device type — rectenna**: the Earth-end receiver. A rectifying antenna array that converts an incoming microwave beam back into usable power. It's in Earth orbit and moves with Earth, so whatever feeds it has to keep re-aiming as Earth orbits.
- **New device type — power relay**: fixed-position stations distributed between the transmitter and the rectenna. Each one only has to relay a short leg of the trip, which is what keeps every individual beam low-intensity and safe — the hazardous-single-beam problem is solved by chopping the trip into many short, harmless hops rather than by any property of a single link.
- **Relays are scattered ("put them everywhere"), not a single fixed chain**: the mesh isn't one straight line of stations from the sun to Earth — stations are strewn through the intervening space, connected to their nearest neighbors, forming a web of varied links rather than a single path. This also means there can be more than one route energy could take, echoing the "move energy around" framing — the receiving end can pick whichever relay is currently closest as Earth moves, i.e. the mesh dynamically re-routes rather than using one fixed final hop.
- **Distinct from the diamond-lens/photon-link systems (Goal 3)**: those move *light* between mirrors/lens/foundry at the sun end; this moves *power* (as microwaves) from the foundry outward to Earth. Two different device families serving two different legs of the same overall energy pipeline: sunlight → mirrors/lenses → foundry → microwave transmitter → relay mesh → rectenna.

### Goal 5 — Infinite Compute (verbatim)

> put an area of infinite compute 'behind' the sun - directly oppisite of the energy collection point - with a title infinite compute on top of a blackhole - build a set of laser relay devices to power it

**Implications for the spec:**

- **New structure type — compute cluster ("Infinite Compute")**: a theoretically unbounded compute facility built around a black hole. A new category of consumer in the energy pipeline, alongside the foundry (material processing) and Earth (general power) — the network doesn't just move energy to inhabited/industrial sites, it also feeds pure compute.
- **Positioned directly opposite the energy collection point**: placed on the "behind" half of the sun's galactic travel line (see Goal 3's addendum), the same distance from the sun as the foundry is on the "ahead" half — a deliberate mirror-image placement relative to the foundry, using the same reference line already established for orientation.
- **Lasers are acceptable here, unlike the Earth link (Goal 4)**: the earlier constraint against lasers was specifically about not shooting a high-power beam at Earth. A dedicated laser relay chain (transmitter → fixed relay stations → the compute cluster) is fine on this route because it stays entirely on the far side of the sun, never crossing near Earth or any populated body — the safety constraint is about the destination/path, not lasers as a technology.
- **New device types — laser transmitter, laser relay**: parallel to the microwave transmitter/relay pair from Goal 4, but laser-based and arranged as a single fixed chain (not a scattered mesh) since the source and destination are both static and already in a straight line.
- **Named/titled, not just typed**: the requirement that "Infinite Compute" appear as a visible title on the structure (not just a `deviceType`/name in the data model) means the 3D model needs on-screen labeling as a rendering capability, not only selectable info-panel text — the prototype does this with a camera-facing text label rendered above the structure.

### Goal 6 — Survey Ship (verbatim)

> put a ship that collects data in front of the sun parelle to the galatic line - collecting data and powered by the same laser transmission array

**Addendum (verbatim) — correcting the ship's distance:**

> the ship should be ahead of the heliosphere

**Addendum (verbatim) — matching Goal 5's labeling:**

> the same label for the blackhole - make for the ship

Applies the same on-screen title treatment from Goal 5 (Infinite Compute) to the survey ship — reinforcing that visible labeling is a general rendering capability for named structures/devices, not a one-off for the black hole. Unlike the black hole's label, the ship's label has to track a moving body, updated every frame.

**Implications for the spec:**

- **New device type — survey ship**: a data-collection device, distinct from anything so far (relays, mirrors, lenses) in that its purpose is observation, not moving energy or processing material. Patrols a track parallel to the galactic travel line, ahead of the heliosphere rather than close in near the foundry/mirror array.
- **New reference concept — heliosphere boundary**: a marker (not a device — nothing to select or track) around the sun, well past Neptune's orbit, denoting roughly where the sun's direct influence gives way to interstellar space. The survey ship's patrol lane sits entirely beyond it. This also means the ship's power link is now a genuinely long-haul relay — one shared Laser Transmitter now services a nearby destination (Infinite Compute, just past the sun) and a far one (the ship, well beyond the outer planets) via the same bypass branch.
- **Shared power source across destinations on opposite sides of the sun**: the same Laser Transmitter that powers Infinite Compute (behind the sun) now also powers the survey ship (in front of the sun) via a second relay branch — establishing that one transmitter can feed multiple independent relay chains/destinations, not just one.
- **Routing has to respect the sun as a physical obstruction**: a straight line from the (behind-the-sun) transmitter to the (in-front-of-the-sun) ship would pass through the sun itself. The new branch uses two fixed bypass relay hops, offset well to the side, to route the beam around the sun rather than through it — the same kind of straight-line-through-the-center problem flagged earlier in Goal 3's addendum, now solved deliberately rather than by accident.

### Goal 7 — Solar Observatories (verbatim)

> build a set of observation satellites that observe information from the sun searching for galactic data transmission

**Addendum (verbatim) — the search direction:**

> the data it is looking for is both in deep space, and coming from the sun

**Implications for the spec:**

- **New device type — observation satellite**: dual-purpose, unlike prior devices. It orbits the sun to observe solar activity up close (like the mirrors and diamond lenses), while its sensor searches for the galactic data transmission — a device can observe its orbital host and also actively search elsewhere at the same time.
- **Searching both directions, not one known target**: the transmission could be coming from deep space or from the sun itself, so the sensor continuously sweeps between the two rather than fixating on one fixed direction (e.g. the galactic travel line, already used for other structures) — since a "search" implies the source isn't known yet, unlike Goals 5/6 where placement was deliberately keyed to that established axis.
- **Placed in a dedicated clear orbital band**: a ring between Mercury's and Venus's orbits, chosen specifically because it doesn't overlap either — establishing that new device rings need to be placed with existing orbits (and their eccentricity-driven distance ranges, post orbit-correction) in mind, not just picked arbitrarily.

### Planet Orbit Correction (verbatim)

> make sure the orbits of the planets are perfectly correct

**Implications for the spec:** the prototype's planetary orbits were circular with hand-picked, inconsistent periods (a planet's speed had no real relationship to its distance from the sun). Corrected to true two-body Keplerian ellipses: each planet uses its real orbital eccentricity (so the sun sits at a focus, not the center — most noticeable on Mercury, e≈0.21), its period is derived from Kepler's third law (T ∝ a^1.5) relative to the scene's distance scale rather than picked by hand, and position each frame is solved from Kepler's equation, so a planet correctly moves faster near perihelion and slower near aphelion (Kepler's second law) instead of sweeping at a constant angular rate. This resolves the physical-consistency half of the "N-body vs. simplified model" open question below in favor of the simplified (Keplerian, sun-fixed) model for Phase 1 — full N-body mutual gravitation between planets remains future work.

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
- Solar collector array and interactive object inspection (Goal 2): the first sun-orbiting energy device type, plus a general requirement that any body/device be selectable in the 3D view and surface its name/kind/function on selection. The latter is a rendering/UI capability layered on the physics engine's state, not a physics-engine feature itself — worth noting since Phase 1 above lists "UI/controls" and "the 3D renderer itself" as explicitly out of scope, yet the interactive prototype built during this session includes both; that's a reasonable prototyping tradeoff (fast iteration, see the stack note below) but a real gap between the declared Phase 1 boundary and what's actually been built.
- Concentrated solar foundry (Goal 3): a ring/array of diamond magnification lens devices (1cm thick) positioned near the sun, each oriented to focus incident sunlight toward a shared focal point — a foundry structure/device performing light-powered high-temperature material processing. Needs `thickness`/`material` device attributes and a way to express "many devices aimed at one functional target" distinct from `structureId` merging.
- Microwave power relay mesh, foundry to Earth (Goal 4): a distributed, non-laser power-delivery path — a microwave transmitter at the sun end, a scattered mesh of fixed power-relay stations connected to their nearest neighbors, and a rectenna at the Earth end that dynamically re-aims to the nearest relay as Earth orbits. Needs `deviceType` values for `microwave-transmitter`, `power-relay`, and `rectenna`, plus a link type distinct from `LaserLink` (a link carrying power, not data/topology) and a notion of dynamically-selected (not fixed) link endpoints.
- Infinite Compute, a black-hole compute cluster behind the sun (Goal 5): a new consumer type on the energy network — pure compute rather than an inhabited or industrial site — fed by a dedicated laser relay chain that's safe specifically because it never crosses near Earth. Needs `deviceType` values for `compute-cluster`, `laser-transmitter`, and `laser-relay`, and reinforces that link-safety constraints belong on the route/destination, not the transport technology itself.
- Survey ship, patrolling in front of the sun (Goal 6): first `deviceType` whose purpose is data collection rather than moving energy/material. Shares a single power source (the Laser Transmitter) with a destination on the opposite side of the sun (Infinite Compute), which surfaced the need for routing/bypass logic — a link can't always be a straight line if a body physically sits between the two endpoints.
- Solar observatories searching for a galactic data transmission (Goal 7): a device that observes its own orbital host (the sun) while independently, continuously scanning elsewhere (deep space and the sun itself) for something whose source isn't known yet — a "search" behavior distinct from every other device so far, which are all either fixed-purpose (mirror, lens) or fixed-route (relay, transmitter). Also the first goal to require checking a new device ring against existing orbits' distance ranges before placing it.

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

### Phase 1 Prototype — Actual Implementation (verbatim intent)

> what can we build this in fast - that will give us 3d, and navigate it with mouse and keyboard - simple simple simple [...] what language and code engine works across the most platforms - I am only worried about look - we can do 2d if we need to [...] lets do it for now - what ever - 3d or 2d - i just want to see it working in the next few mins with all my existing spec implemented

The working prototype (`index.html`) built during this session is a deliberate simplification of Option A, prioritizing speed-to-first-render and maximum reach over the documented recommendation:

- **Plain JavaScript, not TypeScript**: no build step, no compiler — the whole thing is one self-contained HTML file, openable directly or via any static file server.
- **Three.js loaded from a CDN (`<script>` tag, not a module/bundler)**, with `OrbitControls` for mouse navigation (drag/scroll/right-drag) and arrow keys for panning — satisfying "navigate it with mouse and keyboard" for free, no custom controls code.
- **Why this still satisfies "works across the most platforms"**: any browser, any OS/device, zero install — the actual constraint driving the 2D-vs-3D and language discussion in this addendum. 3D (WebGL) was chosen over 2D Canvas since the domain genuinely has depth (devices at different orbital planes, the galactic-line structures well outside the ecliptic), and WebGL support is close enough to universal (~98%+) that the reach tradeoff was worth it.
- **This is a prototyping shortcut, not a reversal of the recommendation**: revisit TypeScript + a real build pipeline (still Option A, just without the "no build step" shortcut) once the simulation grows past a single-file, single-session prototype — e.g. once Goal 1's active-maneuvering integrator or a real physics/render state-export boundary gets built.

## Open Questions

- N-body gravity (every body attracts every other body) vs. simplified model (planets follow fixed/Keplerian orbits around the sun, satellites do real N-body relative to their parent planet + sun perturbation)? N-body is more "correct" but more expensive and harder to keep numerically stable at solar-system scale over long simulated time.
- Units and scale: real-world AU/km/kg or a stylized scaled-down unit system for visualization purposes? The foundry/lens prototype surfaced a concrete version of this: meter-scale device spacing (a 500m lens-to-mirror gap) and AU-scale orbital distances don't fit one linear scaled unit system without either a non-uniform/logarithmic scale or rendering a clamped/exaggerated "visual" distance while keeping the true value as data.
- How many satellites, and around which planets, for the initial test scenario?
- Time controls (pause/speed/rewind) — Phase 1 or later?
- When does active maneuvering (Goal 1) get introduced — a later phase after gravity-only Phase 1 is working, or should the integrator be built from the start to accept an extra force term (thrust) alongside gravity? How is reconfiguration triggered — a scripted sequence, live user interaction, or both?
