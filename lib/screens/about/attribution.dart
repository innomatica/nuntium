import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../shared/settings.dart';

class Attribution extends StatelessWidget {
  const Attribution({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      children: [
        ListTile(
          title: Text(
            'App Icons',
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
          subtitle: const Text("News icons created by Freepik - Flaticon"),
          onTap: () {
            launchUrl(Uri.parse(urlNewspaperIcons));
          },
        ),
        ListTile(
          title: Text(
            'Store Background Image',
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
          subtitle: const Text("Image created by AbsolutVision - unsplash.com"),
          onTap: () {
            launchUrl(Uri.parse(urlBackgroundImage));
          },
        ),
      ],
    );
  }
}
