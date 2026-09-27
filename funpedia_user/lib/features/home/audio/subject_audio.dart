import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:funpedia_user/features/home/domain/musical_note.dart';

class SubjectAudioPlayer {
  SubjectAudioPlayer();

  static const _noteVolume = 1.5;
  static const _hoverVolume = 1.5;
  static const _melodyVolume = 1.5;

  static final AudioContext _uiAudioContext = AudioContextConfig(
    focus: AudioContextConfigFocus.mixWithOthers,
  ).build();

  void playNote(MusicalNote note) {
    if (!_isSupported) return;

    final samples = _synthesizeKalimbaNote(note.frequency);
    final player = AudioPlayer();
    unawaited(_playOneShot(player, samples, volume: _noteVolume));
  }

  void playHoverNote(MusicalNote note) {
    if (!_isSupported) return;

    final samples = _synthesizeKalimbaNote(note.frequency);
    final player = AudioPlayer();
    unawaited(_playHoverSample(player, samples));
  }

  Future<void> _playHoverSample(
    AudioPlayer player,
    List<double> samples,
  ) async {
    try {
      await player.setVolume(_hoverVolume);
      await player.play(
        BytesSource(_buildWaveBytes(samples)),
        ctx: _uiAudioContext,
      );
      await player.onPlayerComplete.first;
    } finally {
      await player.dispose();
    }
  }

  void playMelody(Iterable<MusicalNote> notes, {bool reverse = false}) {
    if (!_isSupported) return;

    final melody = reverse ? notes.toList().reversed.toList() : notes.toList();
    if (melody.isEmpty) return;

    const noteDurationMs = 220;
    const noteStartIntervalMs = 110;
    const crossfadeMs = 100;
    const sampleRate = 44100;
    final totalSamples =
        (melody.length - 1) * noteStartIntervalMs + noteDurationMs;
    final samples = List<double>.filled(
      (sampleRate * totalSamples / 1000).round(),
      0.0,
      growable: false,
    );
    final noteFrames = (noteDurationMs / 1000 * sampleRate).round();
    final startIntervalFrames = (noteStartIntervalMs / 1000 * sampleRate)
        .round();
    final crossfadeFrames = (crossfadeMs / 1000 * sampleRate).round();

    for (var noteIndex = 0; noteIndex < melody.length; noteIndex++) {
      final note = melody[noteIndex];
      final offset = noteIndex * startIntervalFrames;

      for (var frame = 0; frame < noteFrames; frame++) {
        final sampleIndex = offset + frame;
        if (sampleIndex >= samples.length) break;

        final attack = math.min(1.0, frame / crossfadeFrames);
        final release = math.min(
          1.0,
          (noteFrames - 1 - frame) / crossfadeFrames,
        );
        final attackCurve = 0.5 - 0.5 * math.cos(attack * math.pi);
        final releaseCurve = 0.5 - 0.5 * math.cos(release * math.pi);
        final crossfadeEnvelope = attackCurve * releaseCurve;
        final time = frame / sampleRate;
        final pluckDecay = math.exp(-time * 5.5);
        final envelope = crossfadeEnvelope * pluckDecay;
        final phase = time * note.frequency * 2 * math.pi;
        final fundamental = math.sin(phase);
        final secondHarmonic = math.sin(phase * 2.01) * 0.10;
        final thirdHarmonic = math.sin(phase * 3.02) * 0.025;
        final kalimbaVoice =
            fundamental * 0.88 + secondHarmonic + thirdHarmonic;
        samples[sampleIndex] += kalimbaVoice * (0.09 * envelope);
      }
    }

    final player = AudioPlayer();
    unawaited(
      _playOneShot(player, _smoothMelody(samples), volume: _melodyVolume),
    );
  }

  List<double> _smoothMelody(List<double> samples) {
    if (samples.isEmpty) return samples;

    const smoothing = 0.22;
    var previous = samples.first;
    final smoothed = List<double>.filled(samples.length, 0.0);
    smoothed[0] = previous;

    for (var index = 1; index < samples.length; index++) {
      previous += (samples[index] - previous) * smoothing;
      smoothed[index] = previous;
    }

    return smoothed;
  }

  Future<void> _playOneShot(
    AudioPlayer player,
    List<double> samples, {
    required double volume,
  }) async {
    try {
      await player.setVolume(volume);
      await player.play(BytesSource(_buildWaveBytes(samples)));
      await player.onPlayerComplete.first;
    } finally {
      await player.dispose();
    }
  }

  List<double> _synthesizeKalimbaNote(double frequency) {
    const sampleRate = 44100;
    const durationMs = 240;
    final frameCount = (durationMs / 1000 * sampleRate).round();

    return List<double>.generate(frameCount, (index) {
      final progress = index / math.max(1, frameCount - 1);
      final time = index / sampleRate;
      final attackProgress = math.min(1.0, progress / 0.25);
      final attack = math.sin(attackProgress * math.pi / 2);
      final decay = math.exp(-time * 12.0);
      final release = math.min(1.0, (1.0 - progress) / 0.35);
      final envelope = attack * decay * release;
      final phase = time * frequency * 2 * math.pi;
      final fundamental = math.sin(phase);
      final secondHarmonic = math.sin(phase * 2.01) * 0.10;
      final thirdHarmonic = math.sin(phase * 3.02) * 0.025;
      return (fundamental * 0.88 + secondHarmonic + thirdHarmonic) *
          (0.10 * envelope);
    });
  }

  Uint8List _buildWaveBytes(List<double> samples) {
    const sampleRate = 44100;
    const bitsPerSample = 16;
    const byteRate = sampleRate * 2;
    const blockAlign = 2;
    const silenceMs = 24;
    final silenceFrames = (sampleRate * silenceMs / 1000).round();
    final paddedSamples = <double>[
      ...List<double>.filled(silenceFrames, 0.0),
      ...samples,
      ...List<double>.filled(silenceFrames, 0.0),
    ];
    final dataSize = paddedSamples.length * 2;
    final buffer = BytesBuilder();

    buffer.add(_ascii('RIFF'));
    buffer.add(_int32(36 + dataSize));
    buffer.add(_ascii('WAVE'));
    buffer.add(_ascii('fmt '));
    buffer.add(_int32(16));
    buffer.add(_int16(1));
    buffer.add(_int16(1));
    buffer.add(_int32(sampleRate));
    buffer.add(_int32(byteRate));
    buffer.add(_int16(blockAlign));
    buffer.add(_int16(bitsPerSample));
    buffer.add(_ascii('data'));
    buffer.add(_int32(dataSize));

    for (final sample in paddedSamples) {
      final value = (sample * 32767).clamp(-32768.0, 32767.0).round();
      buffer.add(_int16(value));
    }

    return buffer.toBytes();
  }

  bool get _isSupported =>
      Platform.isAndroid ||
      Platform.isIOS ||
      Platform.isLinux ||
      Platform.isWindows ||
      Platform.isMacOS;

  List<int> _ascii(String value) => value.codeUnits;
  List<int> _int16(int value) => [value & 0xff, (value >> 8) & 0xff];
  List<int> _int32(int value) => [
    value & 0xff,
    (value >> 8) & 0xff,
    (value >> 16) & 0xff,
    (value >> 24) & 0xff,
  ];

  Future<void> dispose() async {}
}
