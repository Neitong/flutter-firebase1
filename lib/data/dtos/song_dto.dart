    import '../../model/songs/song.dart';

class SongDto {
  static const String idKey = 'id';
  static const String titleKey = 'name';
  static const String artistIdKey = 'artistId';
  static const String durationKey = 'duration'; 
  static const String imageUriKey = 'imageUri';  

  static Song fromJson(Map<String, dynamic> json) {
    assert(json[idKey] is String);
    assert(json[titleKey] is String);
    assert(json[artistIdKey] is String);
    assert(json[durationKey] is int);
    assert(json[imageUriKey] is String);

    return Song(
      id: json[idKey],
      title: json[titleKey],
      artistId: json[artistIdKey],
      duration: Duration(milliseconds: json[durationKey]),
      imageUri: Uri.parse(json[imageUriKey]),
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
    };
  }
}


