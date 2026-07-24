# Garmin Colored Power

A Garmin Connect IQ data field for Edge cycling computers that displays power with Wahoo-style zone colors.

## Features

- Full-screen background color changes with power zone (like Wahoo ELEMNT)
- Large power number centered on screen, using a configurable rolling average
- 6-segment zone color bar at the bottom with the active zone highlighted
- White border outline around the field
- Zones derived automatically from your FTP

## Zone Colors

Zones are computed as a percentage of your FTP (Coggan power zones). With the default 260W FTP:

| Zone | Color  | % FTP    | Default Watts | Meaning         |
|------|--------|----------|----------------|-----------------|
| Z1   | Gray   | ≤ 55%    | ≤ 143          | Active Recovery |
| Z2   | Blue   | 56–75%   | 144–195        | Endurance       |
| Z3   | Green  | 76–90%   | 196–234        | Tempo           |
| Z4   | Yellow | 91–105%  | 235–273        | Threshold       |
| Z5   | Red    | 106–125% | 274–325        | VO2 Max         |
| Z6   | Purple | > 125%   | > 325          | Anaerobic       |

Text is black on Z4 (yellow) for contrast, white on all other zones.

## Settings

Open the Garmin Connect app → Your device → Data Fields → Colored Power → Settings.

- **FTP (watts)** — your functional threshold power; zone thresholds are recalculated from this. Defaults to 260W.
- **Power Averaging** — Instant, 3s, 5s, or 10s rolling average of power. Defaults to 3s.

## Supported Devices

- Garmin Edge 850

## Development

### Requirements

- [Garmin Connect IQ SDK](https://developer.garmin.com/connect-iq/sdk/)
- A signing key (`developer_key.der`)

Use the repo-level [`build.sh`](../build.sh) to build both data fields at once into `dist/`. The commands below are for building this project directly.

### Build .prg (simulator / sideload)

```bash
SDK="/path/to/connectiq-sdk/bin"

"$SDK/monkeyc" \
  -f monkey.jungle \
  -o garmincoloredpower.prg \
  -d edge850 \
  -y developer_key.der
```

### Build .iq (Connect IQ store submission)

```bash
"$SDK/monkeyc" \
  -f monkey.jungle \
  -o garmincoloredpower.iq \
  -e \
  -y developer_key.der
```

### Run in Simulator

```bash
# Launch the simulator
open "$SDK/ConnectIQ.app"

# Load the app
"$SDK/monkeydo" garmincoloredpower.prg edge850
```
