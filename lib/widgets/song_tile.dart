import 'package:flutter/material.dart';
import '../utils/theme.dart';

class SongTile extends StatelessWidget {
  final String title;
  final String artist;
  final String album;
  final int index;
  final bool isPlaying;
  final VoidCallback onTap;
  final VoidCallback? onMore;

  const SongTile({
    Key? key,
    required this.title,
    required this.artist,
    required this.album,
    required this.index,
    required this.isPlaying,
    required this.onTap,
    this.onMore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isPlaying ? SpotifyTheme.playlistBg : Colors.transparent,
      child: ListTile(
        leading: SizedBox(
          width: 40,
          child: isPlaying
              ? Center(
                  child: Icon(
                    Icons.pause_circle_filled,
                    color: SpotifyTheme.primaryColor,
                  ),
                )
              : Center(
                  child: Text(
                    (index + 1).toString(),
                    style: const TextStyle(
                      color: SpotifyTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
        ),
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: SpotifyTheme.textPrimary,
            fontWeight: isPlaying ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        subtitle: Text(
          '$artist • $album',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: SpotifyTheme.textSecondary,
            fontSize: 12,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert),
          color: SpotifyTheme.textSecondary,
          onPressed: onMore,
        ),
        onTap: onTap,
      ),
    );
  }
}
