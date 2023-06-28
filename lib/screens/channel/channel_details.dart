import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../logic/feed_bloc.dart';
import '../../models/feed_channel.dart';

class ChannelDetailsPage extends StatefulWidget {
  final FeedChannel channel;
  const ChannelDetailsPage(this.channel, {Key? key}) : super(key: key);

  @override
  State<ChannelDetailsPage> createState() => _ChannelDetailsPageState();
}

class _ChannelDetailsPageState extends State<ChannelDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  late String _channelTitle;

  // late String _maxItems;
  late String _feedUrl;
  String? _iconUrl;

  @override
  void initState() {
    _channelTitle = widget.channel.title ?? 'Unknown Channel';
    _feedUrl = widget.channel.url;
    _iconUrl = widget.channel.icon;
    super.initState();
  }

  //
  // Channel Title
  //
  Widget _buildChannelTitle(FeedBloc bloc) {
    return Focus(
      onFocusChange: (hasFocus) async {
        if (!hasFocus) {
          if (_formKey.currentState!.validate()) {
            await bloc.updateFeedChannel(widget.channel);
          }
        }
      },
      child: TextFormField(
        initialValue: _channelTitle,
        decoration: const InputDecoration(
          label: Text("Channel Title"),
        ),
        onChanged: (value) {
          _channelTitle = value;
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Channel Title should not be empty";
          }
          return null;
        },
      ),
    );
  }

  //
  // Maximum Items
  // Widget _buildMaxItems() {
  //   return TextFormField(
  //     initialValue: _maxItems,
  //     decoration: const InputDecoration(
  //       label: Text("Maximum Items in the Channel"),
  //     ),
  //     onChanged: (value) {
  //       _maxItems = value;
  //     },
  //   );
  // }

  //
  // Feed URL
  //
  Widget _buildFeedUrl(FeedBloc bloc) {
    return Focus(
      onFocusChange: (hasFocus) async {
        if (!hasFocus) {
          if (_formKey.currentState!.validate()) {
            await bloc.changeFeedChannelUrl(widget.channel, _feedUrl);
          }
        }
      },
      child: TextFormField(
        initialValue: _feedUrl,
        decoration: const InputDecoration(label: Text("Feed URL")),
        onChanged: (value) {
          _feedUrl = value;
        },
        validator: (value) {
          if ((value == null) ||
              (value.isEmpty) ||
              (!Uri.parse(value).isAbsolute)) {
            return "URL is not valid";
          }
          return null;
        },
      ),
    );
  }

  //
  // Favicon URL
  //
  Widget _buildFaviconUrl(FeedBloc bloc) {
    return Focus(
      onFocusChange: (hasFocus) async {
        if (!hasFocus) {
          if (_formKey.currentState!.validate()) {
            widget.channel.icon = _iconUrl;
            await bloc.updateFeedChannel(widget.channel);
          }
        }
      },
      child: TextFormField(
        initialValue: _iconUrl,
        decoration: const InputDecoration(
          label: Text("Favicon URL"),
        ),
        onChanged: (value) {
          _iconUrl = value;
        },
        validator: (value) {
          if ((value != null) &&
              (value.isNotEmpty) &&
              (!Uri.parse(value).isAbsolute)) {
            return "URL is not valid";
          }
          return null;
        },
      ),
    );
  }

  //
  // Label Selection
  //
  Widget _buildLabelList(FeedBloc bloc) {
    final labels = bloc.labels;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 14.0),
        Text(
          'Labels',
          style: TextStyle(
            fontSize: 13.0,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          itemCount: labels.length,
          itemBuilder: (context, index) => CheckboxListTile(
            visualDensity: VisualDensity.compact,
            // value: widget.channel.labels.contains(labels[index].title),
            value: widget.channel.labelIds.contains(labels[index].id),
            onChanged: (value) {
              if (value == true) {
                // widget.channel.labels.add(labels[index].title);
                widget.channel.labelIds.add(labels[index].id);
              } else {
                // widget.channel.labels.remove(labels[index].title);
                widget.channel.labelIds.remove(labels[index].id);
              }
              // debugPrint('labelId changed: ${widget.channel.labelIds}');
              bloc.updateFeedChannel(widget.channel);
              bloc.updateSelectedChannels();
            },
            title: Text(
              labels[index].title,
              style:
                  const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w400),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<FeedBloc>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text("Channel Settings"),
        actions: [
          TextButton.icon(
            onPressed: () async {
              // delete the channel and update stream
              await bloc.deleteFeedChannelByUrl(widget.channel.url);
              if (mounted) {
                Navigator.pop(context);
              }
            },
            label: const Text('delete'),
            icon:
                Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              _buildChannelTitle(bloc),
              _buildFeedUrl(bloc),
              _buildFaviconUrl(bloc),
              _buildLabelList(bloc),
            ],
          ),
        ),
      ),
    );
  }
}
