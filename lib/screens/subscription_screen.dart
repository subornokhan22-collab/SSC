import 'package:flutter/material.dart';

/// সাবস্ক্রিপশন পর্দা — এখানকার দাম/নম্বর/নিয়ম নিজের মতো বদলে নাও।
/// এখন এটি তথ্যমূলক; পরে bKash/অনলাইন পেমেন্ট যুক্ত করা যাবে।
class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  // ⚠️ এখানে নিজের তথ্য বসাও
  static const String hotline = '01XXXXXXXXX'; // তোমার WhatsApp/মোবাইল
  static const String priceLine = 'মাসিক ১০০ টাকা / বার্ষিক ১০০০ টাকা';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('সাবস্ক্রিপশন কিনো')),
      body: ListView(
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
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.workspace_premium, color: Color(0xFFF7B733), size: 34),
                    SizedBox(width: 10),
                    Text('A-Learning Pro',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900)),
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  '• সম্পূর্ণ প্রশ্নপত্র প্রিন্ট (PDF)\n• কাস্টম টেস্ট পেপার\n• কোনো ওয়াটারমার্ক নেই\n• নতুন ফিচার সবার আগে',
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
                Text('মূল্য',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 6),
                Text(priceLine, style: TextStyle(fontSize: 14.5, height: 1.5)),
                SizedBox(height: 14),
                Divider(),
                SizedBox(height: 10),
                Text('কীভাবে কিনবে?',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 6),
                Text(
                  'নিচের নম্বরে WhatsApp এ নক করো — পেমেন্ট (bKash) সম্পন্ন হলে তোমার ইমেইলে Pro চালু করে দেওয়া হবে। তারপর অ্যাপের Profile ট্যাবে "Pro সিংক" চাপলেই হয়ে যাবে!',
                  style: TextStyle(fontSize: 13.5, height: 1.6),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.phone_iphone, size: 20),
                    SizedBox(width: 8),
                    Text(hotline,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
