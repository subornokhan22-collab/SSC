'use strict';
/* Tutor's Desk question admin — hosted version.
 *
 * Talks straight to Supabase from the browser. There is no backend of our
 * own, so this can be hosted as static files anywhere and the URL never
 * expires.
 *
 * Everything published here is read by the app's QuestionSync on next
 * launch, so questions reach tutors without an app update.
 */

const SUPABASE_URL = 'https://vxexidxdoghdmzvkvgqk.supabase.co';
const SUPABASE_ANON =
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ4ZXhpZHhkb2doZG16dmt2Z3FrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODU5ODYzMTcsImV4cCI6MjEwMTU2MjMxN30.hp1ZatmQpCXDFClWlOQEpSJhUwh8bfvspWYKXnXcMY4';

const BUCKET = 'question-figures';
const $ = (id) => document.getElementById(id);

const SUBJECTS = {
  physics: 'পদার্থবিজ্ঞান (Physics)',
  chemistry: 'রসায়ন (Chemistry)',
  higher_math: 'উচ্চতর গণিত (Higher Math)',
  biology: 'জীববিজ্ঞান (Biology)',
  general_math: 'গণিত (General Math)',
  bangla_1st: 'বাংলা প্রথম পত্র (Bangla 1st)',
  bangla_2nd: 'বাংলা দ্বিতীয় পত্র (Bangla 2nd)',
  english_1st: 'ইংরেজি ১ম পত্র (English 1st)',
  english_2nd: 'ইংরেজি ২য় পত্র (English 2nd)',
  bgs: 'বাংলাদেশ ও বিশ্বপরিচয় (BGS)',
  religion: 'ইসলাম ও নৈতিক শিক্ষা (Religion & Moral Ed.)',
  general_science: 'বিজ্ঞান (General Science)',
  agriculture: 'কৃষিশিক্ষা (Agriculture)',
  business_ent: 'ব্যবসায় উদ্যোগ (Business Entre.)',
  accounting: 'হিসাববিজ্ঞান (Accounting)',
  finance: 'ফিন্যান্স ও ব্যাংকিং (Finance & Banking)',
  ict: 'তথ্য ও যোগাযোগ প্রযুক্তি (ICT)',
  physical_edu: 'শারীরিক শিক্ষা (Physical Education)',
  career: 'ক্যারিয়ার শিক্ষা (Career Education)',
  history: 'বাংলাদেশের ইতিহাস ও বিশ্বসভ্যতা (History of Bangladesh)',
  civics: 'পৌরনীতি ও নাগরিকতা (Civics & Citizenship)',
};

const ID_PREFIX = {
  physics: 'phy',
  chemistry: 'chem',
  higher_math: 'hm',
  biology: 'bio',
  general_math: 'gm',
  bangla_1st: 'b1',
  bangla_2nd: 'b2',
  english_1st: 'e1',
  english_2nd: 'e2',
  bgs: 'bgs',
  religion: 'rel',
  general_science: 'gsci',
  agriculture: 'agr',
  business_ent: 'bent',
  accounting: 'acc',
  finance: 'fin',
  ict: 'ict',
  physical_edu: 'pe',
  career: 'car',
  history: 'hist',
  civics: 'civ',
};

// Every chapter that already has questions, per subject, in textbook order.
// Typing these Bengali names by hand is error-prone, and a mismatched name
// means the question silently never shows under any chapter.
const CHAPTERS = {
 "physics": [
  "অধ্যায় ১: ভৌত রাশি এবং তাদের পরিমাপ",
  "অধ্যায় ২: গতি",
  "অধ্যায় ৩: বল",
  "অধ্যায় ৪: কাজ, ক্ষমতা ও শক্তি",
  "অধ্যায় ৫: পদার্থের অবস্থা ও চাপ",
  "অধ্যায় ৬: বস্তুর ওপর তাপের প্রভাব",
  "অধ্যায় ৭: তরঙ্গ ও শব্দ",
  "অধ্যায় ৮: আলোর প্রতিফলন",
  "অধ্যায় ৯: আলোর প্রতিসরণ",
  "অধ্যায় ১০: স্থির বিদ্যুৎ",
  "অধ্যায় ১১: চল বিদ্যুৎ",
  "অধ্যায় ১২: বিদ্যুতের চৌম্বক ক্রিয়া",
  "অধ্যায় ১৩: তেজস্ক্রিয়তা ও ইলেকট্রনিকস"
 ],
 "chemistry": [
  "অধ্যায় ১: রসায়নের ধারণা",
  "অধ্যায় ২: পদার্থের অবস্থা",
  "অধ্যায় ৩: পদার্থের গঠন",
  "অধ্যায় ৪: পর্যায় সারণি",
  "অধ্যায় ৫: রাসায়নিক বন্ধন",
  "অধ্যায় ৬: মোলের ধারণা ও রাসায়নিক গণনা",
  "অধ্যায় ৭: রাসায়নিক বিক্রিয়া",
  "অধ্যায় ৮: রসায়ন ও শক্তি",
  "অধ্যায় ৯: এসিড-ক্ষারক সমতা",
  "অধ্যায় ১০: খনিজ সম্পদ: ধাতু-অধাতু",
  "অধ্যায় ১১: খনিজ সম্পদ: জীবাশ্ম",
  "অধ্যায় ১২: আমাদের জীবনে রসায়ন"
 ],
 "higher_math": [
  "অধ্যায় ১: সেট ও ফাংশন",
  "অধ্যায় ২: বীজগাণিতিক রাশি",
  "অধ্যায় ৭: অসীম ধারা"
 ],
 "biology": [
  "অধ্যায় ১: জীবন পাঠ",
  "অধ্যায় ২: জীবকোষ ও টিস্যু",
  "অধ্যায় ৩: কোষ বিভাজন",
  "অধ্যায় ৪: জীবনীশক্তি",
  "অধ্যায় ৫: খাদ্য, পুষ্টি এবং পরিপাক",
  "অধ্যায় ৬: জীবে পরিবহন",
  "অধ্যায় ৭: গ্যাসীয় বিনিময়",
  "অধ্যায় ৮: রেচন প্রক্রিয়া",
  "অধ্যায় ৯: দৃঢ়তা প্রদান ও চলন",
  "অধ্যায় ১০: সমন্বয়",
  "অধ্যায় ১১: জীবের প্রজনন",
  "অধ্যায় ১২: জীবের বংশগতি ও জৈব অভিব্যক্তি",
  "অধ্যায় ১৩: জীবের পরিবেশ",
  "অধ্যায় ১৪: জীবপ্রযুক্তি"
 ],
 "general_math": [
  "অধ্যায় ১: বাস্তব সংখ্যা",
  "অধ্যায় ২: সেট ও ফাংশন",
  "অধ্যায় ৩: বীজগাণিতিক রাশি",
  "অধ্যায় ৪: সূচক ও লগারিদম",
  "অধ্যায় ৫: এক চলকবিশিষ্ট সমীকরণ",
  "অধ্যায় ৬: রেখা, কোণ ও ত্রিভুজ",
  "অধ্যায় ৭: ব্যবহারিক জ্যামিতি",
  "অধ্যায় ৮: বৃত্ত",
  "অধ্যায় ৯: ত্রিকোণমিতিক অনুপাত",
  "অধ্যায় ১০: দূরত্ব ও উচ্চতা",
  "অধ্যায় ১১: বীজগাণিতিক অনুপাত ও সমানুপাত",
  "অধ্যায় ১২: দুই চলকবিশিষ্ট সরল সহসমীকরণ",
  "অধ্যায় ১৩: সসীম ধারা",
  "অধ্যায় ১৪: অনুপাত, সদৃশতা ও প্রতিসমতা",
  "অধ্যায় ১৫: ক্ষেত্রফল সম্পর্কিত উপপাদ্য ও সম্পাদ্য",
  "অধ্যায় ১৬: পরিমিতি",
  "অধ্যায় ১৭: পরিসংখ্যান"
 ],
 "bangla_1st": [
  "গদ্য: প্রত্যুপকার",
  "গদ্য: ফুলের বিবাহ",
  "গদ্য: শুভা",
  "গদ্য: বই পড়া",
  "গদ্য: অভাগীর স্বর্গ",
  "গদ্য: নিরীহ বাঙালি",
  "গদ্য: পল্লিসাহিত্য",
  "গদ্য: আম-আঁটির ভেঁপু",
  "গদ্য: মানুষ মুহম্মদ (স.)",
  "গদ্য: নিমগাছ",
  "গদ্য: উপেক্ষিত শক্তির উদ্বোধন",
  "গদ্য: প্রবাস বন্ধু",
  "গদ্য: মমতাদি",
  "গদ্য: একুশের গল্প",
  "গদ্য: আমাদের নতুন গৌরবগাথা",
  "কবিতা: বন্দনা",
  "কবিতা: কপোতাক্ষ নদ",
  "কবিতা: প্রাণ",
  "কবিতা: অন্ধবধূ",
  "কবিতা: ঝরনার গান",
  "কবিতা: জীবন বিনিময়",
  "কবিতা: উমর ফারুক",
  "কবিতা: সেইদিন এই মাঠ",
  "কবিতা: যাব আমি তোমার দেশে",
  "কবিতা: আমার দেশ",
  "কবিতা: বৃষ্টি",
  "কবিতা: আমি কোনো আগন্তুক নই",
  "কবিতা: রানার",
  "কবিতা: তোমাকে পাওয়ার জন্য, হে স্বাধীনতা",
  "কবিতা: বোশেখ",
  "উপন্যাস: ১৯৭১",
  "নাটক: বহিপীর"
 ],
 "bangla_2nd": [
  "পরিচ্ছেদ ১: ভাষা ও বাংলা ভাষা",
  "পরিচ্ছেদ ২: বাংলা ব্যাকরণ",
  "পরিচ্ছেদ ৩: বাংলা ভাষারীতি ও বিভাজন",
  "পরিচ্ছেদ ৪: বাগ্‌যন্ত্র",
  "পরিচ্ছেদ ৫: ধ্বনি ও বর্ণ",
  "পরিচ্ছেদ ৬: স্বরধ্বনি",
  "পরিচ্ছেদ ৭: ব্যঞ্জনধ্বনি",
  "পরিচ্ছেদ ৮: বর্ণের উচ্চারণ",
  "পরিচ্ছেদ ৯: ধ্বনিপরিবর্তন",
  "পরিচ্ছেদ ১০: উপসর্গ দিয়ে শব্দ গঠন",
  "পরিচ্ছেদ ১১: প্রত্যয় দিয়ে শব্দ গঠন",
  "পরিচ্ছেদ ১২: সমাস দিয়ে শব্দ গঠন",
  "পরিচ্ছেদ ১৩: সন্ধি",
  "পরিচ্ছেদ ১৪: দ্বিরুক্ত শব্দ",
  "পরিচ্ছেদ ১৫: শব্দের শ্রেণিবিভাগ",
  "পরিচ্ছেদ ১৬: নরবাচক ও নারীবাচক শব্দ",
  "পরিচ্ছেদ ১৭: সংখ্যাবাচক শব্দ",
  "পরিচ্ছেদ ১৮: পদাশ্রিত নির্দেশক",
  "পরিচ্ছেদ ১৯: সর্বনাম",
  "পরিচ্ছেদ ২০: বিশেষণ",
  "পরিচ্ছেদ ২১: বিশেষ্য",
  "পরিচ্ছেদ ২২: ক্রিয়া",
  "পরিচ্ছেদ ২৩: অব্যয়",
  "পরিচ্ছেদ ২৪: যোজক",
  "পরিচ্ছেদ ২৫: আবেগ",
  "পরিচ্ছেদ ২৬: অনুসর্গ",
  "পরিচ্ছেদ ২৭: শব্দ",
  "পরিচ্ছেদ ২৮: বিভক্তি",
  "পরিচ্ছেদ ২৯: ক্রিয়া-বিভক্তি",
  "পরিচ্ছেদ ৩০: ক্রিয়ার কাল",
  "পরিচ্ছেদ ৩১: বাক্যের অংশ ও শ্রেণিবিভাগ",
  "পরিচ্ছেদ ৩২: বাক্যের বর্গ",
  "পরিচ্ছেদ ৩৩: উদ্দেশ্য ও বিধেয়",
  "পরিচ্ছেদ ৩৪: সরল, জটিল ও যৌগিক বাক্য",
  "পরিচ্ছেদ ৩৫: কারক",
  "পরিচ্ছেদ ৩৬: বাচ্য",
  "পরিচ্ছেদ ৩৭: উক্তি",
  "পরিচ্ছেদ ৩৮: যতিচিহ্ন",
  "পরিচ্ছেদ ৩৯: বাগর্থ",
  "পরিচ্ছেদ ৪০: বাগধারা",
  "পরিচ্ছেদ ৪১: প্রতিশব্দ",
  "পরিচ্ছেদ ৪২: বিপরীত শব্দ",
  "পরিচ্ছেদ ৪৩: শব্দজোড়",
  "পরিচ্ছেদ ৪৪: অনুচ্ছেদ",
  "পরিচ্ছেদ ৪৫: সারাংশ ও সারমর্ম",
  "পরিচ্ছেদ ৪৬: ভাব-সম্প্রসারণ",
  "পরিচ্ছেদ ৪৭: চিঠিপত্র",
  "পরিচ্ছেদ ৪৮: সংবাদ প্রতিবেদন",
  "পরিচ্ছেদ ৪৯: প্রবন্ধ"
 ],
 "english_1st": [
  "Unit One: Sense of Self",
  "Unit Two: Climate Change",
  "Unit Three: Pastimes",
  "Unit Four: Events and Festivals",
  "Unit Five: Problems Around Us",
  "Unit Six: Our Neighbours",
  "Unit Seven: People Who Stand Out",
  "Unit Eight: World Heritage",
  "Unit Nine: Unconventional Jobs",
  "Unit Ten: Dreams",
  "Unit Eleven: Reading from English Literature",
  "Unit Twelve: Roots",
  "Unit Thirteen: Loneliness",
  "Unit Fourteen: Renewable Energy",
  "Unit Fifteen: Media and Modes of E-communication",
  "Unit Sixteen: Graffiti"
 ],
 "english_2nd": [
  "Grammar: The Noun",
  "Grammar: Pronouns and Possessives",
  "Grammar: Adjectives",
  "Grammar: Verbs and Tenses",
  "Grammar: Verbs — Modals",
  "Grammar: Kinds of Verbs",
  "Grammar: The Adverb",
  "Grammar: The Preposition",
  "Grammar: Sentences and Punctuation",
  "Grammar: Introductory It and There",
  "Grammar: Conditionals",
  "Grammar: The Passive",
  "Grammar: Speech / Narration",
  "Grammar: Suffixes and Prefixes",
  "Grammar: Connectors and Linking Words",
  "Grammar: Tag Questions",
  "Writing: Paragraph",
  "Writing: E-mail / Letter / Application",
  "Writing: Short Composition"
 ],
 "bgs": [
  "অধ্যায় ১: পূর্ব বাংলার আন্দোলন ও জাতীয়তাবাদের উত্থান (১৯৪৭-১৯৭০)",
  "অধ্যায় ২: বাংলাদেশের স্বাধীনতা",
  "অধ্যায় ৩: সৌরজগৎ ও ভূমণ্ডল",
  "অধ্যায় ৪: বাংলাদেশের ভূপ্রকৃতি ও জলবায়ু",
  "অধ্যায় ৫: বাংলাদেশের নদ-নদী ও প্রাকৃতিক সম্পদ",
  "অধ্যায় ৬: রাষ্ট্র, নাগরিকতা ও আইন",
  "অধ্যায় ৭: বাংলাদেশ সরকারের বিভিন্ন অঙ্গ ও প্রশাসন ব্যবস্থা",
  "অধ্যায় ৮: বাংলাদেশের গণতন্ত্র ও নির্বাচন ব্যবস্থা",
  "অধ্যায় ৯: জাতিসংঘ ও বাংলাদেশ",
  "অধ্যায় ১০: জাতীয় সম্পদ ও অর্থনৈতিক ব্যবস্থা",
  "অধ্যায় ১১: অর্থনৈতিক নির্দেশকসমূহ ও বাংলাদেশের অর্থনীতির প্রকৃতি",
  "অধ্যায় ১২: বাংলাদেশ সরকারের অর্থ ও ব্যাংক ব্যবস্থা",
  "অধ্যায় ১৩: বাংলাদেশের পরিবার কাঠামো ও সামাজিকীকরণ",
  "অধ্যায় ১৪: বাংলাদেশের সামাজিক পরিবর্তন",
  "অধ্যায় ১৫: বাংলাদেশের সামাজিক সমস্যা ও প্রতিকার"
 ],
 "religion": [
  "প্রথম অধ্যায়: আকাইদ ও নৈতিক জীবন",
  "দ্বিতীয় অধ্যায়: শরিয়তের উৎস",
  "তৃতীয় অধ্যায়: ইবাদত",
  "চতুর্থ অধ্যায়: আখলাক",
  "পঞ্চম অধ্যায়: আদর্শ জীবনচরিত"
 ],
 "general_science": [
  "প্রথম অধ্যায়: উন্নততর জীবনধারা",
  "দ্বিতীয় অধ্যায়: জীবনের জন্য পানি",
  "তৃতীয় অধ্যায়: হৃদযন্ত্রের যত কথা",
  "চতুর্থ অধ্যায়: নবজীবনের সূচনা",
  "পঞ্চম অধ্যায়: দেখতে হলে আলো চাই",
  "ষষ্ঠ অধ্যায়: পলিমার",
  "সপ্তম অধ্যায়: অম্ল, ক্ষারক ও লবণের ব্যবহার",
  "অষ্টম অধ্যায়: আমাদের সম্পদ",
  "নবম অধ্যায়: দুর্যোগের সাথে বসবাস"
 ],
 "agriculture": [
  "প্রথম অধ্যায়: কৃষি প্রযুক্তি",
  "দ্বিতীয় অধ্যায়: কৃষি উপকরণ",
  "তৃতীয় অধ্যায়: কৃষি ও জলবায়ু",
  "চতুর্থ অধ্যায়: কৃষিজ উৎপাদন",
  "পঞ্চম অধ্যায়: বনায়ন",
  "ষষ্ঠ অধ্যায়: কৃষি সমবায়"
 ],
 "business_ent": [
  "প্রথম অধ্যায়: ব্যবসায় পরিচিতি",
  "দ্বিতীয় অধ্যায়: ব্যবসায় উদ্যোগ ও উদ্যোক্তা",
  "তৃতীয় অধ্যায়: আত্মকর্মসংস্থান",
  "চতুর্থ অধ্যায়: মালিকানার ভিত্তিতে ব্যবসায়",
  "পঞ্চম অধ্যায়: ব্যবসায়ের আইনগত দিক",
  "ষষ্ঠ অধ্যায়: ব্যবসায় পরিকল্পনা",
  "সপ্তম অধ্যায়: বাংলাদেশের শিল্প",
  "অষ্টম অধ্যায়: ব্যবসায় প্রতিষ্ঠানের ব্যবস্থাপনা",
  "নবম অধ্যায়: বিপণন",
  "দশম অধ্যায়: ব্যবসায় উদ্যোগ উন্নয়নে সহায়ক সেবা",
  "একাদশ অধ্যায়: ব্যবসায় নৈতিকতা ও সামাজিক দায়িত্ব",
  "দ্বাদশ অধ্যায়: সফল উদ্যোক্তাদের জীবনী থেকে শিক্ষণীয়"
 ],
 "accounting": [
  "প্রথম অধ্যায়: হিসাববিজ্ঞান পরিচিতি",
  "দ্বিতীয় অধ্যায়: লেনদেন",
  "তৃতীয় অধ্যায়: দুতরফা দাখিলা পদ্ধতি",
  "চতুর্থ অধ্যায়: মূলধন ও মুনাফা জাতীয় লেনদেন",
  "পঞ্চম অধ্যায়: হিসাব",
  "ষষ্ঠ অধ্যায়: জাবেদা",
  "সপ্তম অধ্যায়: খতিয়ান",
  "অষ্টম অধ্যায়: নগদান বই",
  "নবম অধ্যায়: রেওয়ামিল",
  "দশম অধ্যায়: আর্থিক বিবরণী",
  "একাদশ অধ্যায়: পণ্যের ক্রয়মূল্য, উৎপাদন ব্যয় ও বিক্রয়মূল্য"
 ],
 "finance": [
  "প্রথম অধ্যায়: অর্থায়ন ও ব্যবসায় অর্থায়ন",
  "দ্বিতীয় অধ্যায়: অর্থায়নের উৎস",
  "তৃতীয় অধ্যায়: শেয়ার, বন্ড ও ডিবেঞ্চার",
  "চতুর্থ অধ্যায়: অর্থের সময়মূল্য",
  "পঞ্চম অধ্যায়: ঝুঁকি ও অনিশ্চয়তা",
  "ষষ্ঠ অধ্যায়: মূলধনি আয়-ব্যয় প্রাক্কলন",
  "সপ্তম অধ্যায়: মূলধন ব্যয়",
  "অষ্টম অধ্যায়: মুদ্রা, ব্যাংক ও ব্যাংকিং",
  "নবম অধ্যায়: ব্যাংকিং ব্যবসায় ও তার ধরন",
  "দশম অধ্যায়: বাণিজ্যিক ব্যাংক",
  "একাদশ অধ্যায়: ব্যাংকের আমানত",
  "দ্বাদশ অধ্যায়: ব্যাংক ও গ্রাহক"
 ],
 "ict": [
  "অধ্যায় ১: তথ্য ও যোগাযোগ প্রযুক্তি ও আমাদের বাংলাদেশ",
  "অধ্যায় ২: কম্পিউটার রক্ষণাবেক্ষণ ও সাইবার নিরাপত্তা",
  "অধ্যায় ৩: ইন্টারনেট ও ওয়েব পরিচিতি",
  "অধ্যায় ৪: আমার লেখালেখি ও হিসাব",
  "অধ্যায় ৫: মাল্টিমিডিয়া ও গ্রাফিক্স",
  "অধ্যায় ৬: প্রোগ্রামিংয়ের মাধ্যমে সমস্যার সমাধান"
 ],
 "physical_edu": [
  "প্রথম অধ্যায়: সুস্থ জীবনের জন্য শারীরিক শিক্ষা",
  "দ্বিতীয় অধ্যায়: শারীরিক সক্ষমতা",
  "তৃতীয় অধ্যায়: মানসিক স্বাস্থ্য ও অবসাদ",
  "চতুর্থ অধ্যায়: স্বাস্থ্যবিজ্ঞান ও স্বাস্থ্যসেবা",
  "পঞ্চম অধ্যায়: স্বাস্থ্যের জন্য পুষ্টি",
  "ষষ্ঠ অধ্যায়: মাদকাসক্তি ও এইডস",
  "সপ্তম অধ্যায়: বয়ঃসন্ধিকাল ও প্রজনন স্বাস্থ্য",
  "অষ্টম অধ্যায়: দলগত খেলা",
  "নবম অধ্যায়: অ্যাথলেটিকস ও সাঁতার",
  "দশম অধ্যায়: খেলাধুলার দুর্ঘটনা"
 ],
 "career": [
  "প্রথম অধ্যায়: আমি ও আমার ক্যারিয়ার",
  "দ্বিতীয় অধ্যায়: ক্যারিয়ার গঠন: গুণ ও দক্ষতা",
  "তৃতীয় অধ্যায়: ক্যারিয়ার গঠনে সংযোগ স্থাপন ও আচরণ",
  "চতুর্থ অধ্যায়: আমি ও আমার কর্মক্ষেত্র"
 ],
 "history": [],
 "civics": []
};

let TOKEN = localStorage.getItem('sb_token') || '';
let REFRESH = localStorage.getItem('sb_refresh') || '';
let USER_ID = localStorage.getItem('sb_uid') || '';
let FIGURE = null;
let BATCH = [];
let RAW_BATCH = [];
let IMAGES = [];

// ── helpers ───────────────────────────────────────────────────────────
function escapeHtml(s){
  return String(s).replace(/[&<>"']/g, c =>
    ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
}

function showMsg(kind, text, items){
  const m = $('msg');
  m.className = 'msg ' + kind;
  m.innerHTML = text + (items && items.length
    ? '<ul>' + items.map(i => `<li>${escapeHtml(i)}</li>`).join('') + '</ul>' : '');
  m.scrollIntoView({ block: 'nearest', behavior: 'smooth' });
}

/** Every REST call to Supabase goes through here. */
/** Swaps the stored refresh token for a fresh access token.
 *  Supabase access tokens last about an hour, so without this every session
 *  died with "JWT expired" and had to be signed in again by hand. */
async function renewToken(){
  if (!REFRESH) return false;
  const r = await fetch(SUPABASE_URL + '/auth/v1/token?grant_type=refresh_token', {
    method: 'POST',
    headers: { apikey: SUPABASE_ANON, 'Content-Type': 'application/json' },
    body: JSON.stringify({ refresh_token: REFRESH }),
  });
  if (!r.ok) return false;
  const d = await r.json().catch(() => null);
  if (!d || !d.access_token) return false;
  TOKEN = d.access_token;
  REFRESH = d.refresh_token || REFRESH;
  localStorage.setItem('sb_token', TOKEN);
  localStorage.setItem('sb_refresh', REFRESH);
  return true;
}

async function sbOnce(path, opts){
  const r = await fetch(SUPABASE_URL + path, {
    ...opts,
    headers: {
      apikey: SUPABASE_ANON,
      Authorization: 'Bearer ' + (TOKEN || SUPABASE_ANON),
      'Content-Type': 'application/json',
      ...(opts.headers || {}),
    },
  });
  const text = await r.text();
  let data = null;
  try { data = text ? JSON.parse(text) : null; } catch (_) { data = text; }
  return { ok: r.ok, status: r.status, data };
}

async function sb(path, opts = {}){
  let res = await sbOnce(path, opts);

  // An expired token is recoverable: renew and replay the call once, so the
  // work is not lost and no re-login is needed.
  const msg0 = res.data && (res.data.message || res.data.error_description || res.data.msg);
  if (!res.ok && (res.status === 401 || /jwt expired|invalid jwt/i.test(String(msg0 || '')))){
    if (await renewToken()) res = await sbOnce(path, opts);
  }

  if (!res.ok){
    const d = res.data;
    let msg = (d && (d.message || d.error_description || d.error || d.msg))
            || ('HTTP ' + res.status);
    if (/jwt expired|invalid jwt/i.test(msg) || res.status === 401){
      msg = 'Your session expired and could not be renewed. Sign in again.';
    }
    throw new Error(msg);
  }
  return res.data;
}

// ── auth ──────────────────────────────────────────────────────────────
$('signin').onclick = async () => {
  const email = $('email').value.trim();
  const password = $('pass').value;
  if (!email || !password){
    $('loginMsg').className = 'msg err';
    $('loginMsg').textContent = 'Enter your email and password.';
    return;
  }
  $('signin').disabled = true;
  $('loginBusy').textContent = 'Signing in…';
  try {
    const d = await sb('/auth/v1/token?grant_type=password', {
      method: 'POST',
      body: JSON.stringify({ email, password }),
    });
    TOKEN = d.access_token;
    USER_ID = d.user && d.user.id;
    REFRESH = d.refresh_token || '';
    localStorage.setItem('sb_token', TOKEN);
    localStorage.setItem('sb_refresh', REFRESH);
    localStorage.setItem('sb_uid', USER_ID);
    enterApp();
  } catch (e) {
    $('loginMsg').className = 'msg err';
    $('loginMsg').textContent = String(e.message || e);
  } finally {
    $('signin').disabled = false;
    $('loginBusy').textContent = '';
  }
};

$('signout').onclick = () => {
  TOKEN = ''; REFRESH = ''; USER_ID = '';
  localStorage.removeItem('sb_token');
  localStorage.removeItem('sb_refresh');
  localStorage.removeItem('sb_uid');
  location.reload();
};

const PANEL_BUILD = 'chapters-all';

async function enterApp(){
  $('login').classList.add('hide');
  $('app').classList.remove('hide');
  // Visible build marker: if this is missing, the browser is running a
  // cached copy of app.js and the deploy has not taken effect.
  const h = document.querySelector('header p');
  if (h) h.textContent += `  ·  build ${PANEL_BUILD}`;
  buildSubjects();
  syncChapters();
  syncTypes();
  renderOptions();
  await loadList();
}

// ── form plumbing ─────────────────────────────────────────────────────
function buildSubjects(){
  for (const [id, name] of Object.entries(SUBJECTS)){
    const o = document.createElement('option');
    o.value = id; o.textContent = name;
    $('subject').appendChild(o);
    const o2 = o.cloneNode(true);
    $('f-subject').appendChild(o2);
  }
}

function renderOptions(n = 4){
  const box = $('options');
  box.innerHTML = '';
  const letters = ['ক','খ','গ','ঘ','ঙ','চ'];
  for (let i = 0; i < n; i++){
    const row = document.createElement('div');
    row.className = 'opt';
    row.innerHTML =
      `<input type="radio" name="correct" value="${i}" ${i === 0 ? 'checked' : ''}>`
      + `<span class="tag">${letters[i]}</span>`
      + `<input type="text" class="opt-text" placeholder="Option ${letters[i]}">`;
    box.appendChild(row);
  }
}

/** Fills the chapter dropdown for the chosen subject. */
const NEW_CHAPTER = '__new__';

function syncChapters(){
  const list = CHAPTERS[$('subject').value] || [];
  const sel = $('chapter');
  const keep = sel.value;
  // Always offer "+ new chapter": a subject with no questions yet has no
  // chapters to list, and every subject can gain one later.
  sel.innerHTML =
    list.map(c => `<option value="${c.replace(/"/g, '&quot;')}">${c}</option>`).join('')
    + `<option value="${NEW_CHAPTER}">+ new chapter…</option>`;
  sel.value = list.includes(keep) ? keep : (list[0] || NEW_CHAPTER);
  syncNewChapter();
}

/** Shows the free-text box only when "+ new chapter" is selected. */
function syncNewChapter(){
  const isNew = $('chapter').value === NEW_CHAPTER;
  $('chapterNew').classList.toggle('hide', !isNew);
  if (!isNew) $('chapterNew').value = '';
}

/** The chapter to publish with: either the picked one or the typed one. */
function currentChapter(){
  const v = $('chapter').value;
  return (v === NEW_CHAPTER ? $('chapterNew').value : v).trim();
}

function syncTypes(){
  const t = $('type');
  if (!t.options.length){
    for (const [v, label] of [['mcq','MCQ (বহুনির্বাচনি)'],['saq','SAQ (সংক্ষিপ্ত)'],['cq','CQ (সৃজনশীল)']]){
      const o = document.createElement('option');
      o.value = v; o.textContent = label;
      t.appendChild(o);
    }
  }
  syncFields();
}

function syncFields(){
  const t = $('type').value;
  $('f-question').classList.toggle('hide', t === 'cq');
  $('f-mcq').classList.toggle('hide', t !== 'mcq');
  $('f-saq').classList.toggle('hide', t !== 'saq');
  $('f-cq').classList.toggle('hide', t !== 'cq');
  $('f-expl').classList.toggle('hide', t === 'cq');
}

function clearForm(){
  $('questionText').value = '';
  $('answer').value = '';
  $('explanation').value = '';
  $('stem').value = '';
  for (const k of ['questionK','questionKh','questionG','questionGh']) $(k).value = '';
  renderOptions();
  $('figClear').click();
}

// ── images ────────────────────────────────────────────────────────────
/** Grayscale + contrast stretch, then trim uniform margins. */
function processImage(img, { mono = true, trim = true } = {}){
  const MAX = 1400;
  let w = img.naturalWidth, h = img.naturalHeight;
  if (Math.max(w, h) > MAX){ const k = MAX / Math.max(w, h); w = Math.round(w*k); h = Math.round(h*k); }
  const c = document.createElement('canvas');
  c.width = w; c.height = h;
  const g = c.getContext('2d');
  g.fillStyle = '#fff'; g.fillRect(0, 0, w, h);
  g.drawImage(img, 0, 0, w, h);

  if (mono){
    const d = g.getImageData(0, 0, w, h), p = d.data;
    // Not a 1-bit threshold: that destroys thin lines and Bengali matras.
    for (let i = 0; i < p.length; i += 4){
      const v = 0.299*p[i] + 0.587*p[i+1] + 0.114*p[i+2];
      let o = (v - 128) * 1.45 + 128;
      o = o < 0 ? 0 : o > 255 ? 255 : o;
      if (o > 224) o = 255;
      if (o < 42)  o = 0;
      p[i] = p[i+1] = p[i+2] = o; p[i+3] = 255;
    }
    g.putImageData(d, 0, 0);
  }
  if (!trim) return c;

  const q = g.getImageData(0, 0, w, h).data;
  const LIGHT = 232;
  let top = 0, bot = h - 1, left = 0, right = w - 1;
  const rowBlank = (y) => { for (let x = 0; x < w; x++) if (q[(y*w+x)*4] < LIGHT) return false; return true; };
  const colBlank = (x) => { for (let y = 0; y < h; y++) if (q[(y*w+x)*4] < LIGHT) return false; return true; };
  while (top < bot && rowBlank(top)) top++;
  while (bot > top && rowBlank(bot)) bot--;
  while (left < right && colBlank(left)) left++;
  while (right > left && colBlank(right)) right--;
  const pad = 12;
  top = Math.max(0, top - pad); left = Math.max(0, left - pad);
  bot = Math.min(h - 1, bot + pad); right = Math.min(w - 1, right + pad);
  const cw = right - left + 1, ch = bot - top + 1;
  if (cw < 40 || ch < 40 || (cw === w && ch === h)) return c;
  const c2 = document.createElement('canvas');
  c2.width = cw; c2.height = ch;
  c2.getContext('2d').drawImage(c, left, top, cw, ch, 0, 0, cw, ch);
  return c2;
}

/** Uploads to Supabase Storage and returns a public URL. */
async function uploadCanvas(c, name){
  const blob = await new Promise(r => c.toBlob(r, 'image/png'));
  const safe = name.toLowerCase().replace(/[^a-z0-9._-]+/g, '_').replace(/\.[^.]+$/, '');
  const file = `${safe}-${Date.now()}.png`;
  const put = () => fetch(`${SUPABASE_URL}/storage/v1/object/${BUCKET}/${file}`, {
    method: 'POST',
    headers: {
      apikey: SUPABASE_ANON,
      Authorization: 'Bearer ' + TOKEN,
      'Content-Type': 'image/png',
    },
    body: blob,
  });
  let r = await put();
  // Uploads bypass sb(), so they need the same expired-token recovery.
  if (r.status === 401 && await renewToken()) r = await put();
  if (!r.ok){
    const body = await r.text();
    // A storage select policy does not grant insert; without the write policy
    // Supabase returns 403 "new row violates row-level security policy".
    if (/row-level security|Unauthorized|403/i.test(body)) {
      throw new Error(
        'Image uploads are not permitted for this account yet. Re-run '
        + 'schema.sql in the Supabase SQL editor — it now adds the storage '
        + 'write policy — then sign out and back in.'
      );
    }
    throw new Error('Image upload failed: ' + body.slice(0, 160));
  }
  return {
    imagePath: `${SUPABASE_URL}/storage/v1/object/public/${BUCKET}/${file}`,
    aspect: Number((c.width / c.height).toFixed(4)),
    width: c.width, height: c.height,
  };
}

$('figFile').onchange = async () => {
  const f = $('figFile').files[0];
  if (!f) return;
  $('saving').textContent = 'Processing…';
  try {
    const img = new Image();
    img.src = URL.createObjectURL(f);
    await img.decode();
    const c = processImage(img, { mono: $('figMono').checked, trim: $('figTrim').checked });
    FIGURE = await uploadCanvas(c, f.name);
    $('figPreview').src = FIGURE.imagePath;
    $('figInfo').textContent = `${FIGURE.width}x${FIGURE.height}px`;
    $('figPreviewWrap').classList.remove('hide');
  } catch (e) {
    showMsg('err', '<b>Could not upload:</b>', [String(e.message || e)]);
  } finally {
    $('saving').textContent = '';
  }
};

$('figClear').onclick = () => {
  FIGURE = null;
  $('figFile').value = '';
  $('figCaption').value = '';
  $('figPreviewWrap').classList.add('hide');
};

// ── publishing ────────────────────────────────────────────────────────
let idSeq = 0;

function nextId(subjectId, type, chapter){
  const prefix = ID_PREFIX[subjectId] || subjectId.slice(0, 3);
  const m = /([০-৯0-9]+)/.exec(chapter || '');
  const bn = { '০':0,'১':1,'২':2,'৩':3,'৪':4,'৫':5,'৬':6,'৭':7,'৮':8,'৯':9 };
  let n = 0;
  if (m){ for (const ch of m[1]) n = n * 10 + (bn[ch] ?? Number(ch)); }
  const cc = n ? String(n).padStart(2, '0') : 'x';
  // Date.now() alone is not enough: a batch builds every row inside the same
  // millisecond, so all of them got the identical id and the insert failed
  // with "duplicate key value violates unique constraint questions_pkey".
  // A per-call counter plus randomness makes collisions effectively
  // impossible, both within a batch and across two devices publishing at once.
  idSeq += 1;
  const stamp = Date.now().toString(36);
  const seq = idSeq.toString(36);
  const rand = Math.random().toString(36).slice(2, 7);
  return `${prefix}_web${cc}_${type}_${stamp}${seq}${rand}`;
}

function buildRow(q, common){
  const payload = {};
  if (q.type === 'mcq'){
    payload.questionText = q.questionText;
    payload.options = q.options;
    payload.correctIndex = q.correctIndex;
    if (q.explanation) payload.explanation = q.explanation;
  } else if (q.type === 'saq'){
    payload.questionText = q.questionText;
    payload.answer = q.answer;
    if (q.explanation) payload.explanation = q.explanation;
  } else {
    payload.stem = q.stem;
    payload.questionK = q.questionK;
    payload.questionKh = q.questionKh;
    payload.questionG = q.questionG;
    payload.questionGh = q.questionGh || '';
    payload.marks = q.marks && q.marks.length ? q.marks : (q.questionGh ? [1,2,3,4] : [2,4,4]);
  }
  const row = {
    id: nextId(common.subjectId, q.type, common.chapter),
    type: q.type,
    subject_id: common.subjectId,
    // Trimmed: a trailing space makes a near-duplicate chapter that the app
    // treats as a different one.
    chapter: String(common.chapter || '').trim(),
    payload,
    source: 'original',
    owner_id: null,          // official content, visible to every tutor
    is_active: true,
  };
  if (q.figure) row.figure = q.figure;
  return row;
}

function validate(q, common){
  const e = [];
  if (!common.subjectId) e.push('Choose a subject.');
  const chap = String(common.chapter || '').trim();
  if (!chap) e.push('Chapter is required.');
  else if (common.subjectId){
    const known = CHAPTERS[common.subjectId] || [];
    // A chapter typed via "+ new chapter" is deliberate, so only flag a
    // mismatch when the subject already has chapters and this is not one.
    const typedNew = $('chapter').value === NEW_CHAPTER;
    if (!typedNew && known.length && !known.includes(chap)){
      e.push(
        `"${chap}" is not a chapter of this subject. Pick one from the list, `
        + 'or the question will not appear under any chapter.'
      );
    }
  }
  if (JSON.stringify(q).includes('\uFFFD'))
    e.push('The text contains corrupted characters — re-paste it.');
  if (q.type === 'mcq'){
    if (!String(q.questionText || '').trim()) e.push('Question text is required.');
    const o = (q.options || []).map(x => String(x || '').trim()).filter(Boolean);
    if (o.length < 2) e.push('At least two options are required.');
    if (new Set(o).size !== o.length) e.push('Options must be distinct.');
    if (!Number.isInteger(q.correctIndex) || q.correctIndex < 0 || q.correctIndex >= o.length)
      e.push('Select which option is correct.');
  } else if (q.type === 'saq'){
    if (!String(q.questionText || '').trim()) e.push('Question text is required.');
    if (!String(q.answer || '').trim()) e.push('Answer is required.');
  } else {
    if (!String(q.stem || '').trim()) e.push('Stem is required.');
    if (!String(q.questionK || '').trim()) e.push('Question ক is required.');
  }
  return e;
}

async function publish(rows){
  // Last line of defence: guarantee the batch itself carries no repeated id
  // before it ever reaches Postgres.
  const seen = new Set();
  for (const r of rows){
    while (seen.has(r.id)){
      r.id = r.id + '-' + Math.random().toString(36).slice(2, 6);
    }
    seen.add(r.id);
  }
  try {
    return await sb('/rest/v1/questions', {
      method: 'POST',
      headers: { Prefer: 'return=representation' },
      body: JSON.stringify(rows),
    });
  } catch (e) {
    // Row-level security rejects a non-admin trying to publish official
    // content. The raw Postgres wording is opaque, so say what to do.
    const m = String(e.message || e);
    if (/duplicate key|questions_pkey|23505/i.test(m)) {
      throw new Error(
        'One of these questions already exists on the server. Reload the page '
        + 'and publish again — if it repeats, the same batch was already saved.'
      );
    }
    if (/row-level security|violates row-level|42501|permission denied/i.test(m)) {
      throw new Error(
        'This account is not on the publisher list, so it cannot add questions '
        + 'that every tutor sees. Run the "Make yourself an admin" block at the '
        + 'bottom of schema.sql with your email, then sign out and back in.'
      );
    }
    throw e;
  }
}

$('save').onclick = async () => {
  const type = $('type').value;
  const common = { subjectId: $('subject').value, chapter: currentChapter() };
  const q = { type };
  if (type === 'mcq'){
    q.questionText = $('questionText').value.trim();
    q.options = [...document.querySelectorAll('.opt-text')].map(i => i.value.trim());
    const picked = document.querySelector('input[name=correct]:checked');
    q.correctIndex = picked ? Number(picked.value) : -1;
    q.explanation = $('explanation').value.trim();
  } else if (type === 'saq'){
    q.questionText = $('questionText').value.trim();
    q.answer = $('answer').value.trim();
    q.explanation = $('explanation').value.trim();
  } else {
    q.stem = $('stem').value.trim();
    for (const k of ['questionK','questionKh','questionG','questionGh']) q[k] = $(k).value.trim();
    q.marks = $('marks').value.split(/[^0-9]+/).filter(Boolean).map(Number);
  }
  if (FIGURE){
    q.figure = { kind: 'image', imagePath: FIGURE.imagePath, aspect: FIGURE.aspect };
    const cap = $('figCaption').value.trim();
    if (cap) q.figure.caption = cap;
  }

  const errs = validate(q, common);
  if (errs.length){ showMsg('err', '<b>Could not publish:</b>', errs); return; }

  // Same-text check, so the one-at-a-time route cannot quietly re-add a
  // question that is already on the server.
  await loadServerPrints();
  const fp = fingerprint(q);
  if (fp && SERVER_PRINTS.has(fp)){
    showMsg('err', '<b>Already published:</b>', [
      `This question is already on the server as ${SERVER_PRINTS.get(fp)}.`,
    ]);
    return;
  }

  $('save').disabled = true;
  $('saving').textContent = 'Publishing…';
  try {
    const out = await publish([buildRow(q, common)]);
    showMsg('ok', `Published <b>${escapeHtml(out[0].id)}</b>. It reaches the app on next launch.`);
    clearForm();
    await loadList();
  } catch (e) {
    showMsg('err', '<b>Could not publish:</b>', [String(e.message || e)]);
  } finally {
    $('save').disabled = false;
    $('saving').textContent = '';
  }
};

$('clear').onclick = clearForm;

// ── Gemini ────────────────────────────────────────────────────────────
const GEMINI_MODELS = [
  'gemini-flash-latest', 'gemini-flash-lite-latest',
  'gemini-2.0-flash', 'gemini-2.0-flash-lite',
];
const sleep = (ms) => new Promise(r => setTimeout(r, ms));

function buildPrompt(type, raw){
  const shape = {
    mcq: '{"type":"mcq","questionText":"...","options":["..","..","..",".."],"correctIndex":0,"explanation":"..."}',
    saq: '{"type":"saq","questionText":"...","answer":"...","explanation":"..."}',
    cq:  '{"type":"cq","stem":"...","questionK":"...","questionKh":"...","questionG":"...","questionGh":"...","marks":[1,2,3,4]}',
  }[type];
  return [
    'You are formatting Bangla SSC exam questions for a database.',
    'The input is raw text pasted from a PDF and may be messy.',
    '',
    'Return ONLY a JSON array. No markdown, no commentary, no code fences.',
    'Each element must match exactly this shape:', shape, '',
    'Rules:',
    '- Split the input into as many separate questions as it contains.',
    '- Keep the Bangla text exactly as written; fix only spacing and line breaks.',
    '- Never invent questions, options or answers that are not in the input.',
    '- correctIndex is 0-based. If the answer is not marked, use 0.',
    '- If a cq has only three parts, leave questionGh empty and use marks [2,4,4].',
    '- If the input marks which chapter a question belongs to (a heading such',
    '  as "অধ্যায় ৩" or "Chapter 3" before a group), copy that heading text',
    '  into a "chapterHint" field on every question under it. Omit the field',
    '  when the input gives no such heading.',
    '- Strip the leading question number. "২৪। জবাগোষ্ঠীতে..." becomes',
    '  "জবাগোষ্ঠীতে...". The app adds its own numbering when it prints a paper,',
    '  so a number left in the text would appear twice.',
    '', 'INPUT:', raw,
  ].join('\n');
}

function extractArray(text){
  let t = String(text || '').replace(/^\s*```(?:json)?/i, '').replace(/```\s*$/, '').trim();
  const a = t.indexOf('['), b = t.lastIndexOf(']');
  if (a >= 0 && b > a) t = t.slice(a, b + 1);
  let p = JSON.parse(t);
  return Array.isArray(p) ? p : [p];
}

/** Removes a leading question number the model left in place.
 *  "২৪। প্রশ্ন" / "24. প্রশ্ন" / "(২৪) প্রশ্ন" -> "প্রশ্ন".
 *  The app prints its own Bengali numbering, so a number kept in the text
 *  shows up twice on the paper. Only a number followed by a real separator
 *  is stripped, so text that genuinely opens with a figure survives.
 */
function stripLeadingNumber(t){
  const v = String(t || '').trim();
  // A decimal like "0.5 T ..." must not lose its leading digit, so a dot only
  // counts as a separator when it is not followed by another digit.
  return v
    .replace(/^[\(\[]?\s*[০-৯0-9]{1,3}\s*[\)\]]?\s*(?:।|:|\)|-|\.(?![০-৯0-9]))\s*/, '')
    .trim();
}

function normalizeQuestion(raw, type){
  const q = { ...(raw || {}) };
  for (const k of ['payload','question','data','fields'])
    if (q[k] && typeof q[k] === 'object' && !Array.isArray(q[k])) Object.assign(q, q[k]);
  const pick = (...n) => { for (const x of n){ const v = q[x]; if (typeof v === 'string' && v.trim()) return v.trim(); } return ''; };
  const out = { type: q.type || type };
  // Carried through so a batch can span several chapters.
  const hint = pick('chapterHint','chapter','adhyay');
  if (hint) out.chapterHint = hint;

  if (out.type === 'cq'){
    out.stem = stripLeadingNumber(pick('stem','uddipok','passage','questionText','question','text'));
    out.questionK = pick('questionK','k','ka');
    out.questionKh = pick('questionKh','kh','kha');
    out.questionG = pick('questionG','g','ga');
    out.questionGh = pick('questionGh','gh','gha');
    let m = q.marks;
    if (typeof m === 'string') m = m.split(/[^0-9]+/).filter(Boolean).map(Number);
    out.marks = Array.isArray(m) && m.length ? m.map(Number) : (out.questionGh ? [1,2,3,4] : [2,4,4]);
    return out;
  }
  out.questionText = stripLeadingNumber(pick('questionText','question','text','stem','prompt'));
  if (out.type === 'saq'){
    out.answer = pick('answer','ans','correctAnswer','solution');
    const ex = pick('explanation','reason'); if (ex) out.explanation = ex;
    return out;
  }
  let opts = q.options || q.choices || q.answers;
  if (!Array.isArray(opts)){
    const found = [];
    for (const L of ['ক','খ','গ','ঘ','a','b','c','d','A','B','C','D']){
      for (const key of ['option'+L,'opt'+L,L])
        if (typeof q[key] === 'string' && q[key].trim()){ found.push(q[key].trim()); break; }
    }
    opts = found;
  }
  opts = (opts||[]).map(o => typeof o === 'string' ? o.trim()
      : String((o && (o.text ?? o.value ?? o.option ?? o.label)) ?? '').trim())
    .filter(Boolean)
    .map(o => o.replace(/^[\(\[]\s*[ক-ঘa-dA-D1-4]\s*[\)\]]\s*/, '')
                .replace(/^[ক-ঘa-dA-D1-4]\s*[\)\].:]\s+/, '').trim());
  out.options = opts;

  let ci = q.correctIndex ?? q.correct ?? q.answerIndex ?? q.answer;
  if (typeof ci === 'string'){
    const map = {'ক':0,'খ':1,'গ':2,'ঘ':3,'a':0,'b':1,'c':2,'d':3,'A':0,'B':1,'C':2,'D':3,'1':0,'2':1,'3':2,'4':3};
    const t = ci.trim();
    ci = (t in map) ? map[t] : Math.max(0, opts.indexOf(t));
  }
  ci = Number(ci);
  out.correctIndex = Number.isInteger(ci) && ci >= 0 && ci < opts.length ? ci : 0;
  const ex = pick('explanation','reason'); if (ex) out.explanation = ex;
  return out;
}

async function callGemini(model, key, prompt){
  const r = await fetch(
    `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${encodeURIComponent(key)}`,
    { method: 'POST', headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ contents: [{ parts: [{ text: prompt }] }],
                             generationConfig: { temperature: 0.1, maxOutputTokens: 8192 } }) });
  const d = await r.json().catch(() => ({}));
  if (!r.ok){
    const e = new Error((d.error && d.error.message) || ('HTTP ' + r.status));
    e.transient = [429, 500, 503].includes(r.status);
    throw e;
  }
  const c = (d.candidates || [])[0];
  const text = c && c.content ? (c.content.parts || []).map(p => p.text || '').join('') : '';
  if (!text.trim()) throw new Error('Gemini sent an empty reply — try a smaller batch.');
  return extractArray(text);
}

$('apiKey').value = localStorage.getItem('gemKey') || '';
$('apiKey').onchange = () => localStorage.setItem('gemKey', $('apiKey').value.trim());

$('testKey').onclick = async () => {
  const key = $('apiKey').value.trim();
  if (!key){ showMsg('err', '<b>Paste your API key first.</b>'); return; }
  try {
    const r = await fetch('https://generativelanguage.googleapis.com/v1beta/models?key=' + encodeURIComponent(key));
    const d = await r.json().catch(() => ({}));
    if (r.ok) showMsg('ok', `<b>Connected.</b> ${(d.models || []).length} models available.`);
    else showMsg('err', '<b>Google rejected the key:</b>', [(d.error && d.error.message) || ('HTTP ' + r.status)]);
  } catch (e) {
    showMsg('err', '<b>Could not reach Google.</b>', [String(e.message || e)]);
  }
};

$('formatBtn').onclick = async () => {
  const type = $('type').value;
  const key = $('apiKey').value.trim();
  const raw = $('rawText').value.trim();
  if (!key){ showMsg('err', '<b>Add your Gemini API key first.</b>'); return; }
  if (!raw){ showMsg('err', '<b>Paste some question text first.</b>'); return; }

  $('formatBtn').disabled = true;
  $('fmtStatus').textContent = 'Checking what is already published…';
  await loadServerPrints();
  $('fmtStatus').textContent = 'Asking Gemini…';
  const prompt = buildPrompt(type, raw);
  let last = null;
  try {
    for (const model of GEMINI_MODELS){
      for (let attempt = 0; attempt < 2; attempt++){
        try {
          $('fmtStatus').textContent = `Asking ${model}…`;
          RAW_BATCH = await callGemini(model, key, prompt);
          BATCH = RAW_BATCH.map(q => normalizeQuestion(q, type));
          renderBatch();
          showMsg('ok', `Found <b>${BATCH.length}</b> question(s). Check them, then Publish all.`);
          return;
        } catch (e) {
          last = e;
          if (!e.transient) throw e;
          if (attempt === 0) await sleep(1200);
        }
      }
    }
    throw new Error('All Gemini models are busy (' + (last && last.message) + ').');
  } catch (e) {
    showMsg('err', '<b>Could not format:</b>', [String(e.message || e)]);
  } finally {
    $('formatBtn').disabled = false;
    $('fmtStatus').textContent = '';
  }
};

/** Normalised fingerprint of a question's text, used to spot duplicates.
 *
 *  Ignores the things that differ between two copies of the same question
 *  without changing its meaning: leading numbers, whitespace, punctuation
 *  and the Bengali/Latin digit split. Two questions with the same
 *  fingerprint are treated as the same question.
 */
function fingerprint(q){
  const bn = {'০':'0','১':'1','২':'2','৩':'3','৪':'4','৫':'5','৬':'6','৭':'7','৮':'8','৯':'9'};
  let t = stripLeadingNumber(q.questionText || q.stem || '');
  t = t.replace(/[০-৯]/g, c => bn[c]);
  // Drop punctuation and collapse whitespace so spacing differences do not
  // hide a duplicate.
  t = t.replace(/[।?.,;:!()\[\]{}'"“”‘’\-–—\/\\]/g, ' ')
       .replace(/\s+/g, ' ')
       .trim()
       .toLowerCase();
  return t;
}

/** Questions already on the server, as fingerprint -> id. */
let SERVER_PRINTS = new Map();

/** Loads fingerprints of everything published for the chosen subject, so a
 *  re-paste can be spotted before it is written. */
async function loadServerPrints(){
  SERVER_PRINTS = new Map();
  const subject = $('subject').value;
  if (!subject) return;
  try {
    const rows = await sb('/rest/v1/questions?select=id,payload,type'
      + '&subject_id=eq.' + encodeURIComponent(subject) + '&limit=5000');
    for (const r of rows || []){
      const p = r.payload || {};
      const fp = fingerprint({ questionText: p.questionText, stem: p.stem });
      if (fp) SERVER_PRINTS.set(fp, r.id);
    }
  } catch (_) {
    // Detection is a convenience; never block publishing because of it.
  }
}

/** Best-guess chapter for a question, from any hint the model returned. */
function guessChapter(hint, subjectId){
  const list = CHAPTERS[subjectId] || [];
  if (!hint) return '';
  const h = String(hint).trim();
  if (list.includes(h)) return h;
  // Match on the chapter number, so "অধ্যায় ৩" finds "অধ্যায় ৩: কোষ বিভাজন".
  const bn = {'০':0,'১':1,'২':2,'৩':3,'৪':4,'৫':5,'৬':6,'৭':7,'৮':8,'৯':9};
  const num = (t) => {
    const m = /([০-৯0-9]+)/.exec(t || '');
    if (!m) return null;
    let n = 0;
    for (const c of m[1]) n = n * 10 + (bn[c] ?? Number(c));
    return n;
  };
  const want = num(h);
  if (want == null) return '';
  return list.find(c => num(c) === want) || '';
}

function renderBatch(){
  const subject = $('subject').value;
  const list = CHAPTERS[subject] || [];
  const fallback = currentChapter();

  // Flag anything already on the server, or repeated inside this paste.
  const seenHere = new Map();
  for (let i = 0; i < BATCH.length; i++){
    const fp = fingerprint(BATCH[i]);
    BATCH[i]._dupOf = null;
    BATCH[i]._dupHere = false;
    if (!fp) continue;
    if (SERVER_PRINTS.has(fp)) BATCH[i]._dupOf = SERVER_PRINTS.get(fp);
    else if (seenHere.has(fp)) BATCH[i]._dupHere = true;
    else seenHere.set(fp, i);
    // Default: skip a duplicate, keep everything else.
    if (BATCH[i]._skip === undefined) {
      BATCH[i]._skip = !!(BATCH[i]._dupOf || BATCH[i]._dupHere);
    }
  }

  $('batchList').innerHTML = BATCH.map((q, i) => {
    const t = escapeHtml(q.questionText || q.stem || '');
    let sub = '';
    if (q.options && q.options.length)
      sub = q.options.map((o, n) => `${n === q.correctIndex ? '<b>&#10003; </b>' : ''}${escapeHtml(o)}`).join(' &bull; ');
    else if (q.answer) sub = escapeHtml(q.answer);
    else if (q.questionK){
      const L = ['ক','খ','গ','ঘ'];
      sub = [q.questionK,q.questionKh,q.questionG,q.questionGh]
        .map((x, n) => x ? `${L[n]}) ${escapeHtml(x)}` : '').filter(Boolean).join('<br>');
    }

    // Per-question chapter, so one paste can cover several chapters.
    const chosen = q.chapter || guessChapter(q.chapterHint, subject) || fallback;
    q.chapter = chosen;
    const opts = list.map(c =>
      `<option value="${c.replace(/"/g,'&quot;')}"${c === chosen ? ' selected' : ''}>${c}</option>`).join('');

    const body = (!t && !sub)
      ? `<div class="o" style="color:var(--danger)">Could not read this one:</div>
         <pre style="font-size:11px;white-space:pre-wrap">${escapeHtml(JSON.stringify(RAW_BATCH[i] ?? q)).slice(0,600)}</pre>`
      : `<div class="t"><b>${i+1}.</b> ${t}</div><div class="o">${sub}</div>`;

    const dup = q._dupOf
      ? `<span class="new" style="background:#FFF1DC;color:#8A5200">ALREADY PUBLISHED</span>`
      : (q._dupHere
        ? `<span class="new" style="background:#FFF1DC;color:#8A5200">REPEATED IN THIS PASTE</span>`
        : '');
    const skipBox = dup
      ? `<label class="opt" style="margin-top:8px;font-size:12px">
           <input type="checkbox" class="q-skip" data-i="${i}" ${q._skip ? 'checked' : ''}
                  style="width:auto;flex:none">
           <span style="color:var(--muted)">Skip this one</span>
         </label>`
      : '';
    return `<div class="qprev"${q._skip ? ' style="opacity:.55"' : ''}>
      ${dup}${body}
      <select class="q-chap" data-i="${i}" style="margin-top:8px;font-size:12px;padding:6px 8px">${opts}</select>
      ${skipBox}
    </div>`;
  }).join('');

  for (const sel of document.querySelectorAll('.q-chap')){
    sel.onchange = () => { BATCH[Number(sel.dataset.i)].chapter = sel.value; };
  }
  for (const box of document.querySelectorAll('.q-skip')){
    box.onchange = () => {
      BATCH[Number(box.dataset.i)]._skip = box.checked;
      renderBatch();
    };
  }
  const dups = BATCH.filter(q => q._dupOf || q._dupHere).length;
  const skipping = BATCH.filter(q => q._skip).length;
  $('fmtStatus').textContent = dups
    ? `${dups} duplicate(s) found, ${skipping} will be skipped`
    : '';
  $('batchOut').classList.remove('hide');
}

$('batchCancel').onclick = () => { BATCH = []; $('batchOut').classList.add('hide'); };

$('batchSave').onclick = async () => {
  const subjectId = $('subject').value;
  const rows = [], bad = [];
  let skipped = 0;
  BATCH.forEach((q, i) => {
    if (q._skip){ skipped += 1; return; }
    // Each question carries the chapter chosen on its own row.
    const common = { subjectId, chapter: (q.chapter || currentChapter()).trim() };
    const e = validate(q, common);
    if (e.length) bad.push(`#${i+1} ${e[0]}`);
    else rows.push(buildRow(q, common));
  });
  if (!rows.length){
    if (skipped && !bad.length){
      showMsg('ok', `All ${skipped} question(s) were already published — nothing new to add.`);
      BATCH = []; $('batchOut').classList.add('hide'); $('rawText').value = '';
      return;
    }
    showMsg('err', '<b>Nothing valid to publish:</b>', bad); return;
  }

  $('batchSave').disabled = true;
  $('fmtStatus').textContent = 'Publishing…';
  try {
    const out = await publish(rows);
    let m = `Published <b>${out.length}</b> question(s).`;
    if (skipped) m += `<br>${skipped} duplicate(s) skipped.`;
    if (bad.length) m += `<br>${bad.length} rejected: ${bad.map(escapeHtml).join('; ')}`;
    showMsg('ok', m);
    BATCH = []; $('batchOut').classList.add('hide'); $('rawText').value = '';
    await loadServerPrints();
    await loadList();
  } catch (e) {
    showMsg('err', '<b>Could not publish:</b>', [String(e.message || e)]);
  } finally {
    $('batchSave').disabled = false;
    $('fmtStatus').textContent = '';
  }
};

// ── batch images ──────────────────────────────────────────────────────
$('imgFiles').onchange = async () => {
  const files = [...$('imgFiles').files];
  if (!files.length) return;
  IMAGES = []; $('imgGrid').innerHTML = '';
  $('imgBar').classList.remove('hide');
  const bar = $('imgBar').firstElementChild;
  for (let i = 0; i < files.length; i++){
    $('imgStatus').textContent = `Processing ${i+1} of ${files.length}…`;
    bar.style.width = ((i / files.length) * 100) + '%';
    try {
      const img = new Image();
      img.src = URL.createObjectURL(files[i]);
      await img.decode();
      const c = processImage(img, { mono: $('imgMono').checked, trim: $('imgTrim').checked });
      const up = await uploadCanvas(c, files[i].name);
      IMAGES.push(up);
      // Each image gets its own question box, so a batch can carry different
      // wording per picture instead of one line repeated across all of them.
      $('imgGrid').insertAdjacentHTML('beforeend',
        `<div class="thumb">
           <img src="${up.imagePath}">
           <div class="nm">${up.width}x${up.height}</div>
           <textarea class="img-q" data-img="${IMAGES.length - 1}" rows="2"
             style="margin-top:6px;font-size:12px;min-height:44px"
             placeholder="Question for this image (optional)"></textarea>
         </div>`);
    } catch (e) {
      showMsg('err', `<b>${escapeHtml(files[i].name)} failed:</b>`, [String(e.message || e)]);
    }
  }
  bar.style.width = '100%';
  $('imgStatus').textContent = `${IMAGES.length} ready`;
  $('imgSave').disabled = IMAGES.length === 0;
};

$('imgClear').onclick = () => {
  IMAGES = []; $('imgFiles').value = ''; $('imgGrid').innerHTML = '';
  $('imgBar').classList.add('hide'); $('imgSave').disabled = true; $('imgStatus').textContent = '';
};

$('imgSave').onclick = async () => {
  const common = { subjectId: $('subject').value, chapter: currentChapter() };
  const type = $('type').value;
  const stem = $('imgText').value.trim() || 'চিত্রটি লক্ষ কর।';
  // Per-image text when given, otherwise the shared default.
  const perImage = {};
  for (const box of document.querySelectorAll('.img-q')){
    const v = box.value.trim();
    if (v) perImage[box.dataset.img] = v;
  }
  const rows = IMAGES.map((im, i) => {
    const text = perImage[String(i)] || stem;
    const q = { type, figure: { kind: 'image', imagePath: im.imagePath, aspect: im.aspect } };
    if (type === 'mcq'){ q.questionText = text; q.options = ['ক','খ','গ','ঘ']; q.correctIndex = 0; }
    else if (type === 'saq'){ q.questionText = text; q.answer = 'উত্তর ছবিতে দেওয়া আছে।'; }
    else { q.stem = text; q.questionK = 'ক'; q.questionKh = 'খ'; q.questionG = 'গ'; q.questionGh = 'ঘ'; q.marks = [1,2,3,4]; }
    return buildRow(q, common);
  });
  if (!common.chapter){ showMsg('err', '<b>Chapter is required.</b>'); return; }

  $('imgSave').disabled = true;
  $('imgStatus').textContent = 'Publishing…';
  try {
    const out = await publish(rows);
    showMsg('ok', `Published <b>${out.length}</b> image question(s).`);
    $('imgClear').click();
    await loadList();
  } catch (e) {
    showMsg('err', '<b>Could not publish:</b>', [String(e.message || e)]);
  } finally {
    $('imgSave').disabled = false;
    $('imgStatus').textContent = '';
  }
};

// ── published list ────────────────────────────────────────────────────
async function loadList(){
  const p = new URLSearchParams();
  p.set('select', 'id,type,subject_id,chapter,payload,updated_at');
  p.set('order', 'updated_at.desc');
  p.set('limit', '50');
  if ($('f-subject').value) p.set('subject_id', 'eq.' + $('f-subject').value);
  if ($('f-type').value) p.set('type', 'eq.' + $('f-type').value);
  const q = $('f-search').value.trim();
  if (q) p.set('or', `(id.ilike.*${q}*,payload->>questionText.ilike.*${q}*)`);

  try {
    const rows = await sb('/rest/v1/questions?' + p.toString(), {
      headers: { Prefer: 'count=exact' },
    });
    $('s-total').textContent = rows.length >= 50 ? '50+' : String(rows.length);
    $('s-shown').textContent = String(rows.length);
    $('list').innerHTML = rows.map(r => {
      const text = (r.payload && (r.payload.questionText || r.payload.stem)) || '';
      return `<div class="q">
        <div class="meta">
          <span class="pill ${r.type}">${r.type}</span>
          <span class="id">${escapeHtml(r.id)}</span>
          <span style="flex:1"></span>
          <button class="danger" data-del="${escapeHtml(r.id)}">delete</button>
        </div>
        <div class="text">${escapeHtml(text).slice(0, 200)}</div>
        <div class="id" style="margin-top:4px">${escapeHtml(r.chapter || '')}</div>
      </div>`;
    }).join('') || '<p class="hint">Nothing published yet.</p>';

    for (const b of document.querySelectorAll('[data-del]')){
      b.onclick = async () => {
        if (!confirm('Delete ' + b.dataset.del + '?')) return;
        try {
          await sb('/rest/v1/questions?id=eq.' + encodeURIComponent(b.dataset.del), { method: 'DELETE' });
          await loadList();
        } catch (e) { showMsg('err', '<b>Delete failed:</b>', [String(e.message || e)]); }
      };
    }
  } catch (e) {
    $('list').innerHTML = `<p class="hint" style="color:var(--danger)">${escapeHtml(String(e.message || e))}</p>`;
  }
}

// ── init ──────────────────────────────────────────────────────────────
for (const b of document.querySelectorAll('.tab')){
  b.onclick = () => {
    for (const x of document.querySelectorAll('.tab')) x.classList.toggle('on', x === b);
    for (const n of ['single','batch','images']) $('pane-' + n).classList.toggle('hide', n !== b.dataset.tab);
    $('msg').className = 'msg';
  };
}
$('type').onchange = syncFields;
$('subject').onchange = syncChapters;
$('chapter').onchange = syncNewChapter;
$('f-subject').onchange = loadList;
$('f-type').onchange = loadList;
let t = null;
$('f-search').oninput = () => { clearTimeout(t); t = setTimeout(loadList, 250); };
$('pass').onkeydown = (e) => { if (e.key === 'Enter') $('signin').click(); };

if (TOKEN) enterApp();
