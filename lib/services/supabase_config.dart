/// Supabase কনফিগারেশন — লগইন/OTP চালু করতে নিচের দুটো ঘর পূরণ করো।
///
/// কোথায় পাবে (SUPABASE_SETUP.md গাইড দেখো):
///   supabase.com → তোমার প্রজেক্ট → Project Settings → API
///   - Project URL          → নিচে url ঘরে
///   - anon public key      → নিচে anonKey ঘরে
///
/// ঘর ফাঁকা থাকলে লগইন ফিচারটি নিজে থেকেই বন্ধ থাকে — অ্যাপের বাকি সব
/// আগের মতো চলবে, কোনো error আসবে না।
class SupabaseConfig {
  // ⚠️ এখানে তোমার Supabase প্রজেক্ট URL বসাও, যেমন:
  // static const String url = 'https://abcdwxyz.supabase.co';
  static const String url = 'https://vxexidxdoghdmzvkvgqk.supabase.co';

  // ⚠️ এখানে তোমার anon public key বসাও (eyJhbGciOi... দিয়ে শুরু হয়)
  static const String anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ4ZXhpZHhkb2doZG16dmt2Z3FrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODU5ODYzMTcsImV4cCI6MjEwMTU2MjMxN30.hp1ZatmQpCXDFClWlOQEpSJhUwh8bfvspWYKXnXcMY4';

  /// কনফিগ পূরণ করা আছে কিনা
  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
}
