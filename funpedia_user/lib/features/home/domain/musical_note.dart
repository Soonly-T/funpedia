class MusicalNote {
  const MusicalNote(this.name, this.frequency);

  final String name;
  final double frequency;

  @override
  String toString() => name;
}

abstract final class Note {
  static const b2 = MusicalNote('B2', 123.47);
  static const c2 = MusicalNote('C2', 65.41);
  static const c3 = MusicalNote('C3', 130.81);
  static const d3 = MusicalNote('D3', 146.83);
  static const ds4 = MusicalNote('D#4', 311.13);
  static const e3 = MusicalNote('E3', 164.81);
  static const f3 = MusicalNote('F3', 174.61);
  static const fs3 = MusicalNote('F#3', 185.00);
  static const g3 = MusicalNote('G3', 196.00);
  static const gs3 = MusicalNote('G#3', 207.65);
  static const a3 = MusicalNote('A3', 220.00);
  static const as3 = MusicalNote('A#3', 233.08);
  static const b3 = MusicalNote('B3', 246.94);
  static const c4 = MusicalNote('C4', 261.63);
  static const cs4 = MusicalNote('C#4', 277.18);
  static const d4 = MusicalNote('D4', 293.66);
  static const eb4 = MusicalNote('Eb4', 311.13);
  static const e4 = MusicalNote('E4', 329.63);
  static const f4 = MusicalNote('F4', 349.23);
  static const fs4 = MusicalNote('F#4', 369.99);
  static const g4 = MusicalNote('G4', 392.00);
  static const a4 = MusicalNote('A4', 440.00);
  static const as4 = MusicalNote('A#4', 466.16);
  static const bb4 = MusicalNote('Bb4', 466.16);
  static const b4 = MusicalNote('B4', 493.88);
  static const c5 = MusicalNote('C5', 523.25);
  static const cs5 = MusicalNote('C#5', 554.37);
  static const d5 = MusicalNote('D5', 587.33);
  static const eb5 = MusicalNote('Eb5', 622.25);
  static const e5 = MusicalNote('E5', 659.25);
  static const f5 = MusicalNote('F5', 698.46);
  static const fs5 = MusicalNote('F#5', 740.00);
  static const g5 = MusicalNote('G5', 783.99);
  static const gs5 = MusicalNote('G#5', 830.61);
  static const a5 = MusicalNote('A5', 880.00);
  static const bb5 = MusicalNote('Bb5', 932.33);
  static const b5 = MusicalNote('B5', 987.77);
  static const c6 = MusicalNote('C6', 1046.50);
  static const d6 = MusicalNote('D6', 1174.66);
}
