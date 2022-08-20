import 'package:get/get.dart';
import 'package:test/models/artist.dart';
import 'package:test/models/feed_event.dart';
import 'package:test/models/track.dart';
import 'package:test/repos/tracks.dart';
import 'package:test/services/api.dart';
import 'package:test/services/hive.dart';

class EventsRepo {
  final hive = Get.find<HiveService>();
  final api = Get.find<ApiService>();

  Future<List<FeedEvent>> get({bool online = false}) async {
    if (online) {
      final events = await api.feedEvents();

      for (FeedEvent event in events) {
        for (Track track in event.tracks) {
          await track.persist();
        }
        for (Artist artist in event.artists) {
          await artist.persist();
        }
      }
      return events
          .where((e) => e.tracks.isNotEmpty || e.artists.isNotEmpty)
          .toList();
    }

    return [
      FeedEvent(
        titleParts: [
          {'text': 'Вы оффлайн.'},
          {'text': ' Случайные загруженные треки для Вас.'},
        ],
        tracks:
            ((await TracksRepo().downloaded())..shuffle()).take(30).toList(),
      )
    ];
  }
}
