    import '../../model/songs/song.dart';

class SongDto {
  static const String idKey = 'id';
  static const String titleKey = 'title';
  static const String artistIdKey = 'artistId';
  static const String durationKey = 'duration';   
  static const String imageUriKey = 'imageUrl';
  static const String likesKey = 'likes';

  static Song fromJson({required String id, required Map<String, dynamic> json}) {
    assert(json[titleKey] is String);
    assert(json[artistIdKey] is String);
    assert(json[durationKey] is int);
    assert(json[imageUriKey] is String);
    assert(json[likesKey] is num?);
    return Song(
      id: id,
      title: json[titleKey],
      artistId: json[artistIdKey],
      duration: Duration(milliseconds: json[durationKey]),
      imageUri: Uri.parse(json[imageUriKey]),
      likes: (json[likesKey] as num?)?.toInt() ?? 0,
    );
  }

  /// Convert Song to JSON
  Map<String, dynamic> toJson(Song song) {
    return {
      idKey: song.id,
      titleKey: song.title,
      artistIdKey: song.artistId,
      durationKey: song.duration.inMilliseconds,
      imageUriKey: song.imageUri.toString(),
      likesKey: song.likes,
    };
  }
}
