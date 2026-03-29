import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../model/songs/song.dart';
import '../../dtos/song_dto.dart';
import 'song_repository.dart';

class SongRepositoryFirebase extends SongRepository {
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
    required int likes,
  }) async {
    final response = await http.patch(
      _songByIdUri(id),
      body: json.encode({SongDto.likesKey: likes}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to update song likes');
    }
  }

  @override
  Future<List<Song>> fetchSongs() async {
    final http.Response response = await http.get(songsUri);

    if (response.statusCode == 200) {
      final dynamic decoded = json.decode(response.body);
      if (decoded == null) {
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


      return songs;
    } else {
      throw Exception('Failed to load posts');
    }
  }

  @override
  Future<Song?> fetchSongById(String id) async {}
}
