import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../model/songs/song.dart';
import '../../dtos/song_dto.dart';
import 'song_repository.dart';

class SongRepositoryFirebase extends SongRepository {
  List<Song>? _songsCache;

  final Uri songsUri = Uri.https(
    'week-8-practice-97b3a-default-rtdb.asia-southeast1.firebasedatabase.app',
    '/songs.json',
  );

  Uri _songByIdUri(String id) => Uri.https(
    'week-8-practice-97b3a-default-rtdb.asia-southeast1.firebasedatabase.app',
    '/songs/$id.json',
  );

  @override
  Future<void> updateSongLikes({
    required String id, 
    required int likes
    }) async {
      final response = await http.patch(
        _songByIdUri(id),
        body: json.encode({
          SongDto.likesKey: likes,
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Failed to update song likes');
      }

      if (_songsCache != null) {
        for (int i = 0; i < _songsCache!.length; i++) {
          if (_songsCache![i].id == id) {
            _songsCache![i] = _songsCache![i].copyWith(likes: likes);
            break;
          }
        }
      }
  }

  @override
  Future<List<Song>> fetchSongs() async {
    if (_songsCache != null) {
      return List<Song>.from(_songsCache!);
    }

    final http.Response response = await http.get(songsUri);

    if (response.statusCode == 200) {
      final dynamic decoded = json.decode(response.body);
      if (decoded == null) {
        _songsCache = [];
        return [];
      }

      final Map<String, dynamic> songJson = Map<String, dynamic>.from(decoded);

      List<Song> songs = [];
      for (var song in songJson.entries) {
        songs.add(
          SongDto.fromJson(
            id: song.key,
            json: Map<String, dynamic>.from(song.value),
          )
        );
      }

      _songsCache = songs;

      return songs;
    } else {
      throw Exception('Failed to load posts');
    }
  }

  @override
  Future<Song?> fetchSongById(String id) async {
    if (_songsCache != null) {
      for (final song in _songsCache!) {
        if (song.id == id) {
          return song;
        }
      }
    }

    final http.Response response = await http.get(_songByIdUri(id));

    if (response.statusCode == 200) {
      final dynamic decoded = json.decode(response.body);
      if (decoded == null) {
        return null;
      }

      final Song song = SongDto.fromJson(
        id: id,
        json: Map<String, dynamic>.from(decoded),
      );

      _songsCache ??= [];
      bool replaced = false;
      for (int i = 0; i < _songsCache!.length; i++) {
        if (_songsCache![i].id == id) {
          _songsCache![i] = song;
          replaced = true;
          break;
        }
      }
      if (!replaced) {
        _songsCache!.add(song);
      }

      return song;
    }

    throw Exception('Failed to load song with id $id');
  }
}
