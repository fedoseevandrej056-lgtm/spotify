import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/audio_player_service.dart';
import '../utils/formatters.dart';
import '../utils/theme.dart';

class PlayerControls extends ConsumerWidget {
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  const PlayerControls({
    Key? key,
    this.onPrevious,
    this.onNext,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerService = ref.watch(audioPlayerServiceProvider);
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
                    icon: const Icon(Icons.shuffle_rounded),
                    iconSize: 24,
                    color: SpotifyTheme.textSecondary,
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_previous_rounded),
                    iconSize: 32,
                    color: SpotifyTheme.textPrimary,
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      (onPrevious ?? () => playerService.previous())();
                    },
                  ),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
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
                        boxShadow: [
                          BoxShadow(
                            color: SpotifyTheme.primaryColor.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        playerService.isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        size: 32,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_next_rounded),
                    iconSize: 32,
                    color: SpotifyTheme.textPrimary,
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      (onNext ?? () => playerService.next())();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.repeat_rounded),
                    iconSize: 24,
                    color: SpotifyTheme.textSecondary,
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ],
        );
  }
}
