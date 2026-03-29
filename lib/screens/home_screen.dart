import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';
import '../utils/theme.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadSongs();
  }

  Future<void> _loadSongs() async {
    final libraryService = ref.read(musicLibraryServiceProvider);
    final playerService = ref.read(audioPlayerServiceProvider);

    if (libraryService.allSongs.isNotEmpty) {
      await playerService.loadPlaylist(libraryService.allSongs);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Your Library',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 26,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.playlist_play_rounded),
            onPressed: () {
              final libraryService = ref.read(musicLibraryServiceProvider);
              showModalBottomSheet(
                context: context,
                backgroundColor: SpotifyTheme.secondaryBg,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (context) {
                  final playlists = libraryService.playlists;
                  return SizedBox(
                    height: 320,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Playlists', style: TextStyle(fontSize: 18, color: Colors.white)),
                              IconButton(
                                icon: const Icon(Icons.add, color: Colors.white),
                                onPressed: () {
                                  Navigator.pop(context);
                                  showDialog(
                                    context: context,
                                    builder: (_) {
                                      final nameCtrl = TextEditingController();
                                      return AlertDialog(
                                        backgroundColor: SpotifyTheme.secondaryBg,
                                        title: const Text('Create playlist'),
                                        content: TextField(
                                          controller: nameCtrl,
                                          style: const TextStyle(color: Colors.white),
                                          decoration: const InputDecoration(hintText: 'Playlist name'),
                                        ),
                                        actions: [
                                          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                                          TextButton(
                                            onPressed: () {
                                              if (nameCtrl.text.trim().isNotEmpty) {
                                                libraryService.createPlaylist(nameCtrl.text.trim());
                                                Navigator.pop(context);
                                              }
                                            },
                                            child: const Text('Create'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: playlists.length,
                            itemBuilder: (context, idx) {
                              final pl = playlists[idx];
                              return ListTile(
                                leading: const Icon(Icons.folder, color: Colors.white),
                                title: Text(pl.name, style: const TextStyle(color: Colors.white)),
                                subtitle: Text('${pl.songCount} songs', style: const TextStyle(color: Colors.white70)),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.white),
                                  onPressed: () {
                                    libraryService.deletePlaylist(pl.id);
                                    Navigator.pop(context);
                                  },
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Playlist "${pl.name}" with ${pl.songCount} songs')),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final libraryService = ref.watch(musicLibraryServiceProvider);
    final playerService = ref.watch(audioPlayerServiceProvider);

    if (libraryService.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            SpotifyTheme.primaryColor,
          ),
        ),
      );
    }

    if (libraryService.allSongs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.library_music,
              size: 80,
              color: SpotifyTheme.primaryColor,
            ),
            const SizedBox(height: 24),
            const Text(
              'Your library is empty',
              style: TextStyle(
                color: SpotifyTheme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Add songs to get started',
              style: TextStyle(
                color: SpotifyTheme.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => libraryService.importSongsFromFiles(),
              icon: const Icon(Icons.add),
              label: const Text('Import Songs'),
              style: ElevatedButton.styleFrom(
                backgroundColor: SpotifyTheme.primaryColor,
                foregroundColor: Colors.black,
              ),
            ),
          ],
        ),
      );
    }

    final filteredSongs = libraryService.allSongs.where((song) {
      if (_searchQuery.isEmpty) return true;
      return song.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          song.artist.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          song.album.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search, color: Colors.white70),
              hintText: 'Search songs, artists, albums',
              hintStyle: const TextStyle(color: Colors.white54),
              filled: true,
              fillColor: SpotifyTheme.secondaryBg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${filteredSongs.length} songs',
                  style: const TextStyle(
                    color: SpotifyTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.playlist_add, color: Colors.white),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      final controller = TextEditingController();
                      return AlertDialog(
                        backgroundColor: SpotifyTheme.secondaryBg,
                        title: const Text('Create playlist'),
                        content: TextField(
                          controller: controller,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(hintText: 'Playlist name'),
                        ),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                          TextButton(
                            onPressed: () {
                              if (controller.text.trim().isNotEmpty) {
                                libraryService.createPlaylist(controller.text.trim());
                                Navigator.pop(context);
                              }
                            },
                            child: const Text('Create'),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filteredSongs.length,
            itemBuilder: (context, index) {
              final song = filteredSongs[index];
              return ListTile(
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: SpotifyTheme.primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.music_note,
                    color: Colors.black,
                  ),
                ),
                title: Text(
                  song.title,
                  style: const TextStyle(
                    color: SpotifyTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  '${song.artist} • ${song.album}',
                  style: const TextStyle(
                    color: SpotifyTheme.textSecondary,
                  ),
                ),
                trailing: IconButton(
                  icon: Icon(
                    playerService.currentSong?.id == song.id && playerService.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow,
                    color: SpotifyTheme.primaryColor,
                  ),
                  onPressed: () {
                    if (playerService.currentSong?.id == song.id) {
                      if (playerService.isPlaying) {
                        playerService.pause();
                      } else {
                        playerService.play();
                      }
                    } else {
                      playerService.playSong(libraryService.allSongs.indexOf(song));
                    }
                  },
                ),
                onTap: () {
                  playerService.playSong(libraryService.allSongs.indexOf(song));
                },
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
