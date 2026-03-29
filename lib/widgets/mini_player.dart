import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/audio_player_service.dart';
import '../utils/theme.dart';

class MiniPlayer extends ConsumerWidget {
  final VoidCallback onTap;

  const MiniPlayer({
    Key? key,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerService = ref.watch(audioPlayerServiceProvider);
        if (playerService.currentSong == null) {
          return const SizedBox.shrink();
        }

        final song = playerService.currentSong!;

        return GestureDetector(
          onTap: onTap,
          child: Container(
            height: 60,
            color: SpotifyTheme.playlistBg,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: SpotifyTheme.primaryColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(Icons.music_note_rounded),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        song.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: SpotifyTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        song.artist,
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
                const SizedBox(width: 12),
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
                        ? Icons.pause_circle_filled_rounded
                        : Icons.play_circle_filled_rounded,
                    size: 40,
                    color: SpotifyTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        );
  }
}
