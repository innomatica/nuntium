import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../logic/feed_bloc.dart';
import '../../models/feed_label.dart';

class LabelManager extends StatefulWidget {
  const LabelManager({Key? key}) : super(key: key);

  @override
  State<LabelManager> createState() => _LabelManagerState();
}

class _LabelManagerState extends State<LabelManager> {
  String? _labelName;
  int _itemCount = 0;

  //
  // Bottom Sheet
  //
  Future _showBottomSheet({String? currentLabel}) {
    return showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8.0)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
            bottom: 12 + MediaQuery.of(context).viewInsets.bottom,
            left: 12,
            right: 12),
        child: TextFormField(
          autofocus: true,
          initialValue: currentLabel,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            label: const Text('Label Name'),
            hintText: 'World News',
            suffix: IconButton(
              icon: const Icon(Icons.check),
              onPressed: () {
                Navigator.of(context).pop(_labelName);
              },
            ),
          ),
          onChanged: (value) {
            _labelName = value;
          },
        ),
      ),
    );
  }

  //
  // Body
  //
  Widget _buildBody() {
    final bloc = context.watch<FeedBloc>();
    final labels = bloc.labels;
    _itemCount = labels.length;

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: labels.length,
      itemBuilder: (context, index) {
        return Card(
          child: ListTile(
            // key: Key('$index'),
            title: Text(labels[index].title),
            trailing: IconButton(
              icon: Icon(
                Icons.delete_rounded,
                color: Theme.of(context).colorScheme.error,
              ),
              onPressed: () async {
                await bloc.deleteFeedLabel(labels[index]);
              },
            ),
            onTap: () {
              _showBottomSheet(currentLabel: labels[index].title).then((value) {
                if (value != null && value.isNotEmpty) {
                  final label = labels[index];
                  label.title = value;
                  bloc.updateFeedLabel(label);
                }
              });
            },
          ),
        );
      },
    );
  }

  //
  // Floating Action Button
  //
  Widget _buildFab() {
    return FloatingActionButton(
      child: const Icon(Icons.add_rounded),
      onPressed: () {
        _showBottomSheet().then((value) {
          if (value != null && value.isNotEmpty) {
            final bloc = context.read<FeedBloc>();
            bloc.addFeedLabel(FeedLabel(position: _itemCount, title: value));
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Labels'),
      ),
      body: _buildBody(),
      // resizeToAvoidBottomInset: true,
      floatingActionButton: _buildFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
