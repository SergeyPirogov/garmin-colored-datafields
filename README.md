# Garmin Data Fields

Garmin Connect IQ data fields for Edge cycling computers with Wahoo-style zone coloring.

## Fields

### [colored-hr](colored-hr/)
Full-screen background color based on heart rate zone (Z1–Z5), read from your Garmin user profile.

### [colored-power](colored-power/)
Full-screen background color based on power zone (Z1–Z6), derived from your FTP with a configurable rolling average.

## Development

### Requirements

- [Garmin Connect IQ SDK](https://developer.garmin.com/connect-iq/sdk/)
- A signing key (`developer_key.der`)

### Build

Build both fields' `.iq` packages at once with the repo-level script:

```bash
./build.sh
```

This locates `monkeyc` via the Connect IQ SDK's `current-sdk.cfg`, cleans each project's stale build artifacts, and writes `dist/colored-hr.iq` and `dist/colored-power.iq`.

- Override the SDK's `monkeyc` binary with `MONKEYC=/path/to/monkeyc`.
- Override the signing key with `DEVELOPER_KEY=/path/to/developer_key.der` (defaults to `../garmin-colored-hr/developer_key.der`).

To build a single field's `.prg` for the simulator instead:

```bash
SDK="/path/to/connectiq-sdk/bin"

"$SDK/monkeyc" --output colored-hr/garmincoloredhr.prg \
  --jungles colored-hr/monkey.jungle --device edge850 \
  --private-key developer_key.der --warn
```

### Run in Simulator

```bash
open "$SDK/ConnectIQ.app"
"$SDK/monkeydo" colored-hr/garmincoloredhr.prg edge850
"$SDK/monkeydo" colored-power/garmincoloredpower.prg edge850
```
