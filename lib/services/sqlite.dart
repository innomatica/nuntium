import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/feed_channel.dart';
import '../models/feed_label.dart';

const databaseVersion = 2;
const databaseName = 'Nuntium.sqlite3';
const tableFeedLabels = 'labels';
const tableFeedChannels = 'channels';
const sqlCreateTables = [
  sqlCreateFeedLabels,
  sqlCreateFeedChannels,
];
const sqlDropTables = [
  sqlDropFeedLabels,
  sqlDropFeedChannels,
];
const sqlCreateFeedLabels = 'CREATE TABLE $tableFeedLabels ('
    'id INTEGER PRIMARY KEY,'
    'title TEXT UNIQUE,'
    'position INTEGER,'
    'settings TEXT);';
const sqlCreateFeedChannels = 'CREATE TABLE $tableFeedChannels ('
    'id INTEGER PRIMARY KEY,'
    'url TEXT UNIQUE,'
    'title TEXT,'
    'icon TEXT,'
    'image TEXT,'
    'labels TEXT,'
    'settings TEXT,'
    'lastUpdate TEXT);';
const sqlDropFeedLabels = 'DROP TABLE IF EXISTS $tableFeedLabels;';
const sqlDropFeedChannels = 'DROP TABLE IF EXISTS $tableFeedChannels;';
final defaultFeedLabels = [
  FeedLabel(title: 'Top Strories', position: 0, settings: {}),
  FeedLabel(title: 'Local News', position: 1, settings: {}),
  FeedLabel(title: 'Business', position: 2, settings: {}),
  FeedLabel(title: 'Tech & Science', position: 3, settings: {}),
  FeedLabel(title: 'Art & Sports', position: 4, settings: {}),
  FeedLabel(title: 'Communities', position: 5, settings: {}),
  // FeedLabel(title: 'Podcasts', position: 6, settings: {}),
];

class SqliteService {
  SqliteService._internal();
  static final SqliteService _instance = SqliteService._internal();
  factory SqliteService() {
    return _instance;
  }

  Database? _db;

  Future<void> close() async {
    if (_db != null) {
      _db!.close();
    }
  }

  Future<void> open() async {
    var dbPath = await getDatabasesPath();
    String path = join(dbPath, databaseName);
    debugPrint('database path: $path');

    _db = await openDatabase(
      path,
      version: databaseVersion,
      onCreate: (Database db, int version) async {
        for (final statement in sqlCreateTables) {
          await db.execute(statement);
        }
        // insert default labels
        for (final label in defaultFeedLabels) {
          await db.insert(tableFeedLabels, label.toDatabaseMap());
        }
      },
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        if (oldVersion == 1) {
          debugPrint('drop version 1 tables');
          // simply drop old tables
          for (final statement in sqlDropTables) {
            await db.execute(statement);
          }
          // and recreate them
          for (final statement in sqlCreateTables) {
            await db.execute(statement);
          }
          // insert default labels
          for (final label in defaultFeedLabels) {
            await db.insert(tableFeedLabels, label.toDatabaseMap());
          }
        }
        // do something
      },
    );
  }

  Future<Database> getDatabase() async {
    if (_db == null) {
      await open();
    }
    return _db!;
  }

  //
  // Feed Channel
  //
  Future<List<FeedChannel>> getFeedChannels(
      {Map<String, dynamic>? query}) async {
    final db = await getDatabase();
    final snapshot = await db.query(
      tableFeedChannels,
      distinct: query?['distinct'],
      columns: query?['columns'],
      where: query?['where'],
      whereArgs: query?['whereArgs'],
      groupBy: query?['groupBy'],
      having: query?['having'],
      orderBy: query?['orderBy'],
      limit: query?['limit'],
      offset: query?['offset'],
    );

    final result = <FeedChannel>[];
    for (final item in snapshot) {
      late final List<String> labels;
      late final List<int> labelIds;

      if (item['labels'] is String && (item['labels'] as String).isNotEmpty) {
        labels = (item['labels'] as String).split(',');
        try {
          labelIds = labels.map((e) => int.parse(e)).toList();
        } catch (e) {
          // probably old format: needs conversion
          final query = await db.query(tableFeedLabels);
          labelIds = labels.map((l) {
            final q = query.firstWhere(
              (q) => q['title'] == l,
              orElse: () => {},
            );
            return q.containsKey('id') ? q['id'] as int : -1;
          }).toList();
        }
      } else {
        labels = <String>[];
        labelIds = <int>[];
      }

      result.add(FeedChannel(
        id: item['id'] as int,
        url: item['url'] as String,
        title: item['title'] != null ? item['title'] as String : null,
        icon: item['icon'] != null ? item['icon'] as String : null,
        image: item['image'] != null ? item['image'] as String : null,
        labels: labels,
        labelIds: labelIds,
        settings: item['settings'] is String
            ? jsonDecode(item['settings'] as String)
            : {},
        updated: item['lastUpdate'] is String
            ? DateTime.tryParse(item['lastUpdate'] as String) ?? DateTime.now()
            : DateTime.now(),
      ));
    }

    return result;
  }

  Future<int> addFeedChannel(FeedChannel channel) async {
    final db = await getDatabase();
    final result = await db.insert(
      tableFeedChannels,
      channel.toDatabaseMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return result;
  }

  Future<int> updateFeedChannel(FeedChannel channel) async {
    final db = await getDatabase();
    final result = await db.update(
      tableFeedChannels,
      channel.toDatabaseMap(),
      where: 'url = ?',
      whereArgs: [channel.url],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return result;
  }

  Future<int> deleteFeedChannelByUrl(String url) async {
    final db = await getDatabase();
    final result =
        await db.delete(tableFeedChannels, where: 'url = ?', whereArgs: [url]);
    return result;
  }

  //
  // Feed Label
  //
  Future<List<FeedLabel>> getFeedLabels({Map<String, dynamic>? query}) async {
    final db = await getDatabase();
    final snapshot = await db.query(
      tableFeedLabels,
      distinct: query?['distinct'],
      columns: query?['columns'],
      where: query?['where'],
      whereArgs: query?['whereArgs'],
      groupBy: query?['groupBy'],
      having: query?['having'],
      orderBy: query?['orderBy'],
      limit: query?['limit'],
      offset: query?['offset'],
    );
    final result = snapshot.map((e) => FeedLabel.fromDatabaseMap(e)).toList();
    return result;
  }

  Future<int> addFeedLabel(FeedLabel label) async {
    final db = await getDatabase();
    // let the db set the id
    final labelJson = label.toDatabaseMap();
    labelJson.remove('id');
    final result = await db.insert(
      tableFeedLabels,
      labelJson,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return result;
  }

  Future<int> updateFeedLabel(FeedLabel label) async {
    final db = await getDatabase();
    final result = await db.update(
      tableFeedLabels,
      label.toDatabaseMap(),
      where: 'id = ?',
      whereArgs: [label.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return result;
  }

  Future<int> deleteFeedLabel(FeedLabel label) async {
    final db = await getDatabase();
    final result = await db.delete(
      tableFeedLabels,
      where: 'id = ?',
      whereArgs: [label.id],
    );
    return result;
  }
}
