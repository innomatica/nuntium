import 'package:flutter/material.dart';

import '../../shared/constants.dart';

//
// Instruction: No channels
//
class FirstTime extends StatelessWidget {
  const FirstTime({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(fontSize: 16.0, fontWeight: FontWeight.w400);
    // give some time for the logic to load the actual data
    return FutureBuilder(
      future: Future.delayed(const Duration(seconds: 2)),
      builder: (context, snapshot) {
        return snapshot.connectionState != ConnectionState.done
            ? const Center(
                child: SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(),
                ),
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Welcome to $appName',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.tertiary,
                        )),
                    const SizedBox(height: 16.0, width: 0.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Find ', style: textStyle),
                            Icon(Icons.rss_feed_rounded,
                                color: Theme.of(context).colorScheme.primary),
                            const Text(
                              'Feed Channels menu \u261d',
                              style: TextStyle(
                                  fontSize: 16.0, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8.0, width: 0.0),
                        const Text('And add your favorite channels',
                            style: textStyle),
                        const SizedBox(height: 16.0, width: 0.0),
                      ],
                    ),
                  ],
                ),
              );
      },
    );
  }
}

//
// Instruction: No Channels for the label
//
class EmptyList extends StatelessWidget {
  const EmptyList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(fontSize: 16.0, fontWeight: FontWeight.w400);
    // give some time for the logic to load the actual data
    return FutureBuilder(
      future: Future.delayed(const Duration(seconds: 1)),
      builder: (context, snapshot) {
        return snapshot.connectionState != ConnectionState.done
            ? const Center(
                child: SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(),
                ),
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('No channels for this label',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        )),
                    const SizedBox(height: 16.0, width: 0.0),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('On the ', style: textStyle),
                        Icon(Icons.rss_feed_rounded,
                            color: Theme.of(context).colorScheme.primary),
                        const Text(
                          'Feed Channels menu \u261d',
                          style: TextStyle(
                              fontSize: 16.0, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0, width: 0.0),
                    const Text('Assign labels to your channels',
                        style: textStyle),
                  ],
                ),
              );
      },
    );
  }
}
