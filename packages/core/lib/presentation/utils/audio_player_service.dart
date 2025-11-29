import 'package:audioplayers/audioplayers.dart';

/// Service for managing audio playback across the application.
///
/// Provides synchronized sound effects for the proximity detection feature.
/// Preloads sounds for minimal latency during playback.
class AudioPlayerService {
  AudioPlayerService._();

  static final AudioPlayerService instance = AudioPlayerService._();

  final AudioPlayer _resonancePlayer = AudioPlayer();
  final AudioPlayer _miningPlayer = AudioPlayer();
  final AudioPlayer _ambientPlayer = AudioPlayer();

  bool _isEnabled = true;
  bool _isInitialized = false;
  double _volume = 1.0;

  /// Whether audio is enabled (can be toggled for accessibility)
  bool get isEnabled => _isEnabled;

  /// Current volume level (0.0 to 1.0)
  double get volume => _volume;

  /// Enable or disable audio
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
    if (!enabled) {
      stopAll();
    }
  }

  /// Set the volume level (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    await _resonancePlayer.setVolume(_volume);
    await _miningPlayer.setVolume(_volume);
    await _ambientPlayer.setVolume(_volume);
  }

  /// Initialize and preload audio assets
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Set player modes for low latency
      await _resonancePlayer.setPlayerMode(PlayerMode.lowLatency);
      await _miningPlayer.setPlayerMode(PlayerMode.lowLatency);
      await _ambientPlayer.setPlayerMode(PlayerMode.mediaPlayer);

      // Preload the resonance sound for heartbeat effect
      await _resonancePlayer.setSource(AssetSource('sounds/resonance.mp3'));

      _isInitialized = true;
    } catch (e) {
      // Gracefully handle missing audio files
      // Audio will simply not play if assets are missing
    }
  }

  /// Play the resonance sound (heartbeat pulse)
  ///
  /// [intensity] affects the volume (0.0 to 1.0)
  Future<void> playResonance({double intensity = 1.0}) async {
    if (!_isEnabled) return;

    try {
      await _resonancePlayer.setVolume(_volume * intensity);
      await _resonancePlayer.stop();
      await _resonancePlayer.resume();
    } catch (e) {
      // Silently fail if audio not available
    }
  }

  /// Play the mining impact sound
  Future<void> playMiningImpact() async {
    if (!_isEnabled) return;

    try {
      await _miningPlayer.setVolume(_volume);
      // TODO: Add mining sound asset
      // await _miningPlayer.play(AssetSource('sounds/mining_impact.mp3'));
    } catch (e) {
      // Silently fail if audio not available
    }
  }

  /// Play the crystal shatter sound
  Future<void> playCrystalShatter() async {
    if (!_isEnabled) return;

    try {
      await _miningPlayer.setVolume(_volume);
      // TODO: Add shatter sound asset
      // await _miningPlayer.play(AssetSource('sounds/crystal_shatter.mp3'));
    } catch (e) {
      // Silently fail if audio not available
    }
  }

  /// Start ambient sound loop
  Future<void> startAmbient() async {
    if (!_isEnabled) return;

    try {
      await _ambientPlayer.setVolume(_volume * 0.5);
      await _ambientPlayer.setReleaseMode(ReleaseMode.loop);
      // TODO: Add ambient sound asset
      // await _ambientPlayer.play(AssetSource('sounds/ambient.mp3'));
    } catch (e) {
      // Silently fail if audio not available
    }
  }

  /// Stop ambient sound
  Future<void> stopAmbient() async {
    await _ambientPlayer.stop();
  }

  /// Stop all audio playback
  Future<void> stopAll() async {
    await _resonancePlayer.stop();
    await _miningPlayer.stop();
    await _ambientPlayer.stop();
  }

  /// Dispose of audio players
  Future<void> dispose() async {
    await _resonancePlayer.dispose();
    await _miningPlayer.dispose();
    await _ambientPlayer.dispose();
    _isInitialized = false;
  }
}

