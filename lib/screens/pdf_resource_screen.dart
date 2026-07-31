// lib/screens/pdf_resource_screen.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PDFResourceScreen extends StatelessWidget {
  const PDFResourceScreen({super.key});

  final String googleDriveFolderUrl =
      'https://drive.google.com/drive/folders/19UW5mGKcBgorLSmO-joBer0HBodGA65G';

  Future<void> _openDriveFolder(BuildContext context) async {
    final Uri url = Uri.parse(googleDriveFolderUrl);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('লিংক খোলা যায়নি।')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF রিসোর্স'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: const CircleAvatar(
              radius: 26,
              backgroundColor: Color(0x1AF59E0B),
              child: Icon(Icons.folder, color: Colors.amber, size: 28),
            ),
            title: const Text(
              'SSC নোটস ড্রাইভ',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: const Text('বিষয়ভিত্তিক PDF নোট, সাজেশন ও শীট দেখুন'),
            trailing: const Icon(Icons.open_in_new),
            onTap: () => _openDriveFolder(context),
          ),
        ),
      ),
    );
  }
}
