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
  bool _hasError = false;
  int _retryCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) => setState(() {
            _loading = false;
            _hasError = false;
          }),
          onWebResourceError: (error) {
            // net::ERR_CACHE_MISS is a common Android WebView quirk when a
            // page loads before the view is fully attached. One silent
            // retry usually resolves it.
            if (_retryCount < 1) {
              _retryCount++;
              Future.delayed(const Duration(milliseconds: 300), () {
                if (mounted) _controller.loadRequest(Uri.parse(_embedUrl));
              });
            } else {
              setState(() {
                _loading = false;
                _hasError = true;
              });
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(_embedUrl));
  }

  void _retry() {
    setState(() {
      _loading = true;
      _hasError = false;
      _retryCount = 0;
    });
    _controller.loadRequest(Uri.parse(_embedUrl));
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
      body: _hasError
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cloud_off, size: 56, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      'PDF ফোল্ডার লোড করা যায়নি।',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'ইন্টারনেট সংযোগ পরীক্ষা করে আবার চেষ্টা করুন।',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _retry,
                      icon: const Icon(Icons.refresh),
                      label: const Text('আবার চেষ্টা করুন'),
                    ),
                    TextButton(
                      onPressed: _openExternally,
                      child: const Text('ব্রাউজারে খুলুন'),
                    ),
                  ],
                ),
              ),
            )
          : Stack(
              children: [
                WebViewWidget(controller: _controller),
                if (_loading) const Center(child: CircularProgressIndicator()),
              ],
            ),
    );
  }
}
