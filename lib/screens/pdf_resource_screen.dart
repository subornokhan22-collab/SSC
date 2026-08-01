import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PdfResourceScreen extends StatefulWidget {
  const PdfResourceScreen({super.key});

  @override
  State<PdfResourceScreen> createState() => _PdfResourceScreenState();
}

class _PdfResourceScreenState extends State<PdfResourceScreen> {
  late final WebViewController _controller;
  bool _loading = true;

  // TODO: replace with your actual Google Drive folder share link
  static const String driveUrl = 'https://drive.google.com/drive/folders/https://drive.google.com/drive/folders/19UW5mGKcBgorLSmO-joBer0HBodGA65G';

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) => setState(() => _loading = true),
        onPageFinished: (_) => setState(() => _loading = false),
      ))
      ..loadRequest(Uri.parse(driveUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('রিসোর্স / PDF'),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: () => _controller.reload())],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading) const LinearProgressIndicator(),
        ],
      ),
    );
  }
}
