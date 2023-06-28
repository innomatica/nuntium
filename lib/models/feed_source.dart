class FeedSource {
  String title;
  String? nickname;
  String? website;
  String? description;
  String? language;
  List<String>? keywords;
  String? feedlist;
  String? favicon;
  Map<String, String>? channels;

  FeedSource({
    required this.title,
    this.nickname,
    this.website,
    this.description,
    this.language,
    this.keywords,
    this.feedlist,
    this.favicon,
    this.channels,
  });

  factory FeedSource.fromJsonData(Map<String, dynamic> data) {
    return FeedSource(
      title: data['title'] ?? 'Unknown Source',
      nickname: data['nickname'],
      website: data['website'],
      description: data['description'],
      language: data['language'],
      keywords: List<String>.from(data['keywords']),
      feedlist: data['feedlist'],
      favicon: data['favicon'],
      channels: Map<String, String>.from(data['channels']),
    );
  }

  @override
  String toString() {
    return {
      'title': title,
      'nickname': nickname,
      'website': website,
      'description': description,
      'language': language,
      'keywords': keywords,
      'feedlist': feedlist,
      'channels': channels,
    }.toString();
  }
}
