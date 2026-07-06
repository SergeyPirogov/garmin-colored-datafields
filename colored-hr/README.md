# Garmin Colored HR

A Garmin Connect IQ data field for Edge cycling computers that displays heart rate with Wahoo-style zone colors.

## Features

- Full-screen background color changes with HR zone (like Wahoo ELEMNT)
- Large HR number centered on screen
- 5-segment zone color bar at the bottom with the active zone highlighted
- White border outline around the field
- Fully configurable HR zone thresholds via Garmin Connect app settings

## Zone Colors

| Zone | Color  | Default BPM range | Meaning       |
|------|--------|-------------------|---------------|
| Z1   | Gray   | ≤ 115             | Recovery      |
| Z2   | Blue   | 116–135           | Endurance     |
| Z3   | Green  | 136–155           | Aerobic/Tempo |
| Z4   | Orange | 156–175           | Threshold     |
| Z5   | Red    | > 175             | VO2 Max       |

Text is black on Z3 (green) for contrast, white on all other zones.

## Customizing Zones

Open the Garmin Connect app → Your device → Data Fields → Colored HR → Settings.  
Set the **upper BPM limit** for each zone (Zone 5 has no upper limit).

## Supported Devices

- Garmin Edge 850

## Development

### Requirements

- [Garmin Connect IQ SDK](https://developer.garmin.com/connect-iq/sdk/)
- A signing key (`developer_key.der`)

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
