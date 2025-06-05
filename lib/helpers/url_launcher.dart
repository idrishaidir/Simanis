import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> launchURL(BuildContext context, String url) async {
  final Uri uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Tidak dapat membuka URL')));
  }
}
