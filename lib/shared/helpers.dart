import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/feed_source.dart';
import 'settings.dart';

//
// Source List
//

Future<List<FeedSource>?> getFeedSource() async {
  String feedSourceUrl = urlFeedSourceDefault;
  final locale = Platform.localeName;
  if (supportedLocales.contains(locale)) {
    feedSourceUrl = '${urlFeedSource}feeds_$locale.json';
  }
  // debugPrint('feedSourceUrl:$feedSourceUrl');

  http.Response res = await http.get(Uri.parse(feedSourceUrl));
  if (res.statusCode != 200) {
    // probably 404 not found... try default
    res = await http.get(Uri.parse(urlFeedSourceDefault));
  }

  if (res.statusCode == 200) {
    try {
      final document = jsonDecode(res.body);
      if (document != null && document['data'] != null) {
        final sources = (document['data'] as List)
            .map((e) => FeedSource.fromJsonData(e))
            .toList();
        // sort by title
        sources.sort(
            (a, b) => (a.title.toLowerCase()).compareTo(b.title.toLowerCase()));
        return sources;
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }
  // debugPrint('res.statusCode: ${res.statusCode}');
  return null;
}
