import 'package:flutter/material.dart';

import '../services/app_style.dart';
import '../services/paper_license.dart';

/// সাবস্ক্রিপশন পর্দা।
///  • ফ্রি ব্যবহারকারী: দাম + কেনার কথা।
///  • Pro ব্যবহারকারী: শুধু বড় "Now you are using Pro" বার্তা — বাকি সব লুকানো।
class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  // ⚠️ এখানে নিজের তথ্য বসাও
  static const String hotline = '01715041725; // তোমার WhatsApp/মোবাইল
  static const String priceLine = 'BDT 200 per month / BDT 2,000 per year';

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  bool _isPro = false;

  @override
  void initState() {
    super.initState();
    AppStyle.load();
    PaperLicense.isPro().then((v) {
      if (mounted) setState(() => _isPro = v);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyle.bg,
      appBar: AppBar(
        title: Text(_isPro ? 'A-Learning Pro' : 'Buy Subscription'),
      ),
      body: _isPro ? _proBody() : _buyBody(),
    );
  }

  // ══ Pro ব্যবহারকারীর জন্য — শুধু "Now you are using Pro" ══════════════
  Widget _proBody() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(26),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 34),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              colors: [Color(0xFF0D3B66), Color(0xFF1B8A8F)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  blurRadius: 20,
                  offset: const Offset(0, 10)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.14),
                  border: Border.all(color: const Color(0xFFF7B733), width: 2),
                ),
                child: const Icon(Icons.verified_rounded,
                    color: Color(0xFFF7B733), size: 54),
              ),
              const SizedBox(height: 18),
              const Text(
                'Now you are using Pro',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5),
              ),
              const SizedBox(height: 10),
              Text(
                'আপনি এখন প্রো ব্যবহার করছেন — সম্পূর্ণ পেপার প্রিন্ট,\nকোনো ওয়াটারমার্ক নেই, সব ফিচার আনলকড। ধন্যবাদ! 🎉',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    height: 1.7),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ══ ফ্রি ব্যবহারকারীর জন্য — আগের মতোই দাম/নিয়ম ═══════════════════════
  Widget _buyBody() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Color(0xFF0D3B66), Color(0xFF1B8A8F)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.workspace_premium,
                      color: Color(0xFFF7B733), size: 34),
                  SizedBox(width: 10),
                  Text('A-Learning Pro',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900)),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                '• Full question-paper printing (PDF)\n• Custom test papers\n• No watermark\n• New features first',
                style: TextStyle(color: Colors.white, fontSize: 14, height: 1.8),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 12,
                  offset: const Offset(0, 5)),
            ],
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Price',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 6),
              Text(SubscriptionScreen.priceLine,
                  style: TextStyle(fontSize: 14.5, height: 1.5)),
              SizedBox(height: 14),
              Divider(),
              SizedBox(height: 10),
              Text('How to buy?',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 6),
              Text(
                'Knock on WhatsApp at the number below — once your bKash payment is done, Pro will be activated on YOUR EMAIL. Then open the Profile tab and tap "Sync Pro" — done!',
                style: TextStyle(fontSize: 13.5, height: 1.6),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.phone_iphone, size: 20),
                  SizedBox(width: 8),
                  Text(SubscriptionScreen.hotline,
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
