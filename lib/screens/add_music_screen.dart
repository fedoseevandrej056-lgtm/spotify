import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';
import '../services/music_library_service.dart';
import '../utils/theme.dart';

class AddMusicPage extends ConsumerStatefulWidget {
  const AddMusicPage({Key? key}) : super(key: key);

  @override
  ConsumerState<AddMusicPage> createState() => _AddMusicPageState();
}

class _AddMusicPageState extends ConsumerState<AddMusicPage> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final libraryService = ref.watch(musicLibraryServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Music'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
          )
        ],
      ),
      backgroundColor: SpotifyTheme.darkBg,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: SpotifyTheme.primaryColor,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
              ),
              icon: const Icon(Icons.music_note_rounded),
              label: const Text('Import Songs', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              onPressed: _loading
                  ? null
                  : () async {
                      setState(() => _loading = true);
                      await libraryService.importSongsFromFiles();
                      if (mounted) setState(() => _loading = false);
                      HapticFeedback.mediumImpact();
                    },
            ),
          ),
          if (_loading)
            const LinearProgressIndicator(color: SpotifyTheme.primaryColor),
          Expanded(
            child: ListView.builder(
              itemCount: libraryService.allSongs.length,
              itemBuilder: (context, index) {
                final song = libraryService.allSongs[index];
                return ListTile(
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.deepPurple.shade600,
                          Colors.amber.shade500,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.music_note_rounded, color: Colors.white),
                  ),
                  title: Text(song.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  subtitle: Text('${song.artist} • ${song.album}', style: const TextStyle(color: Colors.white70)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.white54),
                    onPressed: () {
                      libraryService.deleteSong(song.id);
                      HapticFeedback.mediumImpact();
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
