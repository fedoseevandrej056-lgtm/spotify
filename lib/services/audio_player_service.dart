import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'dart:async';
import '../models/song_model.dart';

enum AppPlayerState {
  idle,
  playing,
  paused,
  stopped,
}

class AudioPlayerService extends ChangeNotifier {
  late AudioPlayer _audioPlayer;

  List<Song> _songs = [];
  int _currentSongIndex = -1;
  AppPlayerState _playerState = AppPlayerState.idle;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  Timer? _playbackTimer;
  bool _disposed = false;

  AudioPlayerService() {
    _initializePlayer();
  }

  void _initializePlayer() async {
    _audioPlayer = AudioPlayer();

    _audioPlayer.positionStream.listen((position) {
      _currentPosition = position;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_disposed) notifyListeners();
      });
    });

    _audioPlayer.durationStream.listen((duration) {
      if (duration != null) {
        _totalDuration = duration;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_disposed) notifyListeners();
        });
      }
    });

    _audioPlayer.playerStateStream.listen((state) {
      _updatePlayerState(state);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_disposed) notifyListeners();
      });
    });
  }

  void _updatePlayerState(state) {
    if (state.playing) {
      _playerState = AppPlayerState.playing;
    } else {
      switch (state.processingState) {
        case ProcessingState.idle:
          _playerState = AppPlayerState.idle;
          break;
        case ProcessingState.loading:
        case ProcessingState.buffering:
          _playerState = AppPlayerState.playing;
          break;
        case ProcessingState.ready:
          _playerState = AppPlayerState.paused;
          break;
        case ProcessingState.completed:
          _playerState = AppPlayerState.stopped;
          _currentSongIndex = -1;
          break;
      }
    }
  }

  // Simulate playback for demo/web
  void _simulatePlayback() {
    _playbackTimer?.cancel();
    if (_playerState == AppPlayerState.playing && _songs.isNotEmpty) {
      _playbackTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        if (_playerState == AppPlayerState.playing && !_disposed) {
          _currentPosition = Duration(
            milliseconds: _currentPosition.inMilliseconds + 100,
          );

          if (_currentPosition >= _totalDuration) {
            next();
          } else {
            if (!_disposed) notifyListeners();
          }
        }
      });
    }
  }

  Future<void> loadPlaylist(List<Song> songs) async {
    _songs = songs;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_disposed) notifyListeners();
    });
  }

  Future<void> playSong(int index) async {
    if (index < 0 || index >= _songs.length) {
      return;
    }

    _currentSongIndex = index;
    _playerState = AppPlayerState.playing;
    _currentPosition = Duration.zero;
    _totalDuration = _songs[index].duration;
    _simulatePlayback();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_disposed) notifyListeners();
    });
  }

  Future<void> play() async {
    try {
      if (_currentSongIndex == -1 && _songs.isNotEmpty) {
        await playSong(0);
      } else {
        _playerState = AppPlayerState.playing;
        _simulatePlayback();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error playing: $e');
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_disposed) notifyListeners();
    });
  }

  Future<void> pause() async {
    try {
      _playerState = AppPlayerState.paused;
      _playbackTimer?.cancel();
    } catch (e) {
      if (kDebugMode) {
        print('Error pausing: $e');
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_disposed) notifyListeners();
    });
  }

  Future<void> stop() async {
    try {
      _playerState = AppPlayerState.stopped;
      _currentSongIndex = -1;
      _currentPosition = Duration.zero;
      _playbackTimer?.cancel();
    } catch (e) {
      if (kDebugMode) {
        print('Error stopping: $e');
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_disposed) notifyListeners();
    });
  }

  Future<void> next() async {
    if (_currentSongIndex < _songs.length - 1) {
      await playSong(_currentSongIndex + 1);
    } else {
      await stop();
    }
  }

  Future<void> previous() async {
    if (_currentSongIndex > 0) {
      await playSong(_currentSongIndex - 1);
    } else if (_currentSongIndex >= 0) {
      _currentPosition = Duration.zero;
      if (!_disposed) notifyListeners();
    }
  }

  Future<void> seek(Duration position) async {
    try {
      if (position < Duration.zero) {
        _currentPosition = Duration.zero;
      } else if (position > _totalDuration) {
        _currentPosition = _totalDuration;
      } else {
        _currentPosition = position;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error seeking: $e');
      }
    }
    if (!_disposed) notifyListeners();
  }

  Future<void> setPlaybackRate(double rate) async {
    try {
      await _audioPlayer.setSpeed(rate);
    } catch (e) {
      if (kDebugMode) {
        print('Error setting playback rate: $e');
      }
    }
  }

  // Getters
  List<Song> get songs => _songs;
  int get currentSongIndex => _currentSongIndex;
  Song? get currentSong => _currentSongIndex >= 0 ? _songs[_currentSongIndex] : null;
  AppPlayerState get playerState => _playerState;
  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;
  bool get isPlaying => _playerState == AppPlayerState.playing;
  double get progress =>
      _totalDuration.inMilliseconds > 0
          ? _currentPosition.inMilliseconds / _totalDuration.inMilliseconds
          : 0.0;

  @override
  void dispose() {
    _playbackTimer?.cancel();
    _disposed = true;
    _audioPlayer.dispose();
    super.dispose();
  }
}
