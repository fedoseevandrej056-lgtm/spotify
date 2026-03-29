import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'services/audio_player_service.dart';
import 'services/music_library_service.dart';

final audioPlayerServiceProvider = ChangeNotifierProvider<AudioPlayerService>((ref) => AudioPlayerService());
final musicLibraryServiceProvider = ChangeNotifierProvider<MusicLibraryService>((ref) => MusicLibraryService());