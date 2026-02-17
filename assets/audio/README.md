# Audio Assets

This directory contains drum loop audio files for the Drill mode.

## Required Files

The app supports multiple BPM audio files for better sound quality:

| File | BPM | Usage |
|------|-----|-------|
| `drum_house_128bpm.wav` | 128 | For high BPM (110-130) |
| `drum_hiphop_90bpm.mp3` | 90 | For medium BPM (70-110) |
| `drum_slow_60bpm.mp3` | 60 | For low BPM (60-70) |

## How It Works

- When user selects a BPM, the app automatically selects the closest audio file
- Playback speed is adjusted slightly to match the exact BPM
- This approach maintains better audio quality than large speed changes

## Example

- User selects 100 BPM → Uses 90 BPM audio at 1.11x speed
- User selects 120 BPM → Uses 128 BPM audio at 0.94x speed
- User selects 65 BPM → Uses 60 BPM audio at 1.08x speed

## Notes

- Use high-quality drum loops that loop seamlessly
- 4/4 time signature works best
- WAV format preferred for quality, MP3 for smaller file size

## Where to find drum loops

You can find royalty-free drum loops at:
- https://freedrumloops.com/
- https://looperman.com/
- https://samplefocus.com/

Or create your own using:
- FL Studio
- Ableton Live
- GarageBand
