import 'dart:convert';

import 'package:firebase2/data/repositories/artist/artist_repository.dart';
import 'package:firebase2/model/artists/artist.dart';
import 'package:http/http.dart' as http;


import '../../dtos/artist_dto.dart';

class ArtistRepositoryFirebase extends ArtistRepository {
  List<Artist>? _artistsCache;

  final Uri artistsUri = Uri.https(
    'week-8-practice-97b3a-default-rtdb.asia-southeast1.firebasedatabase.app',
    '/artists.json',
  );

  Uri _artistByIdUri(String id) => Uri.https(
    'week-8-practice-97b3a-default-rtdb.asia-southeast1.firebasedatabase.app',
    '/artists/$id.json',
  );

  @override
  Future<List<Artist>> fetchArtists() async {
    if (_artistsCache != null) {
      return List<Artist>.from(_artistsCache!);
    }

    final http.Response response = await http.get(artistsUri);

    if (response.statusCode == 200) {
      final dynamic decoded = json.decode(response.body);
      if (decoded == null) {
        _artistsCache = [];
        return [];
      }

      final Map<String, dynamic> artistsJson = Map<String, dynamic>.from(decoded);

      List<Artist> artists = [];
      for (var entry in artistsJson.entries) {
        artists.add(
          ArtistDto.fromJson(
            id: entry.key,
            json: Map<String, dynamic>.from(entry.value),
          ),
        );
      }

      _artistsCache = artists;
      return artists;
    } else {
      throw Exception('Failed to load artists');
    }
  }

  @override
  Future<Artist?> fetchArtistById(String id) async {
    if (_artistsCache != null) {
      for (final artist in _artistsCache!) {
        if (artist.id == id) {
          return artist;
        }
      }
    }

    final http.Response response = await http.get(_artistByIdUri(id));

    if (response.statusCode == 200) {
      final dynamic decoded = json.decode(response.body);
      if (decoded == null) {
        return null;
      }

      final Artist artist = ArtistDto.fromJson(
        id: id,
        json: Map<String, dynamic>.from(decoded),
      );

      _artistsCache ??= [];
      bool updated = false;
      for (int i = 0; i < _artistsCache!.length; i++) {
        if (_artistsCache![i].id == id) {
          _artistsCache![i] = artist;
          updated = true;
          break;
        }
      }
      if (!updated) {
        _artistsCache!.add(artist);
      }

      return artist;
    }

    throw Exception('Failed to load artist with id $id');
  }
}
