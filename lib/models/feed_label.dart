import 'dart:convert';

import '../shared/settings.dart';

class FeedLabel {
  int? id;
  String title;
  int position;
  Map<String, dynamic>? settings;
  // {
  //    "maxItems": 10
  // }

  FeedLabel({
    this.id,
    required this.title,
    required this.position,
    this.settings,
  });

  factory FeedLabel.fromDatabaseMap(Map<String, Object?> query) {
    return FeedLabel(
      id: query['id'] as int,
      title: query['title'] as String,
      position: query['position'] != null ? query['position'] as int : 0,
      settings: query['settings'] != null
          ? jsonDecode(query['settings'] as String)
          : null,
    );
  }

  factory FeedLabel.fromPrefString(String dataStr) {
    final data = jsonDecode(dataStr);
    return FeedLabel(
      id: data['id'],
      position: data['position'],
      title: data['title'],
      settings: data['settings'],
    );
  }

  factory FeedLabel.getDefault() {
    return FeedLabel(position: -1, title: allChannels, settings: {});
  }

  Map<String, dynamic> toDatabaseMap() {
    return {
      'id': id,
      'title': title,
      'position': position,
      'settings': jsonEncode(settings),
    };
  }

  String toPrefString() {
    return jsonEncode({
      'id': id,
      'position': position,
      'title': title,
      'settings': settings,
    });
  }

  @override
  String toString() {
    return toDatabaseMap().toString();
  }
}
