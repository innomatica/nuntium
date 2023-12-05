import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../logic/feed_bloc.dart';
import '../../models/feed_label.dart';
import '../../shared/constants.dart';
import 'channel_browser.dart';
import 'channel_details.dart';
import 'curated_feeds.dart';

class ChannelListPage extends StatefulWidget {
  const ChannelListPage({super.key});

  @override
  State<ChannelListPage> createState() => _ChannelListPageState();
}

class _ChannelListPageState extends State<ChannelListPage> {
  final _keywordController = TextEditingController();
  final _feedUrlController = TextEditingController();

  @override
  void dispose() {
    _keywordController.dispose();
    _feedUrlController.dispose();
    super.dispose();
  }

  //
  // Dialog Menu
  //
  void _buildDialogMenu() {
    final iconColor = Theme.of(context).colorScheme.tertiary;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Center(
          child: Text('Search Feed Channels',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              )),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        content: SingleChildScrollView(
          child: Column(
            children: [
              //
              // Search and Navigate
              //
              ListTile(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.search_rounded, color: iconColor),
                        const Text('  Search with Keywords'),
                      ],
                    ),
                    TextField(
                      controller: _keywordController,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 0,
                          vertical: 0,
                        ),
                        labelText: 'keyword',
                        hintText: 'cbc',
                        suffix: IconButton(
                            icon: const Icon(Icons.check),
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ChannelBrowserPage(
                                      keyword: _keywordController.text),
                                ),
                              );
                            }),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              //
              // Direct entry
              //
              ListTile(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.edit_note_rounded, color: iconColor),
                        const Text('  Direct URL Entry'),
                      ],
                    ),
                    TextField(
                      controller: _feedUrlController,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 0,
                          vertical: 0,
                        ),
                        labelText: 'url',
                        hintText: 'https://www.cbc.ca/cmlink/rss-topstories',
                        suffix: IconButton(
                            icon: const Icon(Icons.check),
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ChannelBrowserPage(
                                      url: _feedUrlController.text),
                                ),
                              );
                            }),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              //
              // Select from the list
              //
              ListTile(
                title: Row(
                  children: [
                    Icon(Icons.format_list_bulleted_rounded, color: iconColor),
                    const Text('  Curated List'),
                  ],
                ),
                subtitle: const Text('$appName Selected Feeds'),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CuratedFeedPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  //
  // Instruction
  //
  Widget _buildInstruction() {
    const textStyle = TextStyle(fontSize: 16.0);
    final iconColor = Theme.of(context).colorScheme.tertiary;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tap the button \ud83d\udc47 and add new channels',
            style: textStyle,
          ),
          const SizedBox(height: 16, width: 0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.search_rounded, color: iconColor),
                  const Text(' Find RSS feeds from websites,',
                      style: textStyle),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.edit_note_rounded, color: iconColor),
                  const Text(' Enter RSS URL directly, or', style: textStyle),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.format_list_bulleted_rounded, color: iconColor),
                  const Text(' Select channels from the list',
                      style: textStyle),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChannelList(FeedBloc bloc) {
    final channels = bloc.channels;
    final labels = bloc.labels;

    return ListView.builder(
      itemCount: channels.length,
      itemBuilder: (context, index) {
        final channel = channels[index];

        return Card(
          child: ListTile(
            //
            // Feed Channel Title
            //
            title: Text(channel.title ?? 'Unknown Channel'),
            //
            // Channel Labels
            //
            subtitle: Row(
              children: [
                Expanded(
                  child: Text(
                    channel.labelIds
                        .map((e) => labels.firstWhere(
                              (l) => l.id == e,
                              // labelId not found in labels
                              orElse: () {
                                // db failure: get rid of the id
                                debugPrint('orphan label id found');
                                // use degenerate label for now
                                return FeedLabel(id: 0, title: '', position: 0);
                              },
                            ).title)
                        .join(', '),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    overflow: TextOverflow.fade,
                  ),
                ),
                Text(DateFormat('EE, MMM d H:m').format(channel.updated)),
              ],
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) {
                  return ChannelDetailsPage(channel);
                }),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<FeedBloc>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Feed Channels"),
        // actions: [_buildPopupMenu(), const SizedBox(width: 8)],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: bloc.channels.isNotEmpty
            ? _buildChannelList(bloc)
            : _buildInstruction(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('New Channels'),
        onPressed: () {
          _buildDialogMenu();
        },
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
