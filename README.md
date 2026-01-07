# Crossing Binoculars

Crossing-Binoculars is a lightweight, client-authoritative binocular system for RedM servers.

It enhances the vanilla binocular experience by adding camera sway, distance measurement, and a directional compass, while fully preserving Red Dead Redemption 2’s built-in animal information.

Designed for RSG Framework servers and written to be stable, performant, and non-vanilla without being intrusive.

## Features
- **Normal Binoculars**: Fixed zoom, basic sway, and cardinal directions.
- **Improved Binoculars**: Adjustable zoom, enhanced stability, precise distance, and directional accuracy.

## Notes
- Normal binoculars use RedM’s native zoom behavior.
- Improved binoculars enhance stability, precision, and directional accuracy.

## Configuration
- Adjust sway and precision in `config.lua`.
- Normal binoculars:
  - Sway: 0.65
  - Distance Precision: 5.0
- Improved binoculars:
  - Sway: 0.18
  - Distance Precision: 1.0

## Controls
- **Right Mouse Button**: Activate binoculars.
- **Scroll Wheel**: Zoom (Improved Binoculars only).

📦 Requirements

RedM

RSG Framework

ox_lib (optional, recommended)

🔧 Installation

Download or clone this repository

Place the folder into your resources directory:

resources/crossing-binoculars


Add to your server.cfg:

ensure crossing-binoculars