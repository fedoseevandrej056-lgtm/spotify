import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../models/song_model.dart';
import '../models/playlist_model.dart';

class MusicLibraryService extends ChangeNotifier {
  List<Song> _allSongs = [];
  List<Playlist> _playlists = [];
  bool _isLoading = false;

  MusicLibraryService() {
    _initializeLibrary();
  }

  Future<void> _initializeLibrary() async {
    _isLoading = true;
    notifyListeners();
    try {
      // Load demo songs first
      _loadDemoSongs();
      await _loadSongsFromDocuments();
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing library: $e');
      }
    }
    _isLoading = false;
    notifyListeners();
  }

  void _loadDemoSongs() {
    final demoSongs = [
      Song(
        id: '1',
        title: 'Summer Vibes',
        artist: 'The Weeknd',
        album: 'Starboy',
        filePath: 'demo_path_1',
        duration: const Duration(minutes: 3, seconds: 45),
      ),
      Song(
        id: '2',
        title: 'Blinding Lights',
        artist: 'The Weeknd',
        album: 'After Hours',
        filePath: 'demo_path_2',
        duration: const Duration(minutes: 3, seconds: 20),
      ),
      Song(
        id: '3',
        title: 'Levitating',
        artist: 'Dua Lipa',
        album: 'Future Nostalgia',
        filePath: 'demo_path_3',
        duration: const Duration(minutes: 3, seconds: 23),
      ),
      Song(
        id: '4',
        title: 'Good 4 U',
        artist: 'Olivia Rodrigo',
        album: 'SOUR',
        filePath: 'demo_path_4',
        duration: const Duration(minutes: 2, seconds: 58),
      ),
      Song(
        id: '5',
        title: 'As It Was',
        artist: 'Harry Styles',
        album: 'Harry\'s House',
        filePath: 'demo_path_5',
        duration: const Duration(minutes: 2, seconds: 32),
      ),
    ];
    
    if (_allSongs.isEmpty) {
      _allSongs.addAll(demoSongs);
    }
  }

  Future<void> _loadSongsFromDocuments() async {
    try {
      final docsDir = await getApplicationDocumentsDirectory();
      final musicDir = Directory('${docsDir.path}/Music');

      if (!await musicDir.exists()) {
        await musicDir.create(recursive: true);
      }

      final files = musicDir.listSync();
      _allSongs.clear();

      for (var file in files) {
        if (file is File) {
          final extension = file.path.split('.').last.toLowerCase();
          if (['mp3', 'm4a', 'wav', 'aac'].contains(extension)) {
            final song = Song(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: file.path.split('/').last,
              artist: 'Unknown Artist',
              album: 'My Music',
              filePath: file.path,
              duration: const Duration(seconds: 180),
            );
            _allSongs.add(song);
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading songs from documents: $e');
      }
    }
  }

  Future<void> importSongsFromFiles() async {
    // Demo songs for testing
    final demoSongs = [
      Song(
        id: '1',
        title: 'Summer Vibes',
        artist: 'The Weeknd',
        album: 'Starboy',
        filePath: 'demo_path_1',
        duration: const Duration(minutes: 3, seconds: 45),
      ),
      Song(
        id: '2',
        title: 'Blinding Lights',
        artist: 'The Weeknd',
        album: 'After Hours',
        filePath: 'demo_path_2',
        duration: const Duration(minutes: 3, seconds: 20),
      ),
      Song(
        id: '3',
        title: 'Levitating',
        artist: 'Dua Lipa',
        album: 'Future Nostalgia',
        filePath: 'demo_path_3',
        duration: const Duration(minutes: 3, seconds: 23),
      ),
      Song(
        id: '4',
        title: 'Good 4 U',
        artist: 'Olivia Rodrigo',
        album: 'SOUR',
        filePath: 'demo_path_4',
        duration: const Duration(minutes: 2, seconds: 58),
      ),
      Song(
        id: '5',
        title: 'As It Was',
        artist: 'Harry Styles',
        album: 'Harry\'s House',
        filePath: 'demo_path_5',
        duration: const Duration(minutes: 2, seconds: 32),
      ),
    ];
    
    _allSongs.clear();
    _allSongs.addAll(demoSongs);
    notifyListeners();
  }

  void createPlaylist(String name, {String? description}) {
    final playlist = Playlist(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: description,
    );
    _playlists.add(playlist);
    notifyListeners();
  }

  void addSongsToPlaylist(String playlistId, List<Song> songs) {
    final playlistIndex =
        _playlists.indexWhere((p) => p.id == playlistId);
    if (playlistIndex != -1) {
      final playlist = _playlists[playlistIndex];
      final updatedSongs = [...playlist.songs, ...songs];
      _playlists[playlistIndex] = playlist.copyWith(songs: updatedSongs);
      notifyListeners();
    }
  }

  void removeSongFromPlaylist(String playlistId, String songId) {
    final playlistIndex =
        _playlists.indexWhere((p) => p.id == playlistId);
    if (playlistIndex != -1) {
      final playlist = _playlists[playlistIndex];
      final updatedSongs =
          playlist.songs.where((s) => s.id != songId).toList();
      _playlists[playlistIndex] = playlist.copyWith(songs: updatedSongs);
      notifyListeners();
    }
  }

  void deletePlaylist(String playlistId) {
    _playlists.removeWhere((p) => p.id == playlistId);
    notifyListeners();
  }

  void deleteSong(String songId) {
    _allSongs.removeWhere((s) => s.id == songId);
    notifyListeners();
  }

  // Getters
  List<Song> get allSongs => _allSongs;
  List<Playlist> get playlists => _playlists;
  bool get isLoading => _isLoading;
  int get songCount => _allSongs.length;
  int get playlistCount => _playlists.length;
}
