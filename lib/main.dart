import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/audio_player_service.dart';
import 'services/music_library_service.dart';
import 'screens/home_screen.dart';
import 'utils/theme.dart';

void main() {
  runApp(const SpotifyMusicApp());
}

class SpotifyMusicApp extends StatelessWidget {
  const SpotifyMusicApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AudioPlayerService(),
        ),
        ChangeNotifierProvider(
          create: (_) => MusicLibraryService(),
        ),
      ],
      child: MaterialApp(
        title: 'Spotify Music Player',
        theme: SpotifyTheme.theme,
        debugShowCheckedModeBanner: false,
        home: const MainApp(),
      ),
    );
  }
}

class MainApp extends StatefulWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildPage(_selectedIndex),
      bottomNavigationBar: Consumer<AudioPlayerService>(
        builder: (context, playerService, _) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Mini player
              if (playerService.currentSong != null)
                Container(
                  height: 70,
                  color: SpotifyTheme.playlistBg,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIndex = 0;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              color: SpotifyTheme.primaryColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(
                              Icons.music_note,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  playerService.currentSong!.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: SpotifyTheme.textPrimary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  playerService.currentSong!.artist,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: SpotifyTheme.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              if (playerService.isPlaying) {
                                playerService.pause();
                              } else {
                                playerService.play();
                              }
                            },
                            child: Icon(
                              playerService.isPlaying
                                  ? Icons.pause_circle_filled
                                  : Icons.play_circle_filled,
                              size: 44,
                              color: SpotifyTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              // Bottom Navigation
              BottomNavigationBar(
                currentIndex: _selectedIndex,
                backgroundColor: SpotifyTheme.darkBg,
                selectedItemColor: SpotifyTheme.primaryColor,
                unselectedItemColor: SpotifyTheme.textSecondary,
                type: BottomNavigationBarType.fixed,
                onTap: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.music_note),
                    label: 'Now Playing',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.library_music),
                    label: 'Library',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.add_circle),
                    label: 'Add Music',
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return const NowPlayingPage();
      case 1:
        return const HomeScreen();
      case 2:
        return const AddMusicPage();
      default:
        return const HomeScreen();
    }
  }
}

// Now Playing Page
class NowPlayingPage extends StatelessWidget {
  const NowPlayingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioPlayerService>(
      builder: (context, playerService, _) {
        final song = playerService.currentSong;

        if (song == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Now Playing'),
            ),
            body: const Center(
              child: Text('Select a song to start playing'),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Now Playing'),
            centerTitle: true,
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  // Album Art
                  Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      color: SpotifyTheme.primaryColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: SpotifyTheme.primaryColor.withOpacity(0.3),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.album,
                      size: 140,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Song Info
                  Text(
                    song.title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: SpotifyTheme.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    song.artist,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: SpotifyTheme.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Favorites
                  IconButton(
                    icon: const Icon(Icons.favorite_border),
                    iconSize: 32,
                    color: SpotifyTheme.textSecondary,
                    onPressed: () {},
                  ),
                  const SizedBox(height: 30),
                  // Player Controls
                  const Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: PlayerControlsWidget(),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// Player Controls Widget
class PlayerControlsWidget extends StatelessWidget {
  const PlayerControlsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioPlayerService>(
      builder: (context, playerService, _) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Progress Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 4,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 8,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 10,
                      ),
                    ),
                    child: Slider(
                      value: playerService.progress.clamp(0.0, 1.0),
                      onChanged: (value) {
                        final newPosition = Duration(
                          milliseconds:
                              (value * playerService.totalDuration.inMilliseconds)
                                  .toInt(),
                        );
                        playerService.seek(newPosition);
                      },
                      activeColor: SpotifyTheme.primaryColor,
                      inactiveColor: SpotifyTheme.dividerColor,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(playerService.currentPosition),
                          style: const TextStyle(
                            color: SpotifyTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          _formatDuration(playerService.totalDuration),
                          style: const TextStyle(
                            color: SpotifyTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            // Control Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.shuffle),
                  iconSize: 28,
                  color: SpotifyTheme.textSecondary,
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.skip_previous),
                  iconSize: 40,
                  color: SpotifyTheme.textPrimary,
                  onPressed: () => playerService.previous(),
                ),
                GestureDetector(
                  onTap: () {
                    if (playerService.isPlaying) {
                      playerService.pause();
                    } else {
                      playerService.play();
                    }
                  },
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: SpotifyTheme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      playerService.isPlaying ? Icons.pause : Icons.play_arrow,
                      size: 36,
                      color: Colors.black,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next),
                  iconSize: 40,
                  color: SpotifyTheme.textPrimary,
                  onPressed: () => playerService.next(),
                ),
                IconButton(
                  icon: const Icon(Icons.repeat),
                  iconSize: 28,
                  color: SpotifyTheme.textSecondary,
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}

// Add Music Page
class AddMusicPage extends StatelessWidget {
  const AddMusicPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Music'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_circle,
                size: 80,
                color: SpotifyTheme.primaryColor,
              ),
              const SizedBox(height: 24),
              const Text(
                'Add Music to Your Library',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: SpotifyTheme.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Import your favorite songs and build your collection',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: SpotifyTheme.textSecondary,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () {
                  Provider.of<MusicLibraryService>(context, listen: false)
                      .importSongsFromFiles();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Demo songs added to library'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                icon: const Icon(Icons.music_note),
                label: const Text('Import Songs'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: SpotifyTheme.primaryColor,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}
