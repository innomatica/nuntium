import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../logic/feed_bloc.dart';
import '../../models/feed_channel.dart';
import '../../models/feed_source.dart';
import '../../shared/constants.dart';
import '../../shared/helpers.dart';

class CuratedFeedPage extends StatefulWidget {
  const CuratedFeedPage({Key? key}) : super(key: key);

  @override
  State<CuratedFeedPage> createState() => _CuratedFeedPageState();
}

class _CuratedFeedPageState extends State<CuratedFeedPage> {
  //
  // Channel Selection Dialog
  //
  void _showChannelSelection(int index, FeedSource source) {
    final bloc = context.read<FeedBloc>();
    final channels = source.channels?.entries
        .map((e) => FeedChannel(
            title: '${source.nickname} | ${e.key}',
            url: e.value,
            icon: source.favicon,
            labels: [],
            labelIds: [],
            updated: DateTime.now(),
            settings: {}))
        .toList();
    if (channels == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No channel data found...')),
      );
    } else {
      // build switch flags
      final switchFlags = List.generate(channels.length,
          (index) => bloc.channels.any((e) => e.url == channels[index].url));

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                source.title,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.tertiary),
              ),
            ],
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 0, vertical: 20),
          content: StatefulBuilder(builder: (context, setDialogState) {
            return SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: channels.length,
                itemBuilder: (context, index) => SwitchListTile(
                  value: switchFlags[index],
                  title: Text(channels[index].title?.split('|')[1] ?? ''),
                  onChanged: (value) {
                    if (value) {
                      bloc.addFeedChannel(channels[index]);
                    } else {
                      bloc.deleteFeedChannelByUrl(channels[index].url);
                    }
                    setDialogState(() => switchFlags[index] = value);
                  },
                ),
              ),
            );
          }),
        ),
      );
    }
    // create a list for local state update
  }

  //
  // Source Tile
  //
  Widget _buildSourceTile(int index, FeedSource source) {
    return Card(
      child: ListTile(
        title: Text(source.title),
        onTap: () async {
          _showChannelSelection(index, source);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("$appName Selected")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder<List<FeedSource>?>(
          // future: getFeedSource(Localizations.localeOf(context)),
          future: getFeedSource(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final sources = snapshot.data!;
              return ListView.builder(
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                itemCount: sources.length,
                itemBuilder: (context, index) =>
                    _buildSourceTile(index, sources[index]),
              );
            } else {
              return const Center(
                child: SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
