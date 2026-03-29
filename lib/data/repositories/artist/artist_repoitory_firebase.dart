import 'dart:convert';

import 'package:firebase2/data/repositories/artist/artist_repository.dart';
import 'package:firebase2/model/artists/artist.dart';
import 'package:firebase2/model/artists/comment.dart';
import 'package:firebase2/model/songs/song.dart';
import 'package:http/http.dart' as http;


import '../../dtos/artist_dto.dart';
import '../../dtos/comment_dto.dart';
import '../../dtos/song_dto.dart';

class ArtistRepositoryFirebase extends ArtistRepository {
  List<Artist>? _artistsCache;
  final Map<String, List<Song>> _artistSongsCache = {};
  final Map<String, List<Comment>> _artistCommentsCache = {};

  final Uri artistsUri = Uri.https(
    'week-8-practice-97b3a-default-rtdb.asia-southeast1.firebasedatabase.app',
    '/artists.json',
  );

  Uri _artistByIdUri(String id) => Uri.https(
    'week-8-practice-97b3a-default-rtdb.asia-southeast1.firebasedatabase.app',
    '/artists/$id.json',
  );

  Uri _songsUri() => Uri.https(
    'week-8-practice-97b3a-default-rtdb.asia-southeast1.firebasedatabase.app',
    '/songs.json',
  );

  Uri _artistCommentsUri(String artistId) => Uri.https(
    'week-8-practice-97b3a-default-rtdb.asia-southeast1.firebasedatabase.app',
    '/artist_comments/$artistId.json',
  );

  Uri _artistCommentByIdUri(String artistId, String commentId) => Uri.https(
    'week-8-practice-97b3a-default-rtdb.asia-southeast1.firebasedatabase.app',
    '/artist_comments/$artistId/$commentId.json',
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

  @override
  Future<List<Song>> fetchArtistSongs(String artistId) async {
    if (_artistSongsCache.containsKey(artistId)) {
      return List<Song>.from(_artistSongsCache[artistId]!);
    }

    final response = await http.get(_songsUri());
    if (response.statusCode != 200) {
      throw Exception('Failed to load songs');
    }

    final dynamic decoded = json.decode(response.body);
    if (decoded == null) {
      _artistSongsCache[artistId] = [];
      return [];
    }

    final Map<String, dynamic> songsJson = Map<String, dynamic>.from(decoded);
    final List<Song> artistSongs = [];

    for (final entry in songsJson.entries) {
      final Song song = SongDto.fromJson(
        id: entry.key,
        json: Map<String, dynamic>.from(entry.value),
      );
      if (song.artistId == artistId) {
        artistSongs.add(song);
      }
    }

    _artistSongsCache[artistId] = artistSongs;
    return List<Song>.from(artistSongs);
  }

  @override
  Future<List<Comment>> fetchArtistComments(String artistId) async {
    if (_artistCommentsCache.containsKey(artistId)) {
      return List<Comment>.from(_artistCommentsCache[artistId]!);
    }

    final response = await http.get(_artistCommentsUri(artistId));
    if (response.statusCode != 200) {
      throw Exception('Failed to load comments');
    }

    final dynamic decoded = json.decode(response.body);
    if (decoded == null) {
      _artistCommentsCache[artistId] = [];
      return [];
    }

    final Map<String, dynamic> commentsJson = Map<String, dynamic>.from(decoded);
    final List<Comment> comments = [];

    for (final entry in commentsJson.entries) {
      comments.add(
        CommentDto.fromJson(
          id: entry.key,
          artistId: artistId,
          json: Map<String, dynamic>.from(entry.value),
        ),
      );
    }

    comments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    _artistCommentsCache[artistId] = comments;
    return List<Comment>.from(comments);
  }

  @override
  Future<Comment> postArtistComment({
    required String artistId,
    required String message,
  }) async {
    int nextIndex = 1;
    final response = await http.get(_artistCommentsUri(artistId));
    if (response.statusCode == 200) {
      final dynamic decoded = json.decode(response.body);
      if (decoded is Map<String, dynamic>) {
        final RegExp regex = RegExp(r'^comment_(\d+)$');
        int maxIndex = 0;
        for (final key in decoded.keys) {
          final Match? match = regex.firstMatch(key);
          if (match != null) {
            final int value = int.tryParse(match.group(1) ?? '') ?? 0;
            if (value > maxIndex) {
              maxIndex = value;
            }
          }
        }
        nextIndex = maxIndex + 1;
      }
    }

    final String commentId = 'comment_$nextIndex';
    final Comment createdComment = Comment(
      id: commentId,
      artistId: artistId,
      message: message,
      createdAt: DateTime.now(),
    );

    final createResponse = await http.put(
      _artistCommentByIdUri(artistId, commentId),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(CommentDto.toJson(createdComment)),
    );

    if (createResponse.statusCode < 200 || createResponse.statusCode >= 300) {
      throw Exception('Failed to post comment');
    }

    final List<Comment> cached = _artistCommentsCache[artistId] ?? [];
    _artistCommentsCache[artistId] = [createdComment, ...cached];

    return createdComment;
  }
}
