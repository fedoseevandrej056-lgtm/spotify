import 'song_model.dart';

class Playlist {
  final String id;
  final String name;
  final String? description;
  final List<Song> songs;
  final DateTime createdDate;
  final String? coverImage;

  Playlist({
    required this.id,
    required this.name,
    this.description,
    List<Song>? songs,
    DateTime? createdDate,
    this.coverImage,
  })  : songs = songs ?? [],
        createdDate = createdDate ?? DateTime.now();

  int get songCount => songs.length;

  Duration get totalDuration {
    return songs.fold(
      Duration.zero,
      (total, song) => total + song.duration,
    );
  }

  factory Playlist.fromMap(Map<String, dynamic> map) {
    return Playlist(
      id: map['id'] ?? '',
      name: map['name'] ?? 'New Playlist',
      description: map['description'],
      songs: (map['songs'] as List<dynamic>?)
              ?.map((song) => Song.fromMap(song as Map<String, dynamic>))
              .toList() ??
          [],
      createdDate: map['createdDate'] != null
          ? DateTime.parse(map['createdDate'])
          : DateTime.now(),
      coverImage: map['coverImage'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'songs': songs.map((song) => song.toMap()).toList(),
      'createdDate': createdDate.toIso8601String(),
      'coverImage': coverImage,
    };
  }

  Playlist copyWith({
    String? id,
    String? name,
    String? description,
    List<Song>? songs,
    DateTime? createdDate,
    String? coverImage,
  }) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      songs: songs ?? this.songs,
      createdDate: createdDate ?? this.createdDate,
      coverImage: coverImage ?? this.coverImage,
    );
  }
}
