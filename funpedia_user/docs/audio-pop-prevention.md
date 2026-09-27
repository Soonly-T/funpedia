# Audio Pop Prevention Pattern

Use this pattern whenever generating short WAV tones or overlapping melodies.

## Waveform Rules

- Start every generated sound at exact sample value `0.0`.
- End every generated sound at exact sample value `0.0`.
- Use a smooth attack and release envelope; never jump directly between silence and full volume.
- For a 100 ms crossfade at a 44.1 kHz sample rate:

```dart
final crossfadeFrames = (0.1 * 44100).round();
```

A smooth equal-power style envelope:

```dart
final attack = math.min(1.0, frame / crossfadeFrames);
final release = math.min(
  1.0,
  (noteFrames - 1 - frame) / crossfadeFrames,
);
final attackCurve = 0.5 - 0.5 * math.cos(attack * math.pi);
final releaseCurve = 0.5 - 0.5 * math.cos(release * math.pi);
final envelope = attackCurve * releaseCurve;
```

For a standalone hover note, use a progress-based release so the last sample is guaranteed to be zero:

```dart
final progress = index / math.max(1, frameCount - 1);
final attackProgress = math.min(1.0, progress / 0.25);
final attack = math.sin(attackProgress * math.pi / 2);
final release = math.min(1.0, (1.0 - progress) / 0.35);
final envelope = attack * decay * release;
```

## Overlapping Notes

When notes overlap, add their samples. Do not overwrite an existing sample:

```dart
samples[sampleIndex] += noteSample * envelope * volume;
```

Use note start positions independently from note duration:

```dart
final offset = noteIndex * startIntervalFrames;
```

For example, a 220 ms note with a 110 ms start interval produces a 100 ms overlap.

## WAV Boundary Padding

Add a small silent buffer before and after generated audio. This protects against native audio backends that still click at a hard buffer boundary:

```dart
const silenceMs = 24;
final silenceFrames = (sampleRate * silenceMs / 1000).round();
final paddedSamples = <double>[
  ...List<double>.filled(silenceFrames, 0.0),
  ...samples,
  ...List<double>.filled(silenceFrames, 0.0),
];
```

## Player Lifecycle

- Do not call `stop()` immediately before playing a sound unless cutting off the previous sound is intentional. Native backends can click when stopped abruptly.
- Do not reuse one player for hover sounds and melodies. Starting a new source on the same player can interrupt the previous source and create a pop.
- Use a persistent melody player for press/reverse jingles.
- Use an isolated short-lived player for hover sounds, then dispose it after `onPlayerComplete`.
- Keep the melody player alive through route changes if a reverse jingle should continue while navigating.

## Platform Guard

If using `dart:io`, allow every intended native target:

```dart
bool get isSupported =>
    Platform.isAndroid ||
    Platform.isIOS ||
    Platform.isLinux ||
    Platform.isWindows ||
    Platform.isMacOS;
```

This does not support web builds because `dart:io` is unavailable there. Use conditional imports if web support is required.

## Common Causes Of Popping

1. The first or last audio sample is nonzero.
2. A note is cut off without a release envelope.
3. Overlapping notes overwrite each other instead of mixing.
4. A player replaces an active source.
5. `stop()` is called immediately before playback.
6. The generated WAV ends exactly at a nonzero sample.
7. The native backend has no silence padding around the buffer.
