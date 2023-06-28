import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';

class FeedWebView extends StatefulWidget {
  final String pageTitle;
  final String pageUrl;

  const FeedWebView({
    required this.pageTitle,
    required this.pageUrl,
    Key? key,
  }) : super(key: key);

  @override
  State<FeedWebView> createState() => _FeedWebViewState();
}

class _FeedWebViewState extends State<FeedWebView> {
  late WebViewController _controller;
  late NavigationDelegate _navDelegate;

  @override
  void initState() {
    super.initState();
    // DO NOT OMIT THIS even if not needed: otherwise exception will occur
    _navDelegate = NavigationDelegate();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(_navDelegate)
      ..loadRequest(Uri.parse(widget.pageUrl));
  }

  @override
  Widget build(BuildContext context) {
    // debugPrint('url:${widget.pageUrl}');
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pageTitle),
        actions: [
          IconButton(
            icon: Icon(
              Icons.share_rounded,
              color: Theme.of(context).colorScheme.tertiary,
            ),
            onPressed: () {
              Share.share('check this article\n\n ${widget.pageUrl}',
                  subject: 'Look what I found');
            },
          )
        ],
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
