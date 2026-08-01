import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PDFResourceScreen extends StatefulWidget {
  const PDFResourceScreen({Key? key}) : super(key: key);

  @override
  State<PDFResourceScreen> createState() => _PDFResourceScreenState();
}

class _PDFResourceScreenState extends State<PDFResourceScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;

  final String _driveUrl = 'https://drive.google.com/embeddedfolderview?id=19UW5mGKcBgorLSmO-joBer0HBodGA65G#grid';

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _hasError = false;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _isLoading = false;
              _hasError = true;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(_driveUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF রিসোর্স', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1A82BB),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _controller.reload();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          if (!_hasError) WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: Color(0xFF1A82BB)),
            ),
          if (_hasError)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
                  const SizedBox(height: 12),
                  const Text('ইন্টারনেট সংযোগ সংযোগ পরীক্ষা করে পুনরায় চেষ্টা করুন।'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => _controller.reload(),
                    child: const Text('পুনরায় চেষ্টা করুন'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
