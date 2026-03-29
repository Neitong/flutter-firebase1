class Song {
  final String id;
  final String title;
  final String artistId;
  final Duration duration;
  final Uri imageUri;
  final int likes;

  Song({
    required this.id,
    required this.title,
    required this.artistId,
    required this.duration,
    required this.imageUri,
    this.likes = 0,
  });

  Song copyWith({
    String? id,
    String? title,
    String? artistId,
    Duration? duration,
    Uri? imageUri,
    int? likes,
  }) {
    return Song(
      id: id ?? this.id,
      title: title ?? this.title,
      artistId: artistId ?? this.artistId,
      duration: duration ?? this.duration,
      imageUri: imageUri ?? this.imageUri,
      likes: likes ?? this.likes,
    );
  }

  @override
  String toString() {
    return 'Song(id: $id, title: $title, artistId: $artistId, duration: $duration, imageUri: $imageUri)';
  }
}
