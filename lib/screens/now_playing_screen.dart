import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/audio_player_service.dart';
import '../widgets/player_controls.dart';
import '../utils/theme.dart';

class NowPlayingScreen extends StatelessWidget {
  const NowPlayingScreen({Key? key}) : super(key: key);

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
              child: Text('No song playing'),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Now Playing'),
            leading: IconButton(
              icon: const Icon(Icons.expand_more),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {},
              ),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Album art
                  Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      color: SpotifyTheme.primaryColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: SpotifyTheme.primaryColor.withOpacity(0.5),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.album,
                      size: 150,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Song info
                  Column(
                    children: [
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
                      const SizedBox(height: 4),
                      Text(
                        song.album,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: SpotifyTheme.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  // Favorite button
                  IconButton(
                    icon: const Icon(Icons.favorite_border),
                    iconSize: 28,
                    color: SpotifyTheme.textSecondary,
                    onPressed: () {},
                  ),
                  const SizedBox(height: 20),
                  // Player controls
                  const Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: PlayerControls(),
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
