import 'dart:convert';

class FeedChannel {
  int? id;
  String url;
  String? title;
  String? icon;
  String? image;
  List<String?> labels;
  List<int?> labelIds;
  DateTime updated;
  Map<String, dynamic> settings;
  // {
  //    "maxItems": 10
  // }

  FeedChannel({
    this.id,
    required this.url,
    this.title,
    this.icon,
    this.image,
    // TODO: get rid of this field at some point in the future
    required this.labels,
    required this.labelIds,
    required this.updated,
    required this.settings,
  });

  /*
  factory FeedChannel.fromDatabaseMap(Map<String, Object?> query) {
    return FeedChannel(
      id: query['id'] as int,
      url: query['url'] as String,
      title: query['title'] != null ? query['title'] as String : null,
      icon: query['icon'] != null ? query['icon'] as String : null,
      image: query['image'] != null ? query['image'] as String : null,
      labels: query['labels'] is String
          ? (query['labels'] as String).split(',')
          : [],
      labelIds: query['labels'] is String
          ? (query['labels'] as String)
              .split(',')
              .map((e) => int.tryParse(e))
              .toList()
          : [],
      settings: query['settings'] is String
          ? jsonDecode(query['settings'] as String)
          : {},
      updated: query['lastUpdate'] is String
          ? DateTime.tryParse(query['lastUpdate'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
  */

  Map<String, dynamic> toDatabaseMap() {
    return {
      'id': id,
      'url': url,
      'title': title,
      'icon': icon,
      'image': image,
      'labels': labelIds.map((e) => e.toString()).toList().join(','),
      'lastUpdate': updated.toIso8601String(),
      'settings': jsonEncode(settings),
    };
  }

  @override
  String toString() {
    return toDatabaseMap().toString();
  }
}
