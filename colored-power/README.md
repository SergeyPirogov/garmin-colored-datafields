# Garmin Colored Power

A Garmin Connect IQ data field for Edge cycling computers that displays power with Wahoo-style zone colors.

## Features

- Full-screen background color changes with power zone (like Wahoo ELEMNT)
- Large power number centered on screen
- 6-segment zone color bar at the bottom with the active zone highlighted
- White border outline around the field
- Fully configurable power zone thresholds via Garmin Connect app settings

## Zone Colors

| Zone | Color  | Default Watts | Meaning         |
|------|--------|---------------|-----------------|
| Z1   | Gray   | ≤ 144         | Active Recovery |
| Z2   | Blue   | 145–195       | Endurance       |
| Z3   | Green  | 196–234       | Tempo           |
| Z4   | Yellow | 235–273       | Threshold       |
| Z5   | Red    | 274–312       | VO2 Max         |
| Z6   | Purple | > 312         | Anaerobic       |

Text is black on Z3 (green) and Z4 (yellow) for contrast, white on all other zones.

Defaults are based on a 260W FTP.

## Customizing Zones

Open the Garmin Connect app → Your device → Data Fields → Colored Power → Settings.  
Set the **upper watt limit** for each zone (Zone 6 has no upper limit).

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
