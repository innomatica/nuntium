import 'dart:async';
import 'dart:convert';

import 'package:feed_parser/feed_parser.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../logic/feed_bloc.dart';
import '../../models/feed_channel.dart';
import '../../shared/settings.dart';

class ChannelBrowserPage extends StatefulWidget {
  final String? url;
  final String? keyword;
  const ChannelBrowserPage({this.url, this.keyword, super.key});

  @override
  State<ChannelBrowserPage> createState() => _ChannelBrowserPageState();
}

class _ChannelBrowserPageState extends State<ChannelBrowserPage> {
  late WebViewController _controller;
  late NavigationDelegate _navDelegate;
  bool _showFab = false;
  FeedData? _feedData;

  @override
  void initState() {
    super.initState();
    // navigation delegate should be created first due to the issue
    // https://github.com/flutter/flutter/issues/108801
    _navDelegate = NavigationDelegate(
      onPageStarted: (url) => _checkFeedData(url),
    );

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(_navDelegate)
      ..loadRequest(Uri.parse(widget.url ?? _getInitialUrl()));
  }

  final feedSignatures = <String>['<rss', '<feed'];

  void _checkFeedData(String url) async {
    // debugPrint('_checkFeedData');
    final res = await http.get(Uri.parse(url));
    // debugPrint('res.body: ${res.body}');
    if (res.statusCode < 400 &&
        feedSignatures.any((element) => res.body.contains(element))) {
      try {
        final utf8String = utf8.decode(res.bodyBytes, allowMalformed: true);
        _feedData = FeedData.parse(utf8String);
      } catch (e) {
        debugPrint(e.toString());
      }
    }

    setState(() {
      _showFab = _feedData == null ? false : true;
    });
  }

  String _getInitialUrl() {
    return widget.keyword == null
        ? searchEngineUrl
        : '$searchEngineUrl/?q='
            '${Uri.encodeComponent('rss ${widget.keyword!}')}';
  }

  Widget? _buildFab() {
    final logic = context.read<FeedBloc>();
    return _showFab
        ? FloatingActionButton.extended(
            label: const Text('Add This Channel'),
            onPressed: () async {
              final url = await _controller.currentUrl();
              if (_feedData != null && url != null) {
                // debugPrint('feedData: $_feedData');

                await logic.addFeedChannel(
                  FeedChannel(
                    url: url,
                    title: _feedData!.title ?? 'Unknown Channel',
                    icon: _feedData!.icon,
                    image: _feedData!.image,
                    labels: initialLabels,
                    labelIds: initialLabelIds,
                    settings: defaultChannelSettings,
                    updated: _feedData!.updated ?? DateTime.now(),
                  ),
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('channel ${_feedData!.title} added')));
                }
              }
            },
          )
        : null;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (await _controller.canGoBack()) {
          _controller.goBack();
          return Future.value(false);
        } else {
          return Future.value(true);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leadingWidth: 96,
          leading: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(Icons.keyboard_double_arrow_left_rounded,
                    size: 32, color: Theme.of(context).colorScheme.primary),
              ),
              IconButton(
                onPressed: () async {
                  if (await _controller.canGoBack()) {
                    _controller.goBack();
                  } else {
                    if (mounted) {
                      Navigator.of(context).pop();
                    }
                  }
                },
                icon: Icon(Icons.keyboard_arrow_left_rounded,
                    size: 32, color: Theme.of(context).colorScheme.tertiary),
              ),
            ],
          ),
          title: const Text('Channel Browser'),
        ),
        body: WebViewWidget(controller: _controller),
        floatingActionButton: _buildFab(),
      ),
    );
  }
}
