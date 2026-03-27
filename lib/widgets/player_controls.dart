import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/audio_player_service.dart';
import '../utils/formatters.dart';
import '../utils/theme.dart';

class PlayerControls extends StatelessWidget {
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  const PlayerControls({
    Key? key,
    this.onPrevious,
    this.onNext,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioPlayerService>(
      builder: (context, playerService, _) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Progress bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 3,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 6,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 8,
                      ),
                    ),
                    child: Slider(
                      value: playerService.progress,
                      onChanged: (value) {
                        final newPosition = Duration(
                          milliseconds: (value *
                                  playerService.totalDuration.inMilliseconds)
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
                          formatDuration(playerService.currentPosition),
                          style: const TextStyle(
                            color: SpotifyTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          formatDuration(playerService.totalDuration),
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
            const SizedBox(height: 24),
            // Control buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shuffle),
                    iconSize: 24,
                    color: SpotifyTheme.textSecondary,
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_previous),
                    iconSize: 32,
                    color: SpotifyTheme.textPrimary,
                    onPressed: onPrevious ?? () => playerService.previous(),
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
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: SpotifyTheme.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        playerService.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                        size: 32,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_next),
                    iconSize: 32,
                    color: SpotifyTheme.textPrimary,
                    onPressed: onNext ?? () => playerService.next(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.repeat),
                    iconSize: 24,
                    color: SpotifyTheme.textSecondary,
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
