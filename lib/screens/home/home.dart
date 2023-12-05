import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../logic/feed_bloc.dart';
import '../../models/feed_element.dart';
import '../../models/feed_label.dart';
import '../../services/sqlite.dart';
import '../../shared/constants.dart';
import '../../shared/settings.dart';
import '../about/about.dart';
import '../channel/channel_list.dart';
import '../label/label_manager.dart';
// import 'feedhtmlview.dart';
import 'feedwebview.dart';
import 'instrunction.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final SqliteService _db;
  late final ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _db = SqliteService();
    _controller = ScrollController();
  }

  @override
  dispose() {
    _controller.dispose();
    _db.close();
    super.dispose();
  }

  //
  // Channel Label DropDown
  //
  Widget _buildLabelDropDown(BuildContext context) {
    const labelStyle = TextStyle(fontWeight: FontWeight.w600);
    final bloc = context.watch<FeedBloc>();
    final labels = <FeedLabel>[FeedLabel.getDefault(), ...bloc.labels];

    return DropdownButton<String>(
      value: bloc.getCurrentLabel().title,
      underline: const SizedBox(height: 0),
      iconSize: 0,
      onChanged: (String? value) async {
        // set label
        bloc.changeCurrentLabel(labels.firstWhere(
          (e) => value == e.title,
          orElse: () => FeedLabel.getDefault(),
        ));
        // scroll to the top
        if (_controller.hasClients) {
          _controller.jumpTo(0.0);
        }
      },
      items: labels.map<DropdownMenuItem<String>>((label) {
        return DropdownMenuItem<String>(
          value: label.title,
          child: Text(label.title, style: labelStyle),
        );
      }).toList(),
    );
  }

  //
  // Scaffold Menu
  //
  Widget _buildScaffoldMenu() {
    const menuStyle = TextStyle(fontWeight: FontWeight.w500, fontSize: 14);
    return PopupMenuButton(
      onSelected: (result) async {
        if (result == 'labels') {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) {
              return const LabelManager();
            }),
          ).then((value) => setState(() {}));
        } else if (result == 'channels') {
          Navigator.of(context)
              .push(
                MaterialPageRoute(
                  builder: (context) => const ChannelListPage(),
                ),
              )
              .then((value) => setState(() {}));
        } else if (result == 'about') {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const About(),
            ),
          );
        }
      },
      itemBuilder: (context) {
        return <PopupMenuEntry<String>>[
          PopupMenuItem<String>(
              value: 'channels',
              child: Row(
                children: [
                  Icon(
                    Icons.rss_feed_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8, height: 0),
                  const Text("Feed Channels", style: menuStyle),
                ],
              )),
          PopupMenuItem<String>(
            value: 'labels',
            child: Row(
              children: [
                Icon(
                  Icons.label_outline_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8, height: 0),
                const Text("Feed Labels", style: menuStyle),
              ],
            ),
          ),
          // const PopupMenuDivider(),
          PopupMenuItem<String>(
            value: 'about',
            child: Row(
              children: [
                Icon(
                  Icons.info_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8, height: 0),
                const Text("About This App", style: menuStyle),
              ],
            ),
          ),
        ];
      },
    );
  }

  //
  // Get Image Url from FeedElement
  //
  String? _getImageUrl(FeedElement element) {
    if (element.media != null || element.media!.isNotEmpty) {
      for (final media in element.media!) {
        if ((media.type != null && media.type!.contains('image')) ||
            (media.url != null && media.url!.contains('.jpg'))) {
          return media.url;
        }
      }
    }
    return null;
  }

  //
  // SubTitle
  //
  Widget _buildSubTitle(FeedElement element) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2.0, bottom: 2.0, right: 6.0),
            child: element.settings?['favicon'] != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: SizedBox(
                        width: 12,
                        height: 12,
                        child: Image.network(
                          element.settings!['favicon'],
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.error, size: 12),
                          fit: BoxFit.cover,
                        )),
                  )
                : const SizedBox(width: 0, height: 0),
          ),
          Text(
            element.settings?['feedTitle'] != null
                ? element.settings!['feedTitle'].length < 24
                    ? element.settings!['feedTitle']
                    : element.settings!['feedTitle'].substring(0, 24)
                : '',
            style: TextStyle(color: Theme.of(context).colorScheme.secondary),
          ),
          const SizedBox(
            width: 8,
            height: 0,
          ),
          // Text(item.authors != null ? item.authors![0].name ?? '' : ''),
          const Spacer(),
          Text(
              element.updated != null
                  ? DateFormat('EEE, MM/dd HH:MM').format(element.updated!)
                  : '',
              style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }

  //
  // Feed Element Tile
  //
  Widget _bulidElementTile(FeedElement element, {Color? color}) {
    // debugPrint('element:$element');
    final imageUrl = _getImageUrl(element);
    // when title is empty, replace it with description (CNN)
    final title = element.title != null && element.title!.isNotEmpty
        ? element.title!
        : element.description ?? '';
    return ListTile(
      minVerticalPadding: 12.0,
      tileColor: color,
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // title
          Expanded(
            child: Text(
              title,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 4, height: 0),
          // image
          imageUrl != null
              ? ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  child: SizedBox(
                    width: 100,
                    height: 80,
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      width: 100,
                      height: 80,
                      loadingBuilder: (context, child, loadingProgress) =>
                          Container(
                        width: 100,
                        height: 80,
                        color: Theme.of(context)
                            .colorScheme
                            .background
                            .withOpacity(0.2),
                        child: child,
                      ),
                      errorBuilder: (_, __, ___) => const SizedBox(
                        width: 0,
                        height: 0,
                      ),
                    ),
                  ))
              : const SizedBox(width: 0, height: 0),
        ],
      ),
      subtitle: _buildSubTitle(element),
      onTap: () {
        if (element.link != null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => FeedWebView(
                pageTitle: element.settings?['feedTitle'] ?? 'Back to Nuntium',
                pageUrl: element.link!,
              ),
            ),
          );
        } else {
          // if (element.description != null) {
          //   Navigator.of(context).push(
          //     MaterialPageRoute(
          //       builder: (context) => FeedHtmlView(
          //         contentHtml: element.description!,
          //       ),
          //     ),
          //   );
          // }
        }
      },
    );
  }

  //
  // Feed Element List
  //
  Widget _buildFeedElementList() {
    final bloc = context.watch<FeedBloc>();
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color oddTileColor = colorScheme.secondary.withOpacity(0.02);
    final Color evenTileColor = colorScheme.secondary.withOpacity(0.10);

    // debugPrint('selected channels: ${bloc.selectedChannels}');
    return bloc.selectedChannels.isEmpty
        ? bloc.getCurrentLabel().title == allChannels
            ? const FirstTime()
            : const EmptyList()
        : FutureBuilder<List<FeedElement>>(
            future: bloc.getFeedElements(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final elements = snapshot.data!;
                return ListView.builder(
                  controller: _controller,
                  itemCount: elements.length,
                  itemBuilder: (context, index) => _bulidElementTile(
                      elements[index],
                      color: index.isEven ? evenTileColor : oddTileColor),
                );
              } else {
                return const Center(
                  child: SizedBox.square(
                    dimension: 20.0,
                    child: CircularProgressIndicator(),
                  ),
                );
              }
            },
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // App Name
            Text(
              appName,
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(width: 10),
            // Label Icon
            Icon(
              Icons.label_outline_rounded,
              size: 20,
              color: Theme.of(context).colorScheme.tertiary,
            ),
            const SizedBox(width: 5),
            // Label Menu
            _buildLabelDropDown(context),
          ],
        ),
        actions: [_buildScaffoldMenu()],
      ),
      body: RefreshIndicator(
        child: _buildFeedElementList(),
        onRefresh: () async {
          setState(() {});
        },
      ),
    );
  }
}
