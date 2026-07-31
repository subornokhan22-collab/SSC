// lib/screens/pdf_resource_screen.dart

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class PDFResourceScreen extends StatefulWidget {
  const PDFResourceScreen({super.key});

  @override
  State<PDFResourceScreen> createState() => _PDFResourceScreenState();
}

class _PDFResourceScreenState extends State<PDFResourceScreen> {
  static const String _folderId = '19UW5mGKcBgorLSmO-joBer0HBodGA65G';
  static const String _embedUrl =
      'https://drive.google.com/embeddedfolderview?id=$_folderId#grid';
  static const String _externalUrl =
      'https://drive.google.com/drive/folders/$_folderId';

  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) => setState(() => _loading = false),
        ),
      )
      ..loadRequest(Uri.parse(_embedUrl));
  }

  Future<void> _openExternally() async {
    final uri = Uri.parse(_externalUrl);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
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
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_new),
            tooltip: 'ব্রাউজারে খুলুন',
            onPressed: _openExternally,
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
