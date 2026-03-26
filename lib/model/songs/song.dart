class Song {
  final String id;
  final String title;
  final String artistId;
  final Duration duration;
  final Uri imageUri;

  Song({
    required this.id,
    required this.title,
    required this.artistId,
    required this.duration,
    required this.imageUri,
  });

  @override
  String toString() {
    return 'Song(id: $id, title: $title, artistId: $artistId, duration: $duration, imageUri: $imageUri)';
  }
}
