import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/audio_player_service.dart';
import '../widgets/player_controls.dart';
import '../utils/theme.dart';

class NowPlayingScreen extends ConsumerStatefulWidget {
  const NowPlayingScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends ConsumerState<NowPlayingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _breath;
  double _dragOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _breath = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutSine),
    );
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playerService = ref.watch(audioPlayerServiceProvider);
    final song = playerService.currentSong;

    final primaryColors = [
      Colors.indigo.shade700,
      Colors.deepPurple.shade700,
      Colors.green.shade700,
      Colors.teal.shade700,
      Colors.deepOrange.shade700,
    ];

    final colorBegin = primaryColors[(playerService.currentSongIndex + 0) % primaryColors.length];
    final colorEnd = primaryColors[(playerService.currentSongIndex + 1) % primaryColors.length];

    final colorTween = ColorTween(begin: colorBegin, end: colorEnd).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (song == null) {
      return Scaffold(
        backgroundColor: SpotifyTheme.darkBg,
        appBar: AppBar(
          title: const Text('Now Playing'),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: const Center(child: Text('No song selected', style: TextStyle(color: Colors.white70))),
      );
    }

    return GestureDetector(
      onVerticalDragUpdate: (details) {
        setState(() {
          _dragOffset += details.delta.dy;
          _dragOffset = _dragOffset.clamp(0.0, MediaQuery.of(context).size.height * 0.5);
        });
      },
      onVerticalDragEnd: (details) {
        if (_dragOffset > 120 || (details.primaryVelocity ?? 0) > 700) {
          HapticFeedback.mediumImpact();
          Navigator.of(context).pop();
          return;
        }
        setState(() {
          _dragOffset = 0;
        });
      },
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [colorTween.value ?? colorBegin, Colors.black87.withOpacity(0.85)],
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                    child: Container(color: Colors.black.withOpacity(0.2)),
                  ),
                ),
                SafeArea(
                  child: Transform.translate(
                    offset: Offset(0, _dragOffset),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.expand_more, color: Colors.white),
                                onPressed: () {
                                  HapticFeedback.lightImpact();
                                  Navigator.of(context).pop();
                                },
                              ),
                              const Expanded(
                                child: Center(
                                  child: Text('Now Playing', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.share, color: Colors.white70),
                                onPressed: () {
                                  HapticFeedback.mediumImpact();
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Hero(
                          tag: 'album-art-${song.id}',
                          child: ScaleTransition(
                            scale: playerService.isPlaying ? _breath : Tween<double>(begin: 1.0, end: 0.9).animate(_pulseController),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 40),
                              height: 320,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.deepPurple.shade700,
                                    Colors.amber.shade600,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.45),
                                    blurRadius: 28,
                                    offset: const Offset(0, 14),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.album_rounded,
                                size: 140,
                                color: Colors.white24,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(song.title, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(song.artist, style: const TextStyle(color: Colors.white70, fontSize: 16)),
                                  const SizedBox(width: 6),
                                  const Text('•', style: TextStyle(color: Colors.white70, fontSize: 16)),
                                  const SizedBox(width: 6),
                                  Text(song.album, style: const TextStyle(color: Colors.white70, fontSize: 16)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Expanded(child: PlayerControls()),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
