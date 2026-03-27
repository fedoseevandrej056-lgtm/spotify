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
                ],
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${libraryService.allSongs.length} songs',
                      style: const TextStyle(
                        color: SpotifyTheme.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: libraryService.allSongs.length,
                  itemBuilder: (context, index) {
                    final song = libraryService.allSongs[index];
                    final isPlaying =
                        playerService.currentSongIndex == index &&
                            playerService.isPlaying;

                    return GestureDetector(
                      onTap: () async {
                        await playerService.playSong(index);
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
}
