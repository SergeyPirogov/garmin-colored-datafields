# Garmin Data Fields

Garmin Connect IQ data fields for Edge cycling computers with Wahoo-style zone coloring.

## Fields

### [colored-hr](colored-hr/)
Full-screen background color based on heart rate zone (Z1–Z5).

### [colored-power](colored-power/)
Full-screen background color based on 3s power zone (Z1–Z6).

## Development

### Requirements

- [Garmin Connect IQ SDK](https://developer.garmin.com/connect-iq/sdk/)
- A signing key (`developer_key.der`)

### Build

```bash
SDK="/path/to/connectiq-sdk/bin"

# HR field
"$SDK/monkeyc" --output colored-hr/garmincoloredhr.prg \
  --jungles colored-hr/monkey.jungle --device edge850 \
  --private-key developer_key.der --warn

# Power field
"$SDK/monkeyc" --output colored-power/garmincoloredpower.prg \
  --jungles colored-power/monkey.jungle --device edge850 \
  --private-key developer_key.der --warn
```

### Run in Simulator

```bash
open "$SDK/ConnectIQ.app"
"$SDK/monkeydo" colored-hr/garmincoloredhr.prg edge850
"$SDK/monkeydo" colored-power/garmincoloredpower.prg edge850
```
