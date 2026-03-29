import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart';
import '../models/song_model.dart';

class AdvancedAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  final AudioPlayer _player = AudioPlayer();
  final ConcatenatingAudioSource _playlist = ConcatenatingAudioSource(children: []);

  AdvancedAudioHandler() {
    _init();
  }

  Future<void> _init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    _player.playbackEventStream.listen((event) {
      playbackState.add(playbackState.value.copyWith(
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
        playing: _player.playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        processingState: _mapProcessingState(_player.processingState),
      ));
    });

    _player.currentIndexStream.listen((index) {
      if (index != null && index < queue.value.length) {
        mediaItem.add(queue.value[index]);
      }
    });

    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        stop();
      }
    });
  }

  PlaybackState _mapProcessingState(ProcessingState state) {
    switch (state) {
      case ProcessingState.idle:
        return PlaybackState(state: AudioProcessingState.idle);
      case ProcessingState.loading:
        return PlaybackState(state: AudioProcessingState.loading);
      case ProcessingState.buffering:
        return PlaybackState(state: AudioProcessingState.buffering);
      case ProcessingState.ready:
        return PlaybackState(state: AudioProcessingState.ready);
      case ProcessingState.completed:
        return PlaybackState(state: AudioProcessingState.completed);
    }
  }

  @override
  Future<void> addQueueItems(List<MediaItem> items) async {
    final sources = items.map((i) {
      return AudioSource.uri(Uri.parse(i.extras?['uri'] ?? ''));
    }).toList();
    await _playlist.clear();
    await _playlist.addAll(sources);
    queue.add(items);
    await _player.setAudioSource(_playlist, initialIndex: 0);
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> skipToNext() => _player.seekToNext();

  @override
  Future<void> skipToPrevious() => _player.seekToPrevious();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  Future<void> setTrack(Song song) async {
    final artUri = song.albumArt != null && song.albumArt!.isNotEmpty
        ? Uri.parse(song.albumArt!)
        : null;

    final item = MediaItem(
      id: song.id,
      album: song.album,
      title: song.title,
      artist: song.artist,
      duration: song.duration,
      artUri: artUri,
      extras: {'uri': song.filePath},
    );
    mediaItem.add(item);
    await _player.setAudioSource(AudioSource.uri(Uri.parse(song.filePath)));
    await play();
  }
}
