import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers.dart';
import 'services/audio_player_service.dart';
import 'services/music_library_service.dart';
import 'screens/add_music_screen.dart';
import 'screens/home_screen.dart';
import 'screens/now_playing_screen.dart';
import 'utils/theme.dart';

void main() {
  runApp(const ProviderScope(child: SpotifyMusicApp()));
}

class SpotifyMusicApp extends StatelessWidget {
  const SpotifyMusicApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spotify Music Player',
      theme: SpotifyTheme.theme,
      debugShowCheckedModeBanner: false,
      home: const MainApp(),
    );
  }
}

class MainApp extends ConsumerStatefulWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  ConsumerState<MainApp> createState() => _MainAppState();
}

class _MainAppState extends ConsumerState<MainApp> {
  int _selectedIndex = 1;

  void _openNowPlaying() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const NowPlayingScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final scaleAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );
          return ScaleTransition(
            scale: Tween<double>(begin: 0.94, end: 1.0).animate(scaleAnimation),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final playerService = ref.watch(audioPlayerServiceProvider);

    return Scaffold(
      body: _buildPage(_selectedIndex),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (playerService.currentSong != null)
            GestureDetector(
              onTap: _openNowPlaying,
              child: Container(
                height: 72,
                color: SpotifyTheme.playlistBg,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Row(
                    children: [
                      Hero(
                        tag: 'album-art-${playerService.currentSong!.id}',
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  SpotifyTheme.primaryColor,
                                  Colors.amber.shade600,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.album_rounded,
                              color: Colors.black,
                              size: 32,
                            ),
                          ),
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
                                fontWeight: FontWeight.w700,
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
                      IconButton(
                        icon: Icon(
                          playerService.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                          color: SpotifyTheme.primaryColor,
                          size: 34,
                        ),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          if (playerService.isPlaying) {
                            playerService.pause();
                          } else {
                            playerService.play();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
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
                label: 'Now',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.library_music),
                label: 'Library',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.add_circle),
                label: 'Add',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return const NowPlayingScreen();
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
class NowPlayingPage extends ConsumerWidget {
  const NowPlayingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerService = ref.watch(audioPlayerServiceProvider);
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
      }
}

// Player Controls Widget
class PlayerControlsWidget extends ConsumerWidget {
  const PlayerControlsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerService = ref.watch(audioPlayerServiceProvider);
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Progress Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  SliderTheme(
                    data: const SliderThemeData(
                      trackHeight: 4,
                      thumbShape: RoundSliderThumbShape(
                        enabledThumbRadius: 8,
                      ),
                      overlayShape: RoundSliderOverlayShape(
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
                    decoration: const BoxDecoration(
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
      }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}

