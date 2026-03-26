import 'dart:convert';

import 'package:firebase2/data/repositories/artist/artist_repository.dart';
import 'package:firebase2/model/artists/artist.dart';
import 'package:http/http.dart' as http;


import '../../dtos/artist_dto.dart';

class ArtistRepositoryFirebase extends ArtistRepository {
  final Uri artistsUri = Uri.https(
    'week-8-practice-97b3a-default-rtdb.asia-southeast1.firebasedatabase.app',
    '/artists.json',
  );

  @override
  Future<List<Artist>> fetchArtists() async {
    final http.Response response = await http.get(artistsUri);

    if (response.statusCode == 200) {
      // 1 - Send the retrieved list of artists
      final Map<String, dynamic> artistsJson = json.decode(response.body);

      List<Artist> artists = [];
      for (var entry in artistsJson.entries) {
        artists.add(
          ArtistDto.fromJson(
            id: entry.key,
            json: Map<String, dynamic>.from(entry.value),
          ),
        );
      }

      return artists;
    } else {
      throw Exception('Failed to load artists');
    }
  }

  @override
  Future<Artist?> fetchArtistById(String id) async {}
}
