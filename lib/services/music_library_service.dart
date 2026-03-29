import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import '../models/song_model.dart';
import '../models/playlist_model.dart';

class MusicLibraryService extends ChangeNotifier {
  final List<Song> _allSongs = [];
  final List<Playlist> _playlists = [];
  bool _isLoading = false;

  MusicLibraryService() {
    _initializeLibrary();
  }

  Future<void> _initializeLibrary() async {
    _isLoading = true;
    notifyListeners();
    try {
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
    if (_allSongs.isEmpty) {
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
      ];
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

      for (var file in files) {
        if (file is File) {
          final extension = file.path.split('.').last.toLowerCase();
          if (['mp3', 'm4a', 'wav', 'aac', 'flac'].contains(extension)) {
            final fileName = file.path.split('/').last;
            final song = Song(
              id: file.path.hashCode.toString(),
              title: fileName.replaceAll('.${extension}', ''),
              artist: 'Local File',
              album: 'My Music',
              filePath: file.path,
              duration: const Duration(seconds: 180),
            );
            if (!_allSongs.any((s) => s.filePath == file.path)) {
              _allSongs.add(song);
            }
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
    try {
      _isLoading = true;
      notifyListeners();

      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: true,
        allowedExtensions: ['mp3', 'm4a', 'wav', 'aac', 'flac'],
      );

      if (result != null && result.files.isNotEmpty) {
        final docsDir = await getApplicationDocumentsDirectory();
        final musicDir = Directory('${docsDir.path}/Music');

        if (!await musicDir.exists()) {
          await musicDir.create(recursive: true);
        }

        for (var pickedFile in result.files) {
          if (pickedFile.path != null) {
            try {
              final sourceFile = File(pickedFile.path!);
              final fileName = sourceFile.path.split('/').last;
              final destFile = File('${musicDir.path}/$fileName');

              await sourceFile.copy(destFile.path);

              final extension = fileName.split('.').last.toLowerCase();
              final song = Song(
                id: destFile.path.hashCode.toString(),
                title: fileName.replaceAll('.${extension}', ''),
                artist: pickedFile.artist ?? 'Unknown',
                album: pickedFile.customProperties?['album'] as String? ?? 'Unknown Album',
                filePath: destFile.path,
                duration: Duration(milliseconds: pickedFile.size),
              );

              if (!_allSongs.any((s) => s.filePath == destFile.path)) {
                _allSongs.add(song);
              }
            } catch (e) {
              if (kDebugMode) {
                print('Error copying file: $e');
              }
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error importing songs: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
    final playlistIndex = _playlists.indexWhere((p) => p.id == playlistId);
    if (playlistIndex != -1) {
      final playlist = _playlists[playlistIndex];
      final updatedSongs = [...playlist.songs, ...songs];
      _playlists[playlistIndex] = playlist.copyWith(songs: updatedSongs);
      notifyListeners();
    }
  }

  void removeSongFromPlaylist(String playlistId, String songId) {
    final playlistIndex = _playlists.indexWhere((p) => p.id == playlistId);
    if (playlistIndex != -1) {
      final playlist = _playlists[playlistIndex];
      final updatedSongs = playlist.songs.where((s) => s.id != songId).toList();
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

  List<Song> get allSongs => _allSongs;
  List<Playlist> get playlists => _playlists;
  bool get isLoading => _isLoading;
  int get songCount => _allSongs.length;
  int get playlistCount => _playlists.length;
}
