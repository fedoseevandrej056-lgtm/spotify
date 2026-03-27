class Song {
  final String id;
  final String title;
  final String artist;
  final String album;
  final String filePath;
  final Duration duration;
  final String? albumArt;
  final DateTime dateAdded;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.filePath,
    required this.duration,
    this.albumArt,
    DateTime? dateAdded,
  }) : dateAdded = dateAdded ?? DateTime.now();

  factory Song.fromMap(Map<String, dynamic> map) {
    return Song(
      id: map['id'] ?? '',
      title: map['title'] ?? 'Unknown Title',
      artist: map['artist'] ?? 'Unknown Artist',
      album: map['album'] ?? 'Unknown Album',
      filePath: map['filePath'] ?? '',
      duration: Duration(milliseconds: map['duration'] ?? 0),
      albumArt: map['albumArt'],
      dateAdded: map['dateAdded'] != null
          ? DateTime.parse(map['dateAdded'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'filePath': filePath,
      'duration': duration.inMilliseconds,
      'albumArt': albumArt,
      'dateAdded': dateAdded.toIso8601String(),
    };
  }

  Song copyWith({
    String? id,
    String? title,
    String? artist,
    String? album,
    String? filePath,
    Duration? duration,
    String? albumArt,
    DateTime? dateAdded,
  }) {
    return Song(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      filePath: filePath ?? this.filePath,
      duration: duration ?? this.duration,
      albumArt: albumArt ?? this.albumArt,
      dateAdded: dateAdded ?? this.dateAdded,
    );
  }

  @override
  String toString() => 'Song(title: $title, artist: $artist, album: $album)';
}
