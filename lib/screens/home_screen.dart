import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/audio_player_service.dart';
import '../services/music_library_service.dart';
import '../utils/theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadSongs();
  }

  Future<void> _loadSongs() async {
    final libraryService =
        Provider.of<MusicLibraryService>(context, listen: false);
    final playerService =
        Provider.of<AudioPlayerService>(context, listen: false);

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
            icon: const Icon(Icons.playlist_play),
            onPressed: () {
              final libraryService =
                  Provider.of<MusicLibraryService>(context, listen: false);
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
      body: Consumer2<MusicLibraryService, AudioPlayerService>(
        builder: (context, libraryService, playerService, _) {
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
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    final name = controller.text.trim();
                                    if (name.isNotEmpty) {
                                      libraryService.createPlaylist(name);
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
                    final originalIndex = libraryService.allSongs.indexOf(song);
                    final isPlaying =
                        playerService.currentSongIndex == originalIndex &&
                            playerService.isPlaying;

                    return GestureDetector(
                      onTap: () async {
                        if (originalIndex >= 0) {
                          await playerService.playSong(originalIndex);
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isPlaying
                              ? SpotifyTheme.playlistBg
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              // Album Art / Icon
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: SpotifyTheme.primaryColor,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Icon(
                                  isPlaying ? Icons.pause : Icons.music_note,
                                  color: Colors.black,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Song Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      song.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: SpotifyTheme.textPrimary,
                                        fontWeight: isPlaying
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${song.artist} • ${song.album}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: SpotifyTheme.textSecondary,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // More Options
                              IconButton(
                                icon: const Icon(Icons.more_vert),
                                color: SpotifyTheme.textSecondary,
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    backgroundColor:
                                        SpotifyTheme.secondaryBg,
                                    builder: (context) => Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        mainAxisSize:
                                            MainAxisSize.min,
                                        children: [
                                          ListTile(
                                            leading: const Icon(
                                              Icons.favorite_border,
                                              color:
                                                  SpotifyTheme
                                                      .textSecondary,
                                            ),
                                            title: const Text(
                                              'Add to Favorites',
                                              style: TextStyle(
                                                color: SpotifyTheme
                                                    .textPrimary,
                                              ),
                                            ),
                                            onTap: () {
                                              Navigator.pop(
                                                  context);
                                              ScaffoldMessenger.of(
                                                      context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Added to favorites',
                                                  ),
                                                  duration: Duration(
                                                    seconds: 1,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                          ListTile(
                                            leading: const Icon(
                                              Icons.delete,
                                              color:
                                                  SpotifyTheme
                                                      .textSecondary,
                                            ),
                                            title: const Text(
                                              'Remove from Library',
                                              style: TextStyle(
                                                color: SpotifyTheme
                                                    .textPrimary,
                                              ),
                                            ),
                                            onTap: () {
                                              Navigator.pop(
                                                  context);
                                              libraryService
                                                  .deleteSong(
                                                      song.id);
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
