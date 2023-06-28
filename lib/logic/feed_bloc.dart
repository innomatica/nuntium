import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:feed_parser/feed_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/feed_channel.dart';
import '../models/feed_element.dart';
import '../models/feed_label.dart';
import '../services/sqlite.dart';
import '../shared/settings.dart';

class FeedBloc extends ChangeNotifier {
  final _db = SqliteService();

  FeedLabel? _currentLabel;
  List<FeedChannel> _channels = <FeedChannel>[];
  List<FeedChannel> _selected = <FeedChannel>[];
  final List<FeedElement> _elements = <FeedElement>[];
  List<FeedLabel> _labels = <FeedLabel>[];

  FeedBloc() {
    _initBloc();
  }

  Future _initBloc() async {
    _labels = await getFeedLabels(query: {'orderBy': 'title'});
    _channels = await _db.getFeedChannels();
    final restoredLabel = await restoreCurrentLabel();
    changeCurrentLabel(restoredLabel);
  }

  List<FeedChannel> get channels => _channels;
  List<FeedElement> get elements => _elements;
  List<FeedLabel> get labels => _labels;
  List<FeedChannel> get selectedChannels => _selected;

  //
  // FeedChannel
  //
  Future refreshFeedChannels() async {
    _channels = await _db.getFeedChannels();
    notifyListeners();
  }

  Future addFeedChannel(FeedChannel channel) async {
    await _db.addFeedChannel(channel);
    await refreshFeedChannels();
  }

  Future updateFeedChannel(FeedChannel channel) async {
    await _db.updateFeedChannel(channel);
    await refreshFeedChannels();
  }

  Future<List<FeedChannel>> getFeedChannels(
      {Map<String, dynamic>? query}) async {
    final result = await _db.getFeedChannels(query: query);
    return result;
  }

  Future deleteFeedChannelByUrl(String url) async {
    await _db.deleteFeedChannelByUrl(url);
    await refreshFeedChannels();
  }

  Future changeFeedChannelUrl(FeedChannel channel, String newUrl) async {
    await _db.deleteFeedChannelByUrl(channel.url);
    channel.url = newUrl;
    await _db.addFeedChannel(channel);
    await refreshFeedChannels();
  }

  //
  // FeedLabel
  //
  Future refreshFeedLabels() async {
    _labels = await getFeedLabels(query: {'orderBy': 'title'});
    notifyListeners();
  }

  Future<List<FeedLabel>> getFeedLabels({Map<String, dynamic>? query}) async {
    return await _db.getFeedLabels(query: query);
  }

  Future addFeedLabel(FeedLabel label) async {
    await _db.addFeedLabel(label);
    await refreshFeedLabels();
  }

  Future updateFeedLabel(FeedLabel label) async {
    await _db.updateFeedLabel(label);
    await refreshFeedLabels();
  }

  Future deleteFeedLabel(FeedLabel label) async {
    bool channelDirty = false;
    // get channels having the label
    final channels = await _db.getFeedChannels(query: {
      'where': 'labels LIKE ?',
      'whereArgs': ['%${label.id.toString()}%'],
    });
    for (final channel in channels) {
      // remove the label
      channel.labelIds.remove(label.id);
      // update the channel info
      await _db.updateFeedChannel(channel);
      channelDirty = true;
    }

    if (channelDirty) {
      refreshFeedChannels();
    }

    // delete the label from the database
    await _db.deleteFeedLabel(label);
    if (label == _currentLabel) {
      // change the current label to default
      await changeCurrentLabel(FeedLabel.getDefault());
    }
    await refreshFeedLabels();
  }

  Future<FeedLabel> restoreCurrentLabel() async {
    final prefs = await SharedPreferences.getInstance();
    final dataStr = prefs.getString('label');
    return dataStr != null
        ? FeedLabel.fromPrefString(dataStr)
        : FeedLabel.getDefault();
  }

  Future backupCurrentLabel() async {
    final prefs = await SharedPreferences.getInstance();
    if (_currentLabel != null) {
      final dataStr = _currentLabel!.toPrefString();
      await prefs.setString('label', dataStr);
    }
  }

  Future changeCurrentLabel(FeedLabel label) async {
    if (_currentLabel != label) {
      _currentLabel = label;
      await backupCurrentLabel();
      await updateSelectedChannels();
    }
  }

  Future updateSelectedChannels() async {
    // update selected channel list
    _selected = _currentLabel?.title == allChannels
        ? _channels
        : _channels
            .where((e) => e.labelIds.contains(_currentLabel?.id))
            .toList();
    notifyListeners();
  }

  FeedLabel getCurrentLabel() {
    return _currentLabel ?? FeedLabel.getDefault();
  }

  //
  // FeedData
  //
  Future<FeedData?> fetch(String url) async {
    try {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        try {
          // for the reason for the conversion
          // https://stackoverflow.com/questions/61312620/flutter-http-response-body-bad-utf8-encoding
          return FeedData.parse(
              utf8.decode(res.bodyBytes, allowMalformed: true));
        } catch (e) {
          (e.toString());
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }

  //
  // FeedElement
  //

  Future<List<FeedElement>> getFeedElements() async {
    final elements = <FeedElement>[];
    final temp = <FeedElement>[];

    for (final channel in _selected) {
      temp.clear();
      final data = await fetch(channel.url);
      // debugPrint('channel.url: ${channel.url}');
      if (data != null && data.items != null) {
        // debugPrint('data: ${data.items![0]}');
        temp.addAll(data.items!
            .map((e) => FeedElement.fromFeedItem(e, settings: {
                  'favicon': channel.icon,
                  'feedTitle': channel.title,
                }))
            .toList());
      }
      // sort by channel
      temp.sort((a, b) =>
          (b.updated?.millisecondsSinceEpoch ?? 0) -
          (a.updated?.millisecondsSinceEpoch ?? 0));

      elements.addAll(temp);
    }

    return elements;
  }
}
