import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/music_library_service.dart';
import '../utils/theme.dart';

class AddMusicPage extends StatefulWidget {
  const AddMusicPage({Key? key}) : super(key: key);

  @override
  State<AddMusicPage> createState() => _AddMusicPageState();
}

class _AddMusicPageState extends State<AddMusicPage> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final libraryService = Provider.of<MusicLibraryService>(context);

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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: SpotifyTheme.primaryColor,
                foregroundColor: Colors.black,
              ),
              icon: const Icon(Icons.file_upload),
              label: const Text('Import Songs from Files'),
              onPressed: _loading
                  ? null
                  : () async {
                      setState(() => _loading = true);
                      await libraryService.importSongsFromFiles();
                      if (mounted) setState(() => _loading = false);
                    },
            ),
          ),
          if (_loading)
            const LinearProgressIndicator(
              color: SpotifyTheme.primaryColor,
            ),
          Expanded(
            child: ListView.builder(
              itemCount: libraryService.allSongs.length,
              itemBuilder: (context, index) {
                final song = libraryService.allSongs[index];
                return ListTile(
                  leading: const Icon(Icons.music_note, color: Colors.white),
                  title: Text(song.title, style: const TextStyle(color: Colors.white)),
                  subtitle: Text('${song.artist} • ${song.album}', style: const TextStyle(color: Colors.white70)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.white),
                    onPressed: () => libraryService.deleteSong(song.id),
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
