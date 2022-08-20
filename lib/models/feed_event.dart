import 'package:test/models/artist.dart';
import 'package:test/models/track.dart';

class FeedEvent {
  String id;
  String type;
  List<dynamic> titleParts;
  List<Track> tracks;
  List<Artist> artists;

  FeedEvent({
    this.id = "",
    this.type = "",
    this.titleParts = const [],
    this.tracks = const [],
    this.artists = const [],
  });
}
