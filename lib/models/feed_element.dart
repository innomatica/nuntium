import 'package:feed_parser/feed_parser.dart';

class FeedElement extends FeedItem {
  Map<String, dynamic>? settings;
  FeedElement({
    required super.id,
    super.title,
    super.link,
    super.updated,
    super.categories,
    super.media,
    super.description,
    super.authors,
    this.settings,
  });

  factory FeedElement.fromFeedItem(FeedItem item,
      {Map<String, dynamic>? settings}) {
    return FeedElement(
      id: item.id,
      title: item.title,
      link: item.link,
      updated: item.updated,
      categories: item.categories,
      media: item.media,
      description: item.description,
      authors: item.authors,
      settings: settings,
    );
  }

  @override
  String toString() {
    return {
      "id": id,
      "title": title,
      "link": link,
      "updated": updated,
      "categories": categories,
      "media": media,
      "description": description,
      "authors": authors,
      "settings": settings,
    }.toString();
  }
}
