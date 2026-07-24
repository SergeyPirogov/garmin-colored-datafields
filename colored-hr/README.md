# Garmin Colored HR

A Garmin Connect IQ data field for Edge cycling computers that displays heart rate with Wahoo-style zone colors.

## Features

- Full-screen background color changes with HR zone (like Wahoo ELEMNT)
- Large HR number centered on screen
- 5-segment zone color bar at the bottom with the active zone highlighted
- White border outline around the field
- Zone thresholds loaded automatically from your Garmin user profile

## Zone Colors

| Zone | Color  | Meaning       |
|------|--------|---------------|
| Z1   | Gray   | Recovery      |
| Z2   | Blue   | Endurance     |
| Z3   | Green  | Aerobic/Tempo |
| Z4   | Orange | Threshold     |
| Z5   | Red    | VO2 Max       |

Text is black on Z4 (orange) for contrast, white on all other zones.

## Zone Thresholds

BPM thresholds come from your Garmin Connect user profile's generic heart rate zones — there are no zone settings to configure on the data field itself.

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
  -o garmincoloredhr.prg \
  -d edge850 \
  -y developer_key.der
```

### Build .iq (Connect IQ store submission)

```bash
"$SDK/monkeyc" \
  -f monkey.jungle \
  -o garmincoloredhr.iq \
  -e \
  -y developer_key.der
```

### Run in Simulator

```bash
# Launch the simulator
open "$SDK/ConnectIQ.app"

# Load the app
"$SDK/monkeydo" garmincoloredhr.prg edge850
```
