# garmin-datafields

Monorepo of two Garmin Connect IQ data fields for Edge cycling computers, styled after Wahoo ELEMNT zone coloring:

- `colored-hr/` — heart rate data field, zones read from the Garmin user profile
- `colored-power/` — power data field, zones derived from an FTP setting with a configurable rolling average

Each project is a standalone Connect IQ project (`monkey.jungle`, `manifest.xml`, `source/`, `resources/`) — see each project's README for zone tables and settings.

## Build

```bash
./build.sh
```

Builds both projects' `.iq` packages into `dist/` (gitignored). It resolves `monkeyc` from the Connect IQ SDK's `current-sdk.cfg` and signs with a developer key at `../garmin-colored-hr/developer_key.der` by default. Override with `MONKEYC` / `DEVELOPER_KEY` env vars. The script also deletes each project's stale build artifacts (`bin/`, `gen/`, `mir/`, `internal-mir/`, `external-mir/`, loose `.iq`/`.prg`) before rebuilding.

To build/run a single project directly with `monkeyc`/`monkeydo`, see that project's README.

## Conventions

- Both views (`ColoredHRView.mc`, `ColoredPowerView.mc`) follow the same structure: load zone thresholds in `loadSettings`/`loadZones`, compute the current zone in `compute`, draw background/text/zone-bar in `onUpdate`. Keep the two in sync when changing shared behavior (e.g. text contrast rules, border style).
- Zone background colors are Wahoo-style: gray/blue/green/yellow-or-orange/red(/purple for power's 6th zone). Text color is white except on the zone whose background is light enough to need black for contrast (currently Zone 4 in both fields).
- Don't hand-edit generated build artifacts (`bin/`, `gen/`, `mir/`, `*.prg`, `*.iq`) — they're produced by `build.sh` or `monkeyc` and are gitignored.
