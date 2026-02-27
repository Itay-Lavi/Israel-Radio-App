import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

/// A custom [AudioHandler] that bridges [just_audio] with [audio_service].
///
/// This gives us full control over the foreground-service lifecycle —
/// in particular `androidStopForegroundOnPause: false` keeps the service
/// alive even when audio is paused, which prevents the OS from killing
/// the player when the user swipes the app away.
class RadioAudioHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayer _player = AudioPlayer();

  /// Stream that surfaces playback errors to the UI.
  final StreamController<(Object, StackTrace)> errorController =
      StreamController.broadcast();

  RadioAudioHandler() {
    // Forward just_audio player-state changes into audio_service's
    // playbackState broadcast stream.
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);

    // Forward stream-level errors (dropped connection, etc.)
    _player.playbackEventStream.listen(null,
        onError: (Object e, StackTrace st) {
      errorController.add((e, st));
    });
  }

  AudioPlayer get player => _player;

  // ---------------------------------------------------------------------------
  // Transport controls
  // ---------------------------------------------------------------------------

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await _player.stop();
    return super.stop();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  // ---------------------------------------------------------------------------
  // Custom actions
  // ---------------------------------------------------------------------------

  /// Load a radio channel.
  ///
  /// Expected extras:
  /// ```
  /// {
  ///   'id':       String,   // channel id
  ///   'title':    String,   // channel display name
  ///   'url':      String,   // stream URL
  ///   'imageUrl': String,   // artwork URL
  ///   'autoPlay': 'true' | 'false',
  /// }
  /// ```
  @override
  Future<dynamic> customAction(String name,
      [Map<String, dynamic>? extras]) async {
    if (name == 'setChannel') {
      return _setChannel(extras!);
    }
    return super.customAction(name, extras);
  }

  Future<void> _setChannel(Map<String, dynamic> extras) async {
    final id = extras['id'] as String;
    final title = extras['title'] as String;
    final url = extras['url'] as String;
    final imageUrl = extras['imageUrl'] as String;
    final autoPlay = extras['autoPlay'] == 'true';

    // Update the media-notification metadata
    mediaItem.add(MediaItem(
      id: id,
      title: title,
      artUri: Uri.parse(imageUrl),
    ));

    try {
      await _player.stop();
      _player
          .setAudioSource(AudioSource.uri(Uri.parse(url)))
          .catchError((Object e, StackTrace st) {
        errorController.add((e, st));
        return null;
      });

      if (autoPlay) {
        _player.play();
      }
    } catch (e, st) {
      errorController.add((e, st));
    }
  }

  // ---------------------------------------------------------------------------
  // State mapping
  // ---------------------------------------------------------------------------

  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.skipToNext,
        MediaControl.stop,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 2],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: event.currentIndex,
    );
  }

  @override
  Future<void> onTaskRemoved() async {
    // Do NOT stop — keep the foreground service alive.
    // The androidStopForegroundOnPause:false config ensures this.
  }
}
