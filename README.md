# Solar System Data Center — 3D Prototype

A single-file Three.js simulation of a solar-system-scale space infrastructure
network: satellites orbiting the sun and planets, connected by laser links,
powered by mirrors/lenses feeding a foundry, and relayed to Earth, a black
hole compute cluster, and a survey ship. See [spec.md](spec.md) for the full
design history and data model.

## Run it

No build step, no dependencies to install — it's one HTML file that loads
Three.js from a CDN (unpkg) at runtime.

**Easiest — just open the file:**

```
open index.html          # macOS
xdg-open index.html      # Linux
```

**Or serve it locally** (needed if your browser blocks `file://` script
loading, or you want to test on another device on your network). The
project's standardized dev port is **8123** — always use `serve.sh` rather
than an ad hoc `http.server` command so the URL stays predictable:

```bash
./serve.sh
# -> http://localhost:8123/index.html

PORT=9000 ./serve.sh   # override if 8123 is taken
```

Requires internet access on first load (to fetch Three.js + OrbitControls
from unpkg.com). Any modern browser with WebGL works — Chrome, Firefox,
Safari, Edge.

## Controls

- **Drag** — rotate camera
- **Scroll** — zoom
- **Right-drag** — pan
- **Arrow keys** — pan
- **Click** a body or a network link — select it and show its info panel (name, kind, function)

## What's implemented

- Sun + all planets on true Keplerian elliptical orbits (real eccentricity,
  period from Kepler's third law)
- Orbiting devices: solar collectors, mirrors, diamond lenses, observation
  satellites, relays, transmitters, rectennas, survey ship, mining ships
- Simulation speed control (never pauses) and a labels on/off toggle
- Laser links (data) and photon links (light) as lines between devices
- Concentrated solar foundry (static focal point) fed by a mirror/lens array
- Microwave relay mesh, guaranteed-connected, delivering power from the
  foundry to every planet's rectenna
- Earth Shipyard building autonomous mining ships that roam the system
- "Infinite Compute" black-hole cluster behind the sun, laser-powered
- Survey ship patrolling ahead of the heliosphere, powered by a multi-hop
  long-haul relay chain
- Click-to-select info panel for every body, device, and energy-network link

Full goal-by-goal history and the data model are in [spec.md](spec.md).
Raw session prompt history is preserved in [llm-prompt-log/](llm-prompt-log/).

## Status / next steps

This is a Phase 1 prototype: plain JS, no build step, single file, prioritizing
speed-to-first-render (see spec.md's "Phase 1 Prototype" section for why).
Not yet implemented: active maneuvering/thrust, dynamic laser-link topology,
scrapyard/device retirement logic, N-body mutual gravitation. See spec.md's
"Open Questions" and "Future Scope" for what's next.
