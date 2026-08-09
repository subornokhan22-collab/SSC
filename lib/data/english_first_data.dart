import 'dart:math';

/// English (Compulsory) — First Paper : Board Questions 2024.
///
/// Transcribed SAME-TO-SAME from the teacher's scanned board-question book
/// (Model Questions Based on Board Exam Questions [Paper-I], sets 61–69).
/// Word boxes, matching columns, info tables, passages and item letters are
/// kept exactly as printed. See services/english_board_pdf.dart (renderer).

/// One Q1 item: bold stem + options i.–iv.
class EF1McqItem {
  final String stem;
  final List<String> options; // 2–4 options
  const EF1McqItem(this.stem, this.options);
}

/// One full First-Paper board set (Part–A Reading 70 + Part–B Writing 30).
class EnglishFirstSet {
  final int serial; // 61–69
  final String board; // e.g. 'Dhaka Board–2024'
  final String passage1Intro; // 'Read the passage ...'
  final String passage1Unit; // 'Unit–15; Lesson–2(B)'
  final String passage1;
  final String q1Instr; // 'Choose the correct answer ...' / 'best answer'
  final List<EF1McqItem> q1; // 7 items (a)–(g)
  final List<String> q2; // 5 items (a)–(e)
  final String q3Instr; // 'Read the following passage/text ...' variants
  final String q3Source;
  final String q3Unit; // '[Unit…]' or the Bengali bracket note
  final String q3Cloze; // paragraph with (a)–(e) gaps
  final String passage2Intro; //'Read the following text ... questions no. 4 and 5 :'
  final String passage2;
  final String q4Instr; // 'Complete the table ...' variants
  final List<List<String>> q4Table; // all grid rows (blanks as printed '(i) ——')
  final Set<int> q4BoldRows; // row indices rendered bold
  final List<String> q6A, q6B, q6C; // matching columns (a)e / (i)v / (i)v
  final List<String> q7; // (a)–(h) story parts
  final List<String> q8; // (a)–(h) poem questions (Bengali hints included)
  final List<String> q9; // (a)–(h) story questions
  final String q10Instr;
  final String q10Starter;
  final String q11;

  const EnglishFirstSet({
    required this.serial,
    required this.board,
    required this.passage1Intro,
    required this.passage1Unit,
    required this.passage1,
    required this.q1Instr,
    required this.q1,
    required this.q2,
    this.q3Instr = ef1Q3InstrPassage,
    required this.q3Source,
    required this.q3Unit,
    required this.q3Cloze,
    required this.passage2Intro,
    required this.passage2,
    this.q4Instr = ef1Q4InstrTable,
    required this.q4Table,
    this.q4BoldRows = const {},
    required this.q6A,
    required this.q6B,
    required this.q6C,
    required this.q7,
    required this.q8,
    required this.q9,
    required this.q10Instr,
    required this.q10Starter,
    required this.q11,
  });
}

// ── Fixed instructions common to the sets ────────────────────────────────
const String ef1PartA = 'Part–A : Reading Test [70 Marks]';
const String ef1PartB = 'Part–B : Writing Test [30 Marks]';
const String ef1Q5Instr = 'Write a summary of the above passage in your own words.';
const String ef1Q6Instr =
    "Match the parts of sentences given in columns 'A', 'B' and 'C' to "
    'write five complete sentences.';
const String ef1Q7Instr =
    'Put the following parts of the story in correct order to make the '
    'whole story. Only the corresponding numbers of the sentences need to '
    'be written.';
const String ef1Q8Instr =
    'Answer the following questions from the poems of your textbook. '
    '[any 5 out of 8]';
const String ef1Q9Instr =
    'Answer the following questions from the stories of your textbook. '
    '[any 5 out of 8]';
const String ef1BengaliNote =
    '[বি.দ্র. : প্রশ্নটি পরিবর্তিত মানবণ্টন অনুযায়ী পরিমার্জন করা হয়েছে।]';
const String ef1OutsideNote = '[এই Passage-টি বর্তমান পাঠ্যবই বহির্ভূত]';
const String ef1Q3InstrPassage =
    'Read the following passage and fill in each gap with a suitable word '
    'based on the information of the passage.';
const String ef1Q3InstrText =
    'Read the following text and fill in each gap with a suitable word '
    'based on the information of the text.';
const String ef1Q4InstrTable =
    'Complete the table below with information from the above passage.';

/// The 9 board sets (2024), in the book's order 61–69.
final List<EnglishFirstSet> englishFirstSets2024 = [
  // ══ 61 · DHAKA BOARD–2024 ═════════════════════════════════════════════
  EnglishFirstSet(
    serial: 61,
    board: 'Dhaka Board–2024',
    passage1Intro: 'Read the passage carefully and answer the questions no. 1 and 2.',
    passage1Unit: 'Unit–15; Lesson–2(B)',
    passage1:
        'The Internet technology has helped design a large number of web sites '
        'to facilitate social relations among people around the world. These '
        'are known as social networking services or social networks or social '
        'media. At present, Facebook is the most popular social media site. '
        'Google+, Twitter, LinkedIn, etc. are other frequently used social '
        'services. Social network services are web-based and hence, provide '
        'ways for the users to interact through the Internet. These services '
        'make it possible to connect people across the borders and thus have '
        'made the users feel that they really live in a global village.\n'
        'Why are social networks expanding so fast? The answer is simple. Most '
        'of the social services are cost-free. You can make use of them free, '
        'paying a very little to your Internet service provider. Secondly, you '
        'can make your personal profile public before the entire online '
        'community. It is like presenting yourself before the entire world. '
        'You can also look into other people\u2019s profile if you are '
        'interested. It is simple and easy. Thirdly, social networks allow '
        'users to upload pictures, multimedia contents and modify the profile. '
        'Some services like Facebook allow users to update their profiles. '
        'Fourthly, networks allow users to post blog entries. User profiles '
        'have a section dedicated to comments from friends and other users. '
        'Finally, there are privacy protection measures too. A user himself or '
        'herself decides over the number of visitors/viewers, and what '
        'information should be shared with others.',
    q1Instr: 'Choose the correct answer from the following alternatives.',
    q1: const [
      EF1McqItem(
          'The internet technology has —— a large number of websites to '
          'facilitate social relations among people around the world.',
          ['defined', 'regained', 'destroyed', 'designed']),
      EF1McqItem('The term "Social Networks" refers to ——.',
          ['socialization', 'networking',
           'media for communicating with others', 'facebook']),
      EF1McqItem("In the text, the word 'frequently' stands for ——.",
          ['recurrently', 'freely', 'rarely', 'hardly']),
      EF1McqItem('The passage highlights the significance of ——.',
          ['electronic media', 'information technology',
           'social networking services', 'communication technology']),
      EF1McqItem('The social networking services work through ——.',
          ['computer', 'Facebook', 'email', 'Internet']),
      EF1McqItem('The social networking services are on the ——.',
          ['decline', 'rise', 'wane', 'decrease']),
      EF1McqItem(
          'There is also assurance of —— protection on using social networks.',
          ['community', 'privacy', 'measurement', 'society']),
    ],
    q2: const [
      'What is social networking service?',
      'How are the social networks making a global community?',
      'How does social network work?',
      '"It is simple and easy."—Explain the statement in 2/3 sentences.',
      'Why are social networks spreading rapidly?',
    ],
    q3Source:
        '"Today there are many jobs where we need English. This is because '
        'the world has become smaller. Vast distances are shortened by speedy '
        'transport. We can talk to a person thousands of kilometers away on '
        'the phone or the Internet. So we can communicate with the whole '
        'world easily. English has made this communication easier.\n'
        'There are many countries in the world with many languages, but to '
        'communicate with them, you cannot speak all the languages. So you '
        'need a common language that we can use with more or less all the '
        'people in the world. English is that common language. You can talk '
        'to a Chinese toy maker, a French artist, an Arab ambassador or a '
        'Korean builder in one language-English. English, for us in '
        'Bangladesh, is all the more important. As we have seen earlier, we '
        'are too many people in a small country. So if you learn English, you '
        'have the best opportunity to find a good job, both within and '
        'outside the country. And that is good news for millions of our '
        'unemployed youths."',
    q3Unit: '[Unit–5; Lesson–5(D)]',
    q3Cloze:
        'Different people use different languages for making (a) ——. But a '
        'common language is necessary in (b) —— to communicate with the '
        'people of the whole world. English has achieved the (c) —— of being '
        'that language. It helps to get good jobs and have better (d) ——. '
        'So, we should learn English properly as it helps (e) —— our '
        'unemployment problem.',
    passage2Intro:
        'Read the following text carefully and answer the questions no. 4 and 5 :',
    passage2:
        'Captain Mohiuddin Jahangir was an officer in the Army during the '
        'Liberation War of 1971. He was born on 7 March, 1949 at Rahimganj '
        'Village under Babuganj Thana in Barishal District. He completed his '
        'HSC from Barishal BM College. In 1967, he took admission in the '
        'department of Statistics in Dhaka University. On October 5, 1967 he '
        'joined the armed forces as a cadet in the Pakistan Military Academy. '
        'He was commissioned in the Engineering Corps in 1968. He was '
        'promoted to the rank of Captain on 30 August in 1970. He was an '
        'officer in Sector 7 of the Mukti Bahini. He was given the '
        'responsibility to fight at the Chapai Nawabganj border in Rajshahi. '
        'On 14 December 1971 he was killed in an attempt to break through the '
        'enemy defenses on the bank of the Mahananda River. He was buried '
        'near Sona Masjid. In recognition of his valor and sacrifice in the '
        'Liberation War, Mohiuddin Jahangir was awarded with the highest '
        'state honor of Birshestho.',
    q4Table: const [
      ['Captain Mohiuddin Jahangir'],
      ['Specialty', 'One of the greatest freedom fighters'],
      ['Recognition', 'Birshrestho'],
      ['Event/Activity', 'Where/place', 'When'],
      ['Born', 'Rahimganj', '(i) ——'],
      ['(ii) ——', 'Dhaka University', '1967'],
      ['Joined as a cadet', '(iii) ——', '1967'],
      ['(iv) ——', 'in the Engineering Corps', '1968'],
      ['Was killed', 'on the bank of Mohananda', '(v) ——'],
    ],
    q4BoldRows: const {0, 1, 2, 3},
    q6A: const [
      '(a)  Punctuality is a virtue', '(b)  It helps',
      '(c)  A punctual', '(d)  He who', '(e)  If we become'
    ],
    q6B: const [
      'person is', 'which can make us', 'punctual we shall',
      'is punctual never', 'us to become'
    ],
    q6C: const [
      'accurate in timing.', 'loved by all.', 'surely succeed in life.',
      'successful in future.', 'gets late in his work.'
    ],
    q7: const [
      'He thought him to be dead.',
      'The bear smelt his ears, nose and face.',
      'Suddenly they came across a bear.',
      'Once uon a time two friends were passing through a forest.',
      'Then the bear went away.',
      'Finding no other way, the later one laid down on the ground and '
      'feigned death.',
      'The first friend climbed up a tree but the later could not climb.',
      'They were talking about their love for each other.',
    ],
    q8: const [
      'What do books bring to us according to the poem "Books"?\n'
      '("Books" কবিতাটি অনুযায়ী বই আমাদের জন্য কী আনে?)',
      'What is the main theme of the poem "Two Mothers Remembered"?\n'
      '("Two Mothers Remembered" কবিতাটির মূল বিষয়বস্তু কী?)',
      'How does the poet portray the mother-daughter bond?\n'
      '(কবি মা-মেয়ের সম্পর্ক কীভাবে চিত্রিত করেছেন?)',
      'Who is the main character in the poem "The Sands of Dee"?\n'
      '("The Sands of Dee" কবিতাটির প্রধান চরিত্র কে?)',
      'Who is the speaker addressing in the poem "Time, You Old Gipsy Man"?\n'
      '("সময়, তুমি একজন বৃদ্ধ যাযাবর" কবিতায় কবি কাকে সম্বোধন করেছেন?)',
      'Whose woods does the speakers stop by?\n'
      '(কবি কার জঙ্গলের কাছে থামেন?)',
      'How does the poem "Solitude" reflect the poet\u2019s view of society?\n'
      '(Solitude কবিতাটি কীভাবে সমাজের প্রতি কবির দৃষ্টিভঙ্গি প্রতিফলিত করে?)',
      'What kind of questions trouble the poet in the poem "O me! O Life"?\n'
      '("O me! O Life" কবিতায় কী ধরনের প্রশ্ন কবিকে বিব্রত করে?)',
    ],
    q9: const [
      "What can you see in a jeweller's shop?",
      'Why did Rosamond cry out suddenly?',
      'How did Rosamond come to know that the purple jar was in fact a '
      'plain white glass jar?',
      "What was Bassanio's intention?",
      'What does "Shylock would cut a pound of flesh from any part of '
      'Antonio\u2019s body" indicate? Write 2/3 sentences regarding this.',
      'Why did Bassanio choose the lead casket?',
      'What was the lawful penalty?',
      'How do you evaluate the character of Shylock?\n'
      '(শাইলকের চরিত্রকে তুমি কিভাবে মূল্যায়ন করবে?)',
    ],
    q10Instr:
        'Read the beginning of a story below. It is not complete. Add at '
        'least ten new sentences to complete it. Give a suitable title to it :',
    q10Starter:
        'One day a school boy named Arif was returning home from school. On '
        'the way to his home, he saw an old woman who was begging. Arif asked '
        'the woman why she was begging. In reply, she told him that .........',
    q11:
        'Suppose, you are Tunan/Tanni. You have a friend named Milon/Mina. '
        'Your friend does not take physical exercise. But it is beneficial to '
        'health. Now, write a dialogue between you and your friend about the '
        'benefits of physical exercise.',
  ),
  // ══ 62 · RAJSHAHI BOARD–2024 ══════════════════════════════════════════
  EnglishFirstSet(
    serial: 62,
    board: 'Rajshahi Board–2024',
    passage1Intro: 'Read the passage and answer the questions 1 and 2.',
    passage1Unit: 'Unit–2; Lesson–1(A)',
    passage1:
        'Meherjan lives in a slum on the Sirajgonj Town Protection '
        'Embankment. The whispering wind from the river Jamuna makes the '
        'fire unsteady. The dancing flames remind Meherjan of the turmoil '
        'in her life. Not long ago Meherjan had everything--- a family, '
        'arable land and cattle. The erosion of the Jamuna gradually '
        'consumed all her land property. It finally claimed her only '
        'shelter during the last monsoon. It took the river only a day to '
        'devour Meher\u2019s house, trees, vegetable garden and the bamboo '
        'bush. She had a happy family once. Over the years, she lost her '
        'husband and her family to diseases that cruel hunger and poverty '
        'brought to the family. Now, she is the only one left to live on '
        'with the loss and the pain. The greedy Jamuna has shattered her '
        'dreams and happiness.\n'
        'There are thousand others waiting to share the same fate like '
        'Meherjan. Bangladesh is a land of rivers, some of whose banks '
        'overflow or erode during monsoon. Erosion is a harsh reality for '
        'the people living along the river banks. During each monsoon many '
        'more villages are threatened by the mighty rivers like the Jamuna, '
        'the Padma and the Meghna. It is estimated that river erosion '
        'makes at least 100,000 people homeless every year in Bangladesh. '
        'In fact, river erosion is one of the main dangers caused by '
        'climate change. If we can\u2019t take prompt actions to adapt to '
        'climate change, there will be thousands of more Meherjans in our '
        'towns and villages every year.',
    q1Instr: 'Choose the correct answer from the following alternatives.',
    q1: const [
      EF1McqItem('Meher\u2019s life was very happy before ——.',
          ['the liberation', 'the destruction of the river Jamuna',
           'the victory', 'the independence']),
      EF1McqItem('\u2018Greedy Jamuna\u2019 is used here to describe the ——.',
          ['cruelty of nature', 'demand of a consumer',
           'supply of a consumer', 'help of a consumer']),
      EF1McqItem('Meherjan is a victim of ——.',
          ['drought', 'famine', 'river erosion', 'cyclone']),
      EF1McqItem('The word \u2018turmoil\u2019 indicates ——.',
          ['agitation', 'reduction', 'constant', 'rigid']),
      EF1McqItem('The word \u2018shatter\u2019 means ——.',
          ['to destroy something', 'to break something into pieces',
           'to erect something', 'to complete something']),
      EF1McqItem('The phrase \u2018whispering wind\u2019 means ——.',
          ['wind that blows from across the river',
           'wind that blows with a hissing sound',
           'wind that helps someone make a fire',
           'wind that blows in summer']),
      EF1McqItem('What is the main purpose of the author of the passage?',
          ['To explain the importance of river',
           'To describe the impact of monsoon',
           'To describe the effect of river erosion.',
           'To describe the fate of a woman.']),
    ],
    q2: const [
      'Why does the author call the Jamuna greedy?',
      'Where does Meherjan live?',
      'What does \u2018dancing flame\u2019 mean?',
      'How can we stop river erosion?',
      'When are many more villages threatened by the roaring rivers?',
    ],
    q3Source:
        'Scientists have identified Hydrogen as another form of renewable '
        'energy source. It is the most abundant element in nature. But it '
        'does not exist separately as a gas. It is always combined with '
        'other elements, such as with Oxygen to make water. Hydrogen, '
        'separated from another element, can be burned as a fuel to '
        'produce electricity.',
    q3Unit: '[Unit–14; Lesson–2(B)]',
    q3Cloze:
        'Scientists have (a) —— out that Hydrogen can be (b) —— as '
        'renewable energy source. The nature is (c) —— with Hydrogen '
        '(d) —— it does not exist separately as gas. Hydrogen and Oxygen '
        '(e) —— water.',
    passage2Intro:
        'Read the following text and answer the questions 4 and 5 :',
    passage2:
        'Abul Kashem Fazlul Huq was born in 1873. at Saturia in Barishal. '
        'He received his primary education in a village Maktab. Then he '
        'entered Barishal Zilla School. He passed the Entrance Examination '
        'standing first in the Dhaka Division. After that he went to '
        'Calcutta for higher education. At the age of twenty-one he passed '
        'the B.Sc Exam obtaining Honours in Chemistry, Physics and Math '
        'from the Presidency College, Calcutta. He took his M.Sc degree in '
        'Math in 1896. The next year he was appointed as an examiner of '
        'M.A. in Math in Calcutta University. Then he passed B.L. '
        'Examination. Then he enrolled himself in the Calcutta High Court. '
        'He worked with Nawab Sir Salimullah.\n'
        'He played an important role in founding the All Indian Muslim '
        'League in 1906. Then he became Deputy Magistrate. But he resigned '
        'and again joined Calcutta High Court. In 1913 he became an '
        'elected member of B.L.C. Three years after he attended the '
        'special joint session of the Congress and the Muslim League in '
        'Lucknow. In 1918 he became the General Secretary of the Indian '
        'National Congress and the President of the All India Muslim '
        'League.',
    q4Instr:
        'Complete the following table with information from the above text.',
    q4Table: const [
      ['Abul Kashem Fazlul Huq'],
      ['His main contribution',
       'Founded the All India Muslim League and became the (i) —— of it'],
      ['Who', 'Event', 'Time', 'Place'],
      ['Abul Kashem Fazlul Huq', 'was born', '1873', '(ii) ——'],
      ['He', '(iii) ——', '1894', 'Presidency College, Calcutta'],
      ['He', 'took his MSc Degree', '(iv) ——', ''],
      ['He', '(v) ——', '1897', 'Calcutta University'],
    ],
    q4BoldRows: const {0, 2},
    q6A: const [
      '(a)  The function of education', '(b)  But education',
      '(c)  The most dangerous criminal', '(d)  We must remember',
      '(e)  Intelligence plus character'
    ],
    q6B: const [
      'which connects with efficiency', 'should be', 'is to teach one',
      'that intelligence is', 'may be the man who'
    ],
    q6C: const [
      'not enough for a man.', 'gifted with reasons and morals.',
      'to think intensively.', 'the goal of true education.',
      'may prove the greatest menace to society.'
    ],
    q7: const [
      'The king followed the advice of the physician and became slim and '
      'fully cured.',
      'He advised the king to move a heavy club into the air till he got '
      'tired.',
      'He did not undergo physical labour.',
      'The doctor was very wise.',
      'He became bulky and could not move or do anything.',
      'Once there was a king who was very idle.',
      'He did not prescribe any medicine.',
      'He called in a doctor.',
    ],
    q8: const [
      'What happens when one opens and looks at a book?\n'
      '(যখন কেউ একটি বই খোলে ও দেখে তখন কী ঘটে?)',
      'How many mothers does the poet claim to have?\n'
      '(কতজন মা আছে বলে কবি দাবী করেন?)',
      'What lesson does the poem teach about caregiving in "Two Mothers '
      'Remembered"?\n(যত্নশীল হওয়া সম্পর্কে কবিতাটি কী শিক্ষাদান করে?)',
      'What task was Mary asked to do?\n'
      '(মেরিকে কী কাজ করতে বলা হয়েছিল?)',
      'What request does the speaker make to Time?\n'
      '(কবি সময়ের কাছে কী অনুরোধ করেছেন?)',
      'Why does the speaker stop by the woods?\n'
      '(কবি কেন জঙ্গলের কাছে থামেন?)',
      'What role does nature play in the poem "Solitude" in reinforcing '
      'the poem\u2019s theme?\n(কবিতার বিষয়বস্তুকে শক্তিশালী করতে '
      'Solitude কবিতায় প্রকৃতি কী ভূমিকা পালন করে?)',
      "What does the poet mean by 'endless train of the faithless'?\n"
      "(অবিশ্বাসীদের অর্থহীন সারি' বলতে কবি কি বুঝিয়েছেন?)",
    ],
    q9: const [
      'Why was Rosamond a little disheartened?',
      'Why did Rosamond request her mother to buy her another pair of '
      'shoes?',
      'Describe the sufferings and disappointments of Rosamond for buying '
      'the purple jar.',
      'How did Bassanio lead his life?',
      'On what condition did Shylock agree to lend Antonio money?',
      '"It is the casket made of precious metal that can hold the precious '
      'picture." Who said this? Why did he choose this?',
      'What was not mentioned in the bond?',
      'Why did Rosamond buy the jar without examining it properly?',
    ],
    q10Instr:
        'Read the beginning of a story. Now, complete it in your own '
        'language. Give a suitable title to it :',
    q10Starter:
        'Once upon a time, there was a king called Midas. He was very '
        'rich but he always longed for more riches. Moreover, he was fond '
        'of gold though he had a lot of it......',
    q11:
        'Suppose, you are Robin/Rubi and you have a friend named '
        'Fardin/Fariha. Now, write a dialogue between you and your friend '
        'about Dengue fever and its remedies.',
  ),
  // ══ 63 · JASHORE BOARD–2024 ═══════════════════════════════════════════
  EnglishFirstSet(
    serial: 63,
    board: 'Jashore Board–2024',
    passage1Intro:
        'Read the following passage and answer the questions 1 and 2 :',
    passage1Unit: 'Unit–15; Lesson–2(B)',
    passage1:
        'The Internet technology has helped design a large number of web '
        'sites to facilitate social relations among people around the '
        'world. These are known as social networking services or social '
        'networks or social media. At present, Facebook is the most '
        'popular social media site. Google+, Twitter, LinkedIn, etc. are '
        'other frequently used social services. Social network services '
        'are web-based and hence, provide ways for the users to interact '
        'through the Internet. These services make it possible to connect '
        'people across the borders and thus have made the users feel that '
        'they really live in a global village.\n'
        'Why are social networks expanding so fast? The answer is simple. '
        'Most of the social services are cost-free. You can make use of '
        'them free, paying a very little to your Internet service '
        'provider. Secondly, you can make your personal profile public '
        'before the entire online community. It is like presenting '
        'yourself before the entire world. You can also look into other '
        'people\u2019s profile if you are interested. It is simple and '
        'easy. Thirdly, social networks allow users to upload pictures, '
        'multimedia contents and modify the profile. Some services like '
        'Facebook allow users to update their profiles. Fourthly, networks '
        'allow users to post blog entries. User profiles have a section '
        'dedicated to comments from friends and other users. Finally, '
        'there are privacy protection measures too. A user himself or '
        'herself decides over the number of visitors/viewers, and what '
        'information should be shared with others.',
    q1Instr: 'Choose the correct answer from the following alternatives.',
    q1: const [
      EF1McqItem('Social network services are ——.',
          ['family based', 'web based', 'relation based',
           'individual based']),
      EF1McqItem('This passage highlights the importance of ——.',
          ['electronic media', 'information technology',
           'social networking services', 'completing education']),
      EF1McqItem('—— are sharing interests through internet.',
          ['Only students', 'People of the world',
           'Only the rich people', 'A privileged few']),
      EF1McqItem(
          'What does the expression "They really live in a global '
          'village" mean?',
          ['All people of the world live in village',
           'Village people have every facility of the world',
           'None lives in cities',
           'Internet and social media have brought the world closer']),
      EF1McqItem('internet increases ——.',
          ['relative relation', 'family relation', 'social relation',
           'human relation']),
      EF1McqItem('The word \u2018protection\u2019 means ——.',
          ['adapt', 'guard', 'alter', 'adjust']),
      EF1McqItem('The word \u2018Viewer\u2019 refers to ——.',
          ['listener', 'diplomate', 'spectator', 'vision']),
    ],
    q2: const [
      'Write down the names of some social media sites.',
      'How is it possible for the social networks to provide ways for '
      'the users to interact through the internet?',
      'When do the users feel that they really live in a global village?',
      'How do social networks work?',
      'Why are social networks expanding so fast?',
    ],
    q3Instr:
        'Read the following passage and fill in each gap with a suitable '
        'word based on the information of the text.',
    q3Source:
        'Fish population is in serious danger from global warming. '
        'Climate change is increasing the water temperature in rivers, '
        'lakes and sea. This means there is less food and oxygen '
        'available for fish. It also means the fish may not grow fully '
        'and may have fewer fish fries. Some fishes will become extinct '
        'if temperatures rise even by one or two degree Celsius. Climate '
        'change increases the pressure on fish population. Fishes are one '
        'of the world\u2019s most valuable biological assests. Forty '
        'percent of people in the world eat fish as their main source of '
        'protein. If we fail to reduce greenhouse gas emissions we will '
        'increase the pressure on fish. As a result, people who depend on '
        'fish will suffer from hunger and poverty.',
    q3Unit: ef1OutsideNote,
    q3Cloze:
        'Global warming raises the stress on fish population. Fish '
        'population is severely affected (a) —— to global warming. For '
        'want of food and oxygen some (b) —— of fish may be (c) —— one '
        'day. To stop global warming, we have to convince people not to '
        '(d) —— greenhouse gas. Otherwise many people have to (t) —— '
        'poverty and hunger.',
    passage2Intro:
        'Read the following passage carefully and answer the questions '
        '4 and 5 :',
    passage2:
        'Charles Babbage was an English mathematician. He was also a '
        'mechanical engineer who is best known for originating the '
        'concept of computer. He was born on 26 December 1791 in London. '
        'He entered Trinity College in October 1810. He was transferred '
        'to Peterhouse, Cambridge. He was the top mathematician there. '
        'He received an honours degree without examination in 1814. He '
        'was elected a fellow of the Royal Society in 1816. From 1828 to '
        '1839 Babbage was Lucasian Professor of Mathematics at Cambridge '
        'University. Babbage is famous for inventing the first mechanical '
        'computer in 1822 that eventually led to today\u2019s computer. '
        'He died at his home in London on 18 October 1871.',
    q4Instr:
        'Complete the table below with the information from the above '
        'passage.',
    q4Table: const [
      ['Charles Babbage'],
      ['Speciality', 'The master brain of inventing computer'],
      ['Best known', 'The inventor of the first mechanical computer'],
      ['Who/What', 'Event', 'Place', 'Year/Time', 'Contribution'],
      ['Charles Babbage', 'was born', 'London', '(i) ——', ''],
      ['He', 'was elected a fellow', '(ii) ——', 'in 1816', ''],
      ['He', '(iii) ——', '', 'in 1814', ''],
      ['His contribution', '', '', 'in 1822', '(iv) ——'],
      ['Death', '', '', '(v) ——', ''],
    ],
    q4BoldRows: const {0, 3},
    q6A: const [
      '(a)  Price hike has added', '(b)  Price hike is caused by',
      '(c)  The vast majority are hard hit', '(d)  It is very difficult',
      '(e)  Price hike'
    ],
    q6B: const [
      'short supply of commodities', 'leads to',
      'for the fixed income group of people', 'a new dimension',
      'by the hike in prices'
    ],
    q6C: const [
      'widespread corruption and moral degradation.',
      'to the problems of Bangladesh.', 'of daily necessities.',
      'to meet up the excessive load.', 'and inflation.'
    ],
    q7: const [
      'Penicillin is the life saving medicine.',
      'He passed his boyhood with his parents.',
      'It was discovered by Dr. Alexander Fleming.',
      'He was the seventh of the eight brothers and sisters.',
      'He was never absent from school up to the age of twelve.',
      'He was sent to London at the age of fourteen for higher study.',
      'He was born in a poor family in Scotland.',
      'Fleming was a very regular and attentive student.',
    ],
    q8: const [
      'What melts away when we read a book?\n'
      '(যখন আমরা বই পড়ি তখন কী অদৃশ্য হয়ে যায়?)',
      'What does the poet mean by "two different people, yet with the '
      'same name"?\n("দুইজন ভিন্ন ব্যক্তি কিন্তু নাম একই" দ্বারা কবি কী '
      'বুঝিয়েছেন?)',
      'How are the two mothers different from each other?\n'
      '(দুই মা একে অন্যের চেয়ে কিভাবে আলাদা?)',
      'What was the condition of the western wind in "The Sands of Dee"?\n'
      '(পশ্চিমা বাতাসের অবস্থা কেমন ছিল?)',
      'What does the speaker offer to Time in return for staying?\n'
      '(কবি সময়কে থাকার বিনিময়ে কী প্রভাব করেছেন?)',
      'Where is the owner of the woods?\n(জঙ্গলটির মালিক কোথায়?)',
      'Why does the poet use contrasting imagery, such as "feast" and '
      '"fast" in the poem "Solitude"?\n(কবি Solitude কবিতায় বিপরীত '
      'চিত্রকল্প "feast" এবং "fast" ব্যবহার করেছেন কেন?)',
      'Why does the poet call himself foolish and faithless in "O Me! '
      'O Life!"?\n(কেন কবি নিজেকে নির্বোধ ও অবিশ্বাসী বলেন?)',
    ],
    q9: const [
      'Why do you think Rosamond wanted to buy all the things?',
      'Why did Rosamond\u2019s mother want to buy her only one thing? '
      'What did Rosamond decide to buy at last?',
      "What is the lesson of the story 'The Purple Jar'?",
      'Do you think that Antonio was really worthy of getting love from '
      'people? Why/ Why not?',
      'Why did Bassanio\u2019s and Portia\u2019s happiness turn into '
      'sorrow?',
      'What did Portia say regarding mercy?\n'
      '(ক্ষমা সম্পর্কে পোর্শিয়া কী বলেছিলেন?)',
      'Do you support that Shylock was right to claim the pound of '
      'flesh? Why or why not? Explain in 2 or 3 sentences.',
      'Do you think that the unusual plan of Portia\u2019s father to '
      'find a good husband for his daughter was successful? Why/ Why '
      'not?',
    ],
    q10Instr:
        'Read the beginning of a story. Write at least ten new sentences '
        'to complete the story :',
    q10Starter:
        'Once there lived a King in an island. There were green trees '
        'everywhere in the island. The King decided to build a '
        'magnificent palace in the island. So he ordered his men to cut '
        'down all the trees. Some opposed the King\u2019s idea but he did '
        'not pay ..........',
    q11:
        'Suppose, you are Sostika/Anu and your friend\u2019s name is '
        'Tanzima/Khalid. Now, write a dialogue between you and your '
        'friend about the severe impact of dengue fever.',
  ),
  // ══ 64 · CUMILLA BOARD–2024 ═══════════════════════════════════════════
  EnglishFirstSet(
    serial: 64,
    board: 'Cumilla Board–2024',
    passage1Intro: 'Read the passage and answer the questions no 1 and 2.',
    passage1Unit: 'Unit–4; Lesson–2(B)',
    passage1:
        'May Day or International Workers\u2019 Day is observed on May 1 '
        'all over the world today to commemorate the historical struggle '
        'and sacrifices of the working people to establish an eight-hour '
        'workday. It is a public holiday in almost all the countries of '
        'the world.\n'
        'Since the Industrial Revolution in the 18th and 19th centuries '
        'in Europe and the US, the workers in mills and factories had '
        'been working a long shift, fourteen or even more hours a day.\n'
        'On May 1st in 1886, inspired by the trade unions, half of the '
        'workers at the McCormick Harvesting Machine Company in Chicago '
        'went on strike demanding an eight-hour workday. Two days later, '
        'a workers\u2019 rally was held near the McCormick Harvester '
        'Machine Company and about 6000 workers joined it. The rally was '
        'addressed by the labour leaders. They urged the workers to stand '
        'together, to go on with their struggle and not to give in to '
        'their bosses. At one point of the rally, some strike breakers '
        'started leaving the meeting place. The strikers went down the '
        'street to bring them back. Suddenly about 200 policemen attacked '
        'them with clubs and revolvers. One striker was killed instantly, '
        'five or six others were seriously wounded and many others were '
        'injured.\n'
        'The events of May 1, 1886 are a reminder that workers will '
        'continue to be exploited until they stand up and speak out to '
        'gain better working conditions, better pay and better lives.',
    q1Instr: 'Choose the correct answer from the following alternatives.',
    q1: const [
      EF1McqItem(
          'The word \u2018commemorate\u2019 used in the passage means ——.',
          ['display', 'disguise', 'remember', 'reunion']),
      EF1McqItem(
          'The prevailing work-hour of the workers had been very ——.',
          ['tolerable', 'short', 'lengthy', 'expectable']),
      EF1McqItem('Where is May Day observed today?',
          ['All over the world', 'In Bangladesh', 'In Europe',
           'In the USA']),
      EF1McqItem('The policemen attacked the strikers on ——.',
          ['May 1, 1886', 'May 2, 1886', 'May 3, 1886', 'May 4, 1886']),
      EF1McqItem('Whom does trade union represent?',
          ['Farmers', 'Teachers', 'Workers', 'Businessmen']),
      EF1McqItem(
          'In the rally, the labour leaders inspired the workers ——.',
          ['to follow their bosses', 'to honour their bosses',
           'not to surrender to their bosses',
           'not to disobey their bosses']),
      EF1McqItem('Clubs and revolvers were used upon ——.',
          ['trade union leaders', 'policemen', 'owner of the factory',
           'strikers']),
    ],
    q2: const [
      'What does May Day commemorate?',
      'When and where did the historic events of May 1st take place?',
      'Which demand did the workers struggle for?',
      'What happened when the policemen attacked the strikers?',
      'What inspired the workers joining the protest?',
    ],
    q3Source:
        'Fish population is in serious danger from global warming. '
        'Climate change is increasing the water temperature in rivers, '
        'lakes and seas. This means there is less food and oxygen '
        'available for fish. It also means the fish may not grow fully '
        'and may have fewer fish fries. Some fishes will become extinct '
        'if temperatures rise even by one or two degrees Celsius.\n'
        'Climate change increases the pressure on fish population. '
        'Fishes are one of the world\u2019s most valuable biological '
        'assets. Forty percent of people in the world eat fish as their '
        'main source of protein. If we fail to reduce greenhouse gas '
        'emissions, we will increase the pressure on fish. As a result, '
        'people who depend on fish will suffer from hunger and poverty.',
    q3Unit: ef1OutsideNote,
    q3Cloze:
        'It is (a) —— from the passage that global warming is (b) —— a '
        'great threat to fish population. (c) —— to global warming, food '
        'production and oxygen, (d) —— in water decrease. As a result, '
        'some fish may be extinct (e) ——.',
    passage2Intro:
        'Read the following passage on Jibanananda Das and then answer '
        'questions no. 4 and 5 :',
    passage2:
        'Jibanananda Das was born in a small town of Barishal in 1899. '
        'He took his Master\u2019s Degree in English at the age of 22. '
        'The next year, he started his teaching career as a Professor of '
        'English at the Kolkata City College. He lost the job in 1928 on '
        'the charge of publishing a poem in the \u2018Parichaya\u2019 '
        'Patrika. But two years later, he joined the Ramjash College, '
        'Delhi, though he returned to his place of birth the next year. '
        'He got an appointment in Brajamohan College, Barishal in 1935. '
        'In 1947 when the partition was made, Jibanananda Das left '
        'Bangladesh for India. In West Bengal he started editing the '
        'Swaraj Patrika. In 1951 he joined the Kharagpur College. He was '
        'awarded Rabindra Purashkar in 1953. He met with a tram accident '
        'on the 14th October, 1954 and was hospitalized. After a few '
        'days, he passed away on October 22, 1954.',
    q4Instr:
        'Complete the following table with information from the passage.',
    q4Table: const [
      ['Who/What', 'Activities', 'Where', 'When'],
      ['Jibananando', 'born', '(iv) ——', 'in 1899'],
      ['He', 'M.A', 'English', '(ii) ——'],
      ['Career', '(iii) ——', 'Kolkata City College', 'in 1922'],
      ['', 'Migration', '(iv) ——', 'in 1947'],
      ['(v) ——', 'award', '', 'in 1953'],
    ],
    q4BoldRows: const {0},
    q6A: const [
      '(a)  Patriotism is a great virtue', '(b)  It is such a virtue',
      '(c)  Patriotism inspires us',
      '(d)  So, we all should encourage our children',
      '(e)  Radio and television should telecast programmes'
    ],
    q6B: const [
      'to be ready to fight against', 'to be patriot and to be devoted',
      'that inspire children to prepare', 'without which we cannot',
      'for which a citizen doesn\u2019t hesitate'
    ],
    q6C: const [
      'themselves to work for the country.',
      'all oppressions that can hinder our progress.',
      'dream of a developed nation.',
      'to their respective duties and responsibilities.',
      'to shed the last drop of his blood.'
    ],
    q7: const [
      'The king asked him why he was making such a small boat.',
      'Napoleon, the king of France, was a great hero.',
      'One day, he was walking along the sea-shore.',
      'He won many battles and conquered many countries of Europe.',
      'The boy said, "I shall cross the sea and go my home."',
      'Suddenly, he noticed a wonderful thing.',
      'The boy was brought before him.',
      'An English boy was making a small boat.',
    ],
    q8: const [
      'What might the people in books become by the end?\n'
      '(বইয়ের মানুষগুলো শেষ পর্যন্ত কী হতে পারে?)',
      'What did the first mother give to the poet?\n'
      '(প্রথম মা কবিকে কী দিয়েছিলেন?)',
      'How are the two mothers the same?\n(মা দুটি কিভাবে একরকম?)',
      'What happened to the land as the mist came down in "The Sands of '
      'Dee"?\n(কুয়াশা নামার সাথে সাথে ভূমির কী হলো?)',
      'How does the poet personify Time?\n'
      '(কবি সময়কে কীভাবে মানবিক রূপ দিয়েছেন?)',
      'What does the speaker\u2019s horse think about stopping?\n'
      '(কবির ঘোড়া থামা সম্পর্কে কী ভাবে?)',
      'What happens when you laugh, according to the poem "Solitude"?\n'
      '(Solitude কবিতা অনুযায়ী, যখন তুমি হাসো, তখন কী ঘটে?)',
      "What does 'eyes that vainly crave the light' symbolize?\n"
      "('যে চোখ অযথা আলোর প্রার্থনা করে' কী প্রতীকায়িত করে?)",
    ],
    q9: const [
      'What does "I am sure, Mamma, you could find some use if you only '
      'bought them first" indicate? Write 2/3 sentences regarding this.',
      'Do you support that Rosamond\u2019s mother was right to force '
      'Rosamond to choose only one thing? Why or Why not? Explain in 2 '
      'or 3 sentences.',
      'Do you think Rosamond\u2019s mother didn\u2019t know about the '
      'coloured water of the jar? Why did she let Rosamond buy it?',
      'How was the relationship between Antonio and Shylock?',
      'Do you support the attitude of Shylock to lend money with high '
      'interest? Why/ Why not? Explain in 2 or 3 sentences.',
      'Do you support the idea of Bassanio that bad men appear good and '
      'they hid their inner ugliness under fine clothes? Why or why '
      'not? Explain in 2 or 3 sentences.',
      'What did the letter of the wisest lawyer contain?',
      'How did Rosamond\u2019s mother teach her daughter a great lesson?',
    ],
    q10Instr:
        'Read the beginning of a story. Write at least ten new sentences '
        'to complete the story :',
    q10Starter:
        'Rahmat Mia is a poor rickshaw puller in Dhaka. He pulls '
        'rickshaw in different areas of the city. One day he saw some '
        'men selling lottery tickets. He felt tempted and bought a '
        'ticket......',
    q11:
        'Suppose, you are Karim/Karima and your younger brother is '
        'Muhib. Write a dialogue between you and your brother about the '
        'merits and demerits of using mobile phone.',
  ),
  // ══ 65 · CHATTOGRAM BOARD–2024 ════════════════════════════════════════
  EnglishFirstSet(
    serial: 65,
    board: 'Chattogram Board–2024',
    passage1Intro:
        'Read the following text carefully. Then answer the questions '
        'no. 1 and 2.',
    passage1Unit: 'Unit–7; Lesson–3(B)',
    passage1:
        'It was late summer, 26 August 1910. A little girl was born to a '
        'rich Catholic merchant\u2019s family of Albanian descent in a '
        'small town called Skopje, Macedonia. She was the youngest of '
        'the three siblings and was named Agnes Gonxha Bojaxhiu. Who '
        'could imagine at the time that this little girl would one day '
        'become the mother of humanity, loving and serving the poorest '
        'of the poor. Yes, we are talking about none other than Mother '
        'Teresa.\n'
        'At the age of 12, she heard a voice from within that urged her '
        'to spread the love of Christ. She decided that she would be a '
        'missionary. At the age of 18 she left her parental home. She '
        'then joined an Irish community of nuns called the Sisters of '
        'Loreto, which had missions in India.\n'
        'After a few months of training at the Institute of the Blessed '
        'Virgin Mary in Dublin, Mother Teresa came to India. On May 24, '
        '1931, she took her initial vows as a nun. From 1931 to 1948, '
        'Mother Teresa taught geography and theology at St. Mary\u2019s '
        'High School in Kolkata (then Calcutta). However, the widespread '
        'poverty in Kolkata had a deep impact on Mother Teresa, and in '
        '1948 she received permission from her superiors to leave the '
        'convent and devote herself to caring for the poorest of the '
        'poor in the slums of Kolkata.',
    q1Instr: 'Choose the best answer from the alternatives.',
    q1: const [
      EF1McqItem(
          'What does \u2018mother of humanity\u2019 refers to in the '
          'passage?',
          ['a mother who takes a great care of her children.',
           'an affectionate mother.',
           'a mother who serves the poor like her own children.',
           'a mother who dislikes humanity.']),
      EF1McqItem(
          'From childhood Mother Teresa desired to be a ——.',
          ['social worker', 'missionary', 'religious person',
           'political figure']),
      EF1McqItem(
          'The voice within her urged her with a view to —— the love '
          'of Christ.',
          ['spread', 'hinder', 'hindering', 'spreading']),
      EF1McqItem(
          '\u2018The Sisters of Loreto\u2019 is an organisation of '
          'Irish ——.',
          ['monks', 'nuns', 'clergymen', 'priests']),
      EF1McqItem(
          '\u2018The poorest of the poor\u2019 stands for the people '
          'who live ——.',
          ['above the poverty line', 'with much poverty',
           'under the poverty line', 'in poor condition']),
      EF1McqItem('What shocked Mother Teresa most in Kolkata?',
          ['discrimination', 'less poverty', 'extreme poverty',
           'food crisis']),
      EF1McqItem('What is the main theme of the passage?',
          ['To spread Christianity', 'To remove poverty',
           'To spread education', 'Love for the distressed']),
    ],
    q2: const [
      'Where did Mother Teresa come of?',
      'Why did Mother Teresa decide to be a missionary?',
      'How did she become the mother of humanity?',
      'What did Mother Teresa do in the first seventeen years in India?',
      'Why did she leave her parental home?',
    ],
    q3Source:
        'The Internet technology has helped design a large number of '
        'websites to facilitate social relations among people around '
        'the world. These are known as social networking services or '
        'social networks or social media. At present, Facebook is the '
        'most popular social media site. Google+, Twitter, LinkedIn, '
        'etc. are other frequently used social services. Social network '
        'services are web-based and hence, provide ways for the users '
        'to interact through the internet. These services make it '
        'possible to connect people across the borders and thus have '
        'made the users feel that they really live in a global village.\n'
        'Why are social networks expanding so fast? The answer is '
        'simple. Most of the social services are cost-free. You can '
        'make use of them free, paying a very little to your Internet '
        'services providers.',
    q3Unit: '[Unit–15; Lesson–2(B)]',
    q3Cloze:
        'With the development of Internet Technology a number of '
        'websites have been designed to promote the relations (a) —— '
        'the people of the world. By (b) —— these social media, we can '
        '(c) —— our ideas with each other and feel as the citizen of a '
        'global village. The social media are expanding rapidly for '
        '(d) —— low-cost. It has brought the whole world within our '
        '(e) ——.',
    passage2Intro:
        'Read the passage carefully and answer the questions no. 4 and '
        '5 :',
    passage2:
        'William Wordsworth was a major English romantic poet. He was '
        'born on April 7, 1770 in Cumberland, Lake District of England. '
        'His father was an attorney. In 1778 when he was only eight '
        'years old, his mother died, and in the same year he went to '
        'Grammar School. In his childhood, he learned poetry of Milton '
        'and Shakespeare from his father. His father died in 1783 and '
        'then he became dependent on his relatives. However, he '
        'continued his study and first wrote a poem in 1787. He went to '
        'St. John\u2019s College, Cambridge, and graduated from that '
        'college in 1791. Then he went out with his friends on a '
        'walking tour to France and Italy. He spent the next year '
        'there. While in Farance, he fell in love with a French woman '
        'Annette Vallon. He was greatly influenced by the French '
        'Revolution in 1791. He had a close friendship with another '
        'romantic poet Samuel Taylor Coleridge. They jointly published '
        'a book named Lyrical Ballads in 1798. In this book they '
        'explained their new poetic theory. They introduce a new '
        'poetic idea of poem. Finally he was the poet laureate of '
        'England.',
    q4Instr:
        'Complete the table below with the information from the passage.',
    q4Table: const [
      ['Biography of William Wordsworth'],
      ['Speciality : (i) ——'],
      ['Who/What', 'Event', 'Time', 'Place'],
      ['W. Wordsworth', 'born', '(ii) ——', ''],
      ['He', 'graduated', '', '(iii) ——'],
      ['(iv) ——', 'Lyrical Ballads', '', ''],
      ['French Revolution', '', '(v) ——', ''],
    ],
    q4BoldRows: const {0, 2},
    q6A: const [
      '(a)  The Bay of Bengal', '(b)  Cox\u2019s Bazar that',
      '(c)  The blue water', '(d)  The Saint Martin\u2019s Island which',
      '(e)  The natural beauty of'
    ],
    q6B: const [
      'and rising waves create a pleasant sight', 'is situated',
      'stretches for miles', 'Saint Martin\u2019s Island is',
      'is located in the Bay of Bengal'
    ],
    q6C: const [
      'is the longest sea beach in the world.',
      'which cools our mind instantly.', 'beyond description.',
      'is a coral island.', 'to the south of Bangladesh'
    ],
    q7: const [
      'In 1930 he joined the Ramjash College, Delhi but returned to '
      'his place of birth the next year.',
      'In 1947, when the partition was made Jibanananda Das left '
      'Bangladesh for India.',
      'He lost the job in 1928 on the charge of publishing a poem in '
      '"The Parichaya Patrika".',
      'He got an appointment in Brajomohan College, Barishal in 1935.',
      'He took his Master\u2019s Degree in English at the age of 22.',
      '1951, he joined the Kharagpur College.',
      'Jibanananda Das was born in a small town of Barishal in 1899.',
      'The next year he started his teaching career as a professor of '
      'English at Kolkata City College.',
    ],
    q8: const [
      'What do we do as we sail along the pages of book?\n'
      '(আমরা বইয়ের পাতাগুলো ভ্রমণ করার সময় কী করি?)',
      'What other benefits do you think reading books can give you?\n'
      '(বই পড়ে তুমি অন্য আর কী কী উপকারিতা পাবার কথা চিন্তা করো?)',
      'How did the poet\u2019s relationship with her mother change as '
      'she grew older?\n(কবি বড়ো হওয়ার সাথে সাথে তার মায়ের সাথে তার '
      'সম্পর্ক কীভাবে পরিবর্তিত হয়েছিল?)',
      'What did the boatman find in the nets in "The Sands of Dee"?\n'
      '(নৌকার মাঝিরা জালে কী খুঁজে পেয়েছিলেন?)',
      'What emotion does the speaker express towards Time?\n'
      '(কবি সময়ের প্রতি কী অনুভূতি বা আবেগ প্রকাশ করেছেন?)',
      'What sound does the horse make in Stopping by Woods on a Snowy '
      'Evening?\n(ঘোড়াটি কী শব্দ করে?)',
      'What happens when you weep, as described in the poem '
      '"Solitude"?\n(Solitude কবিতার বর্ণনা অনুযায়ী যখন তুমি কাঁদো, '
      'তখন কী ঘটে?)',
      'Explain the following lines taken from the poem "Solitude" in '
      'your own words ("Solitude" কবিতা থেকে নেয়া নিচের লাইনগুলোর অর্থ '
      'তোমার নিজের ভাষায় ব্যাখ্যা করো) :\n'
      'i)  "Laugh, and the world laughs with you; ("হাসো, এবং পৃথিবী '
      'তোমার সঙ্গে হাসবে;)\n'
      'Weep, and you weep alone;" (কাঁদো, এবং তুমি একা কাঁদবে;")\n'
      'ii)  "Succeed and give, and it helps you live, ("সফল হও এবং দাও, '
      'এটি তোমাকে বেঁচে থাকতে সাহায্য করবে,)\n'
      'But no man can help you die." (কিন্তু কেউ তোমার মৃত্যুর সময় '
      'সাহায্য করতে পারবে না।")',
    ],
    q9: const [
      'What did Rosamond insist her mother?',
      'What was the dire necessity to Rosamond?',
      'What does the sentence "She hoped that she would be wiser in '
      'future" indicate? Write 2/3 sentences regarding this.',
      'What did Rosamond\u2019s mother ask her when they got back to '
      'the chemist\u2019s shop? What did Rosamond do?',
      'Why did people of Venice love Antonio?',
      'What did the golden casket contain?',
      'Why couldn\u2019t Shylock cut his pound of flesh from '
      'Antonio\u2019s body?',
      'Why did Bassanio go to Antonio?\n'
      '(তিনি কেন অ্যান্টনিওর কাছে গেলেন?)',
    ],
    q10Instr:
        'Read the beginning of a story below. Add at least ten new '
        'sentences to complete the story and. Give a suitable title to '
        'it :',
    q10Starter:
        'Rafi is a worker of a big factory in Dhaka. There are more '
        'than 500 workers in the factory. One day while he was working, '
        'a loud sound was heard. Fire! Fire! Help! Help!......',
    q11:
        'Imagine, you are Abid/Abida and your friend, Ratul/Rita is not '
        'interested in physical exercise. Now, write a dialogue between '
        'you and your friend about the importance of taking physical '
        'exercise.',
  ),
  // ══ 66 · SYLHET BOARD–2024 ═══════════════════════════════════════════
  EnglishFirstSet(
    serial: 66,
    board: 'Sylhet Board–2024',
    passage1Intro: 'Read the passage. Then answer the questions below.',
    passage1Unit: 'Unit–15; Lesson–2(B)',
    passage1:
        'The Internet technology has helped design a large number of web '
        'sites to facilitate social relations among people around the '
        'world. These are known as social networking services or social '
        'networks or social media. At present, Facebook is the most '
        'popular social media site. Google+, Twitter, LinkedIn, etc. are '
        'other frequently used social services. Social network services '
        'are web-based and hence, provide ways for the users to interact '
        'through the Internet. These services make it possible to '
        'connect people across the borders and thus have made the users '
        'feel that they really live in a global village.\n'
        'Why are social networks expanding so fast? The answer is '
        'simple. Most of the social services are cost-free. You can make '
        'use of them free, paying a very little to your Internet service '
        'provider. Secondly, you can make your personal profile public '
        'before the entire online community. It is like presenting '
        'yourself before the entire world. You can also look into other '
        'people\u2019s profile if you are interested. It is simple and '
        'easy. Thirdly, social networks allow users to upload pictures, '
        'multimedia contents and modify the profile. Some services like '
        'Facebook allow users to update their profiles. Fourthly, '
        'networks allow users to post blog entries. User profiles have a '
        'section dedicated to comments from friends and other users. '
        'Finally, there are privacy protection measures too. A user '
        'himself or herself decides over the number of '
        'visitors/viewers, and what information should be shared with '
        'others.',
    q1Instr: 'Choose the best answer from the alternatives.',
    q1: const [
      EF1McqItem(
          'The internet technology has —— the process of creating '
          'social networks.',
          ['slowed', 'diverted', 'accelerated', 'stopped']),
      EF1McqItem('The word \u2018interact\u2019 refers to ——.',
          ['communicate', 'internet', 'tools', 'spread']),
      EF1McqItem(
          'Which of the following has the closest meaning of the word '
          '\u2018viewer\u2019?',
          ['listener', 'speaker', 'optimist', 'spectator']),
      EF1McqItem('Which of the following statement is not true?',
          ['Most of the social services are cost-free.',
           'Google+ is more popular than Facebook.',
           'Users can find other people\u2019s profile.',
           'Friends can comment on other friend\u2019s posts.']),
      EF1McqItem('User profiles have a section for ——.',
          ['others\u2019 remarks', 'outsiders\u2019 editing',
           'outsiders\u2019 moderation', 'outsiders\u2019 uploading']),
      EF1McqItem('The word \u2018entire\u2019 can be best replaced by ——.',
          ['whole', 'fragile', 'partial', 'proportional']),
      EF1McqItem(
          'The word \u2018privacy\u2019 mentioned in the passage '
          'means ——.',
          ['publicity', 'simplicity', 'seclusion', 'suitableness']),
    ],
    q2: const [
      'What do you understand by social network?',
      'Why do people use social networks?',
      'Why are the social networks expanding so fast?',
      'How can we share our interests and activities?',
      'Do you think that social networks like Facebook play a vital '
      'role to make the world a global village? Why?',
    ],
    q3Source:
        'Pritilata Waddedar was born in Chattogram on 5 May 1911. She '
        'was a meritorious student at Dr. Khastagir Government Girls\u2019 '
        'School in Chattogram and Eden College, Dhaka. She graduated in '
        'Philosophy with distinction from Bethune College in Kolkata. In '
        'her college days, Pritilata was an activist in the anti-British '
        'movement. All through her life, she dreamt of two things : a '
        'society without gender discrimination and her motherland '
        'without British colonial rule. So, she decided to fight against '
        'the British rule. Soon after, Pritilata became the head teacher '
        'of Nandankanon Aparna Charan School in Chattogram. Gradually '
        'she involved herself in Surya Sen\u2019s armed resistance '
        'movement. Surya Sen was a famous anti-British movement '
        'organizer and revolutionary activist in Chattogram area at that '
        'time. In 1932, Surya Sen planned an attack on the Pahartali '
        'European Club. The club was well-known for its notorious sign '
        'at its entrance : Dogs and Indians not allowed. Surya Sen '
        'assigned Pritilata to lead a team of 10-12 men to attack the '
        'club. The raid was successful but Pritilata dressed as a man '
        'failed to get out of the club. She committed suicide by taking '
        'potassium cyanide to avoid arrest.',
    q3Unit: '[Unit–10; Lesson–3(B)]',
    q3Cloze:
        'Pritilata was a famous face in the history of anti-British '
        'movement. She was a brilliant student and completed her (a) —— '
        'in Philosophy from Bethune College in Kolkata. During her '
        'college days, she (b) —— part in the anti-British movement. She '
        'had two dreams : one was a society (c) —— from gender '
        'discrimination and the other was her motherland without '
        'British colonial rule. A few days later, Pritilata engaged '
        'herself in Surya Sen\u2019s armed resistance movement. In 1932, '
        'she (d) —— the Pahartali European Club in the guise of a man. '
        'The attack was successful but she committed suicide (e) —— '
        'escape arrest.',
    passage2Intro:
        'Read the following text carefully and answer the questions no. '
        '4 and 5 :',
    passage2:
        'Sher-E-Bangla is one of the most popular leaders of '
        'Bangladesh. He was born in 1873 at Chakhar in Barishal. His '
        'father Mohammad Wazed Ali was a famous lawyer. He passed the '
        'Entrance Examination and went to Calcutta for higher studies. '
        'At the age of 22 he passed the M.A and was placed in the first '
        'division. After two years, he obtained B.L. degree with '
        'distinction and joined the Bar. At the age of 33, he was '
        'appointed Deputy Magistrate. He resigned his post in 1912 due '
        'to difference of opinion with govt. In 1913, he became the '
        'member of Bengal Council. In 1915, he defeated Khaja Nazimuddin '
        'miserably in the election of Patuakhali. In 1918, he was made '
        'General Secretary of Indian Congress. In the same year he was '
        'made President of All India Muslim League. He was the Chief '
        'Minister of Bengal. In 1924, he established many educational '
        'institutions in Bengal as an Education Minister. He was the '
        'Mayor of Calcutta Corporation in 1935-36. In 1937, he was the '
        'first elected Prime Minister of Bengal. On 23rd March 1940 he '
        'proposed his historical Pakistan resolution in Lahore '
        'Conference of Muslim League. He led the United Front in the '
        'general election of East Pakistan until 1958. He died at the '
        'age of 89. People of Bangladesh remember him with gratitude.',
    q4Table: const [
      ['Biography of Sher-E-Bangla'],
      ['Known as', 'One of the greatest leaders of Bangladesh'],
      ['Life span', 'From 1873 to (i) ——'],
      ['Who', 'What', 'Event/Activity', 'When/Time', 'Where/Place',
       'Subject/Specialty'],
      ['Sher-E-Bangla', 'M.A degree', 'obtained', '(ii) ——', 'Calcutta',
       ''],
      ['He', '', '(iii) ——', '1915', 'Patuakhali', ''],
      ['He', '', 'was elected', '1937', 'Bengal', '(iv) ——'],
      ['He', '(v) ——', 'proposed', '1940', 'Lahore', ''],
    ],
    q4BoldRows: const {0, 3},
    q6A: const [
      '(a)  The role of woman in nation building',
      '(b)  It is not possible', '(c)  There was a time',
      '(d)  They were the only instrument',
      '(e)  But the outlook and attitude of the world'
    ],
    q6B: const [
      'towards women has changed', 'when women were looked',
      'cannot be denied', 'for any nation to reach its goal', 'to serve'
    ],
    q6C: const [
      'the family affairs.', 'any more in the situation of the world.',
      'with the progress of civilization.',
      'without allowing the women folk to play their active role.',
      'without any dignity and honour.'
    ],
    q7: const [
      'He said to him, "Look, my friend! Keep the money and remove your '
      'distress."',
      'So, he could not devote himself to his work.',
      'This thought kept him awake and his sleep fled away at night.',
      'Now, a new thinking took hold of the farmer.',
      'He dug a hole in his hut and kept them there.',
      'A rich man went to a farmer with fifty thousand taka in a bag.',
      'He always thought that his money could be stolen any time.',
      'He gradually realized that he had money but no peace of mind.',
    ],
    q8: const [
      'Where is our body while reading a book?\n'
      '(বই পড়ার সময় আমাদের শরীর কোথায় থাকে?)',
      'What does the poet mean by "her mind clouded so"?\n'
      '("তার মন মেঘাচ্ছন্ন হয়ে পড়ে" দ্বারা কবি কী বুঝিয়েছেন?)',
      'Did Mary return home?\n(মেরি কি বাড়ি ফিরে এসেছিল?)',
      'What do the peacocks and little boys symbolize in the poem '
      '"Time, You Old Gipsy Man"?\n("Time, You Old Gipsy Man" কবিতায় '
      'ময়ূর ও ছোটো ছেলেরা কী প্রতীকায়িত করে?)',
      'What other sounds are mentioned in the poem "Stopping by woods '
      'on a Snowy Evening"?\n("Stopping by Woods on a Snowy Evening" '
      'কবিতাটিতে আর কী কী শব্দ উল্লেখ করা হয়েছে?)',
      'What does the poet mean by "Rejoice, and men will seek you" in '
      'the poem "Solitude"?\n("Solitude" কবিতায় "আনন্দিত হলে মানুষ '
      'তোমার কাছে আসবে" দ্বারা কবি কী বুঝিয়েছেন?)',
      'How does the poet describe the world around him in the poem '
      '"O me! O Life"?\n("O me! O Life" কবিতায় কবি কীভাবে তার চারপাশের '
      'জগতের বর্ণনা দেন?)',
      'What question does the poet repeatedly ask in the poem '
      '"O me! O Life"?\n("O me! O Life" কবিতায় কোন প্রশ্ন কবি বার বার '
      'জিজ্ঞেস করেন?)',
    ],
    q9: const [
      'What sort of woman is Rosamond\u2019s mother? How can you '
      'understand it?',
      'What was the answer of Rosamond\u2019s mother about the last '
      'request of Rosamond?',
      'What made Rosamond disappointed?',
      'What type of plan did Portia\u2019s father think of finding a '
      'good husband for his daughter?',
      'How did Portia save Antonio\u2019s life?\n'
      '(পোর্শিয়া কিভাবে অ্যান্টনিওর জীবন বাঁচালেন?)',
      '"But God will only have mercy on us if we have mercy on others" '
      'What does the sentence express?',
      'Why did Shylock get a bond signed by Antonio?\n'
      '(শাইলক কেন অ্যান্টনিওর স্বাক্ষরিত চুক্তিপত্র গ্রহণ করেন?)',
      'How did Rosamond and her mother differ in their views?',
    ],
    q10Instr:
        'Read the beginning of a story and complete it in your own way. '
        'You should give a suitable title to it :',
    q10Starter:
        'Tamim, a student of class ten, was returning from school. On '
        'the way, he saw some boys and girl bathing in the pond. '
        'Suddenly he heard a girl shouting "Help! Help! save me!" '
        'Tamim.......',
    q11:
        'Suppose, you are Nabil/Nabila. You read in Blue Bird School, '
        'Sylhet. Now, write a dialogue between you and the librarian of '
        'your school about borrowing a book.',
  ),
  // ══ 67 · BARISHAL BOARD–2024 ═════════════════════════════════════════
  EnglishFirstSet(
    serial: 67,
    board: 'Barishal Board–2024',
    passage1Intro: 'Read the passage. Then answer the questions below.',
    passage1Unit: 'Unit–14; Lesson–2(B)',
    passage1:
        'Countries of the world rely heavily on petroleum, coal and '
        'natural gas for their energy sources. There are two major '
        'types of energy sources : renewable and non-renewable. '
        'Hydro-carbon or fossil fuels are non-renewable sources of '
        'energy. Reliance on them poses real big problems. First, '
        'fossil fuels such as oil, coal, gas, etc. are finite energy '
        'resources and the world eventually will run out of them. '
        'Secondly, they will become too expensive in the coming decades '
        'and too damaging for the environment. Thirdly, fossil fuels '
        'have direct polluting impacts on earth\u2019s environment '
        'causing global warming. In contrast, renewable energy sources '
        'such as, wind and solar energy are constantly and naturally '
        'replenished and never run out.\n'
        'Most renewable energy comes either directly or indirectly from '
        'the sun. Sunlight or solar energy can be used for heating and '
        'lighting homes, for generating electricity and for other '
        'commercial and industrial uses. The sun\u2019s heat drives the '
        'wind and this wind energy can be captured with wind turbines '
        'to produce electricity. Then the wind and the sun\u2019s heat '
        'cause water to evaporate. When the water vapour turns into '
        'rain or snow and flows downhill into rivers or streams, its '
        'energy can be captured as hydroelectric energy. Along with the '
        'rain and snow, sunlight causes plants to grow. Plants produce '
        'biomass which again can be turned into fuels such as fire '
        'wood, alcohol, etc that are called as bioenergy.\n'
        'Scientists have identified Hydrogen as another form of '
        'renewable energy source. It is the most abundant element in '
        'nature. But it does not exist separately as a gas. It is '
        'always combined with other elements, such as with oxygen to '
        'make water. Hydrogen, separated from another element, can be '
        'burned as a fuel to produce electricity.\n'
        'Our Earth\u2019s interior contains molten lava which gives off '
        'extreme heat. This heat inside the Earth produces steam and '
        'hot water which can be used as geothermal energy to produce '
        'electricity, for heating home, etc.\n'
        'Ocean energy comes from several sources. Ocean\u2019s force of '
        'tide and wave can be used to produce energy. The surface of '
        'the ocean gets more heat from the sun than the ocean depths. '
        'This temperature difference can be used as energy source too.',
    q1Instr: 'Choose the correct answer from the following alternatives.',
    q1: const [
      EF1McqItem('The main types of energy sources are ——.',
          ['natural and nuclear', 'renewable and non-renewable',
           'non-renewable, renewable and fossil',
           'natural and man-made']),
      EF1McqItem(
          'Which of the following has the closest meaning of the word '
          '\u2018extreme\u2019?',
          ['minimum', 'medium', 'external', 'immense']),
      EF1McqItem(
          'We should use renewable energy because it ——.',
          ['never runs out', 'finite', 'is insufficient',
           'can be damaging']),
      EF1McqItem('What can be trapped as geothermal energy?',
          ['Steam and river', 'River and hot water',
           'Steam and hot water', 'Sunlight and wind']),
      EF1McqItem(
          'Which of the following gases can be burnt to produce '
          'electricity?',
          ['Carbon di-oxide', 'Hydrogen', 'Nitrogen', 'Oxygen']),
      EF1McqItem('The word \u2018rely\u2019 refers to —— in the passage.',
          ['depend', 'separate', 'assist', 'unite']),
      EF1McqItem('Consumption of fossil fuels ——.',
          ['protects the environment', 'damages the environment',
           'creates no problem for us',
           'is unlikely to lead us towards a crisis']),
    ],
    q2: const [
      'Why will fossil fuels such as oil, coal, gas, etc. run out?',
      'What are the positive aspects of renewable energy?',
      'How does Hydrogen exist in nature?',
      'What is bioenergy? Where do we get it from?',
      '"Reliance on them poses real big problems".—How? Explain it in '
      '2/3 sentences.',
    ],
    q3Source:
        '21 February is a memorable day in our national history. We '
        'observe the day every year as International Mother Language '
        'Day. The day is a national holiday.\n'
        'On this day, we pay tribute to the martyrs who laid down '
        'their lives to establish Bangla as a state language in '
        'undivided Pakistan in 1952. The struggle to achieve our '
        'language rights is known as the Language Movement.\n'
        'The seed of Language Movement was sown on 21 March 1948 when '
        'Mohammad Ali Jinnah, the Governor General of Pakistan, '
        'declared in a public meeting in Dhaka that Urdu would be the '
        'only state language of Pakistan. The declaration raised a '
        'storm of protest all over the country. The protest continued '
        'non-stop, gathering momentum day by day. It turned into a '
        'movement and reached its climax in 1952. The government '
        'outlawed all sorts of public meetings and rallies to stop it.\n'
        'The students of Dhaka University defied the law and brought '
        'out a peaceful protest procession on 21 February 1952. When '
        'the procession reached near Dhaka Medical College, the police '
        'opened fire on the students, killing Salam, Rafiq, Barkat, '
        'Safiur and Jabbar. As a result, there were mass protests all '
        'over the country and the government had to declare Bangla as '
        'a state language. This kindled the sparks of independence '
        'movement of Bangladesh.',
    q3Unit: '[Unit–4; Lesson–3(B)]',
    q3Cloze:
        '21 February is an (a) —— day in our national history. We '
        'observe the day with a view to (b) —— respect to the language '
        'martyrs. The heroic sons of the soil sacrificed their lives '
        'for the (c) —— of Bangla as one of the state languages of '
        'Pakistan. This sacrifice led the Bangalees to the (d) —— '
        'movement of Bangladesh. In other (e) ——, language movement '
        'worked as the inspiration of our freedom.',
    passage2Intro:
        'Read the following text carefully and answer the questions '
        'no. 4 and 5 :',
    passage2:
        'William Wordsworth was born in 7 April 1770 at Cockermouth in '
        'England. He was sent to St. John\u2019s College, Cambridge in '
        '1789. Upon taking his Cambridge degree in 1791, he moved to '
        'France where he formed a passionate attachment to a French '
        'woman Annette Valon and stayed with her till 1792. '
        'Subsequently he settled down with his sister Dorothy and '
        'Coleridge at Alfoxden house near Bristol in 1792. He published '
        'Lyrical Ballads in 1798 in collaboration with Samuel Taylor '
        'Coleridge. He married in 1802. He was appointed in a sinecure '
        'office in 1813. In 1814 he published his largest poem '
        '\u2018The Excursion.\u2019 For the last fifty years of his '
        'life, he lived first at Dove Cottage, Grasmere and finally at '
        'Rydal Mount. Many of his sonnets were written during the '
        'years of 1820-1835. He died in 23 April 1850.',
    q4Instr:
        'Complete the following table with information from the passage.',
    q4Table: const [
      ['Who/What', 'Event/Activity', 'Place/Where', 'Time/When'],
      ['William Wordsworth', '(i) ——', 'at Cockermouth', 'in 1770.'],
      ['He', 'went', '(ii) ——', 'in 1789.'],
      ['He', 'lived', 'in France', '(iii) ——'],
      ['(iv) ——', 'were written', 'at Grasmere and Rydal Mount',
       'from 1820 – 1835'],
      ['William Wordsworth', 'breathed his last', '(v) ——', 'in 1850.'],
    ],
    q4BoldRows: const {0},
    q6A: const [
      '(a)  Independence', '(b)  No nation',
      '(c)  Our War of Independence',
      '(d)  People from all walks of life', '(e)  They'
    ],
    q6B: const ['fought', 'joined', 'can achieve', 'took', 'is'],
    q6C: const [
      'place in 1977.', 'face to face with the enemies.',
      'the birth right of a man.', 'the war.', 'it without struggle.'
    ],
    q7: const [
      'Then the leader of the robbers came to Saadi and ordered him to '
      'give all he had to him.',
      'They travelled for twelve days without any trouble.',
      'The merchants had their goods and a lot of money.',
      'He had a bundle of books and some money with him.',
      'On the thirteenth day a gang of robbers attacked them and took '
      'away all the goods and money from the merchants.',
      'Sheikh Saadi handed him the bundle of books and also the little '
      'money he had without any fear.',
      'Once Sheikh Saadi was going to Baghdad with a group of rich '
      'merchants.',
      'Saadi then said, "I hope that you will make the good use of '
      'these books."',
    ],
    q8: const [
      'Where is our mind while reading a book?\n'
      '(বই পড়ার সময় আমাদের মন কোথায় থাকে?)',
      'How does the poet describe the "second mother"?\n'
      '(কবি কীভাবে "দ্বিতীয় মা"-টির বর্ণনা দিয়েছেন?)',
      'How does the poet describe the foam of the sea in the Poem '
      '"The Sands of Dee"?\n("The Sands of Dee" কবিতায় কবি সমুদ্রের '
      'ফেনাকে কীভাবে বর্ণনা করেছেন?)',
      'What is the significance of "Last week in Babylon, Last night '
      'in Rome"?\n("গত সপ্তাহে ব্যাবিলনে, গতরাতে রোমে" বাক্যাংশটির '
      'তাৎপর্য কী?)',
      'What does the speaker admire about the woods?\n'
      '(কবি-জঙ্গলের কীসের প্রশংসা করেছেন?)',
      'Why does the poet say "Weep and you weep alone" in the poem '
      '"Solitude"?\n("Solitude" কবিতায় কবি কেন বলেন, "কাঁদলে তুমি একাই '
      'কাঁদবে?)',
      'Why do the mountains echo the songs that we sing but not our '
      'sighs, according to the poem "Solitude"?\n("Solitude" কবিতা '
      'অনুযায়ী পাহাড় কেন আমাদের গানগুলোর প্রতিধ্বনি করে, কিন্তু '
      'আমাদের দীর্ঘশ্বাসের নয়?)',
      'What feelings does the poem "O me! O Life" evoke?\n'
      '(কবিতাটি কি অনুভূতি জাগ্রত করেন?)',
    ],
    q9: const [
      'Do you support the attitude of Rosamond\u2019s mother that we '
      'should not buy the things which are not necessary? Why or why '
      'not? Explain in 2 or 3 sentences.',
      '"Her mind flashed back to all those beautiful things she had '
      'seen that morning." What does the writer want to indicate by '
      'this sentence? Explain in 2/3 sentences.',
      'Why do you think Rosamond often had to limp with pain?',
      'What was Antonio\u2019s business?',
      'Why did Antonio and Shylock hate each other?',
      'What does "He wanted a man to marry Portia for herself and '
      'not for her wealth" indicate?',
      'How do you evaluate the unusual plan of Portia\u2019s father?',
      'Sketch the character of Antonio.\n'
      '(অ্যান্টনিওর চরিত্র বর্ণনা কর।)',
    ],
    q10Instr:
        'Read the beginning of a story below. It is not complete. Add '
        'at least ten new sentences to complete it. Give a suitable '
        'title to it :',
    q10Starter:
        'Dilara is thirteen years old living in Swapnopur. Her poor '
        'parents have two other little children. It is hard for her '
        'illiterate parents to earn enough to run the family well. '
        'Dilara hopes to bring about a change to her family by '
        'receiving higher education. So she ......',
    q11:
        'A future plan of life helps one to reach one\u2019s goal. A '
        'student must have a definite future plan in life. Now, write '
        'a dialogue between you and your friend Sadik/Sadika about '
        'your future plan of life.',
  ),
  // ══ 68 · DINAJPUR BOARD–2024 ═════════════════════════════════════════
  EnglishFirstSet(
    serial: 68,
    board: 'Dinajpur Board–2024',
    passage1Intro: 'Read the passage. Then answer the questions below.',
    passage1Unit: 'Unit–4; Lesson–5(B)',
    passage1:
        '26 March, our Independence Day, is the biggest state festival. '
        'The day is celebrated every year in the country with great '
        'enthusiasm and fervour. It is a national holiday. All offices, '
        'educational institutions, shops and factories remain closed on '
        'this day. The day begins with a 31 gun salute.\n'
        'Early in the morning the President and the Prime Minister on '
        'behalf of the nation place floral wreaths at the National '
        'Mausoleum at Savar. Then other leaders, political parties, '
        'diplomats, social and cultural organisations, educational '
        'institutions and freedom fighters pay homage to the martyrs. '
        'People from all walks of life also go there in rallies and '
        'processions. There are many cultural programmes throughout '
        'the day, highlighting the heroic struggle and sacrifice in '
        '1971.\n'
        'In National Stadium, school children, scouts and girl guides '
        'take part in various displays to entertain thousands of '
        'spectators. Educational institutions also organise their '
        'individual programmes. Sports meets and tournaments are also '
        'organised on the day, including the exciting boat race in the '
        'river Buriganga.\n'
        'In the evening, all major public buildings are illuminated '
        'with colourful lights. Bangla Academy, Bangladesh Shilpakala '
        'Academy and other socio-cultural organisations hold cultural '
        'functions. Similar functions are also arranged in other places '
        'in the country.',
    q1Instr: 'Choose the correct answer from the following alternatives.',
    q1: const [
      EF1McqItem(
          'Very few festivals are as —— as Independence Day.',
          ['more significant', 'most significant', 'significant',
           'insignificant']),
      EF1McqItem(
          'On 26th March, people of all walks of life pay tribute to '
          'the ——.',
          ['martyrs of language movement',
           'martyrs of mass movement', 'martyrs of liberation war',
           'martyred intellectuals']),
      EF1McqItem('Various displays are arranged to —— the spectators.',
          ['irritate', 'sadden', 'amuse', 'annoy']),
      EF1McqItem('A person watching an event is called ——.',
          ['spectator', 'stranger', 'emigrant', 'participant']),
      EF1McqItem('26 March is observed in ——.',
          ['a simple way', 'a befitting manner', 'a normal way',
           'an organized way']),
      EF1McqItem(
          'Different cultural programmes of Independence Day are '
          'observed to ——.',
          ['spread cultural values around the country',
           'display different cultural activities',
           'encourage people to participate in rallies',
           'focus on the valiant struggle and sacrifice of Liberation '
           'War']),
      EF1McqItem('The phrase \u2018public holiday\u2019 means ——.',
          ['public day', 'workers holiday', 'holiday of the public',
           'national holiday']),
    ],
    q2: const [
      'What is the significance of our Independence Day?',
      'How do we pay homage to the martyrs?',
      'Who entertain thousands of spectators in National Stadium?',
      'How do you celebrate the Independence Day in your school?',
      'What are the main features of the day?',
    ],
    q3Source:
        'Fish population is in serious danger from global warming. '
        'Climate change is increasing the water temperature in rivers, '
        'lakes and seas. This means there is less food and oxygen '
        'available for fish. It also means the fish may not grow fully '
        'and may have fewer offsprings. Some fishes will become extinct '
        'if temperatures rise even by one or two degrees Celsius.\n'
        'Climate change increases the pressure on fish population. '
        'Fishes are one of the world\u2019s most valuable biological '
        'assets. Forty percent of people in the world eat fish as their '
        'main source of protein. If we fail to reduce greenhouse gas '
        'emissions, we will increase the pressure on fish. As a '
        'result, people who depend on fish will suffer from hunger and '
        'poverty.',
    q3Unit: ef1OutsideNote,
    q3Cloze:
        'It is learnt from the passage (a) —— global warming is posing '
        'a great (b) —— to fish population. Fish population is not '
        '(c) —— from the danger of climate change. It is (d) —— that '
        'some species of fishes will be extinct due (e) —— temperature '
        'rise in near future.',
    passage2Intro:
        'Read the following text carefully and answer the questions '
        'no. 4 and 5 :',
    passage2:
        'John Milton was one of the famous poets in English '
        'literature. He was born on December 9, 1608 in London. At the '
        'age of 17, he went to Cambridge University for study and '
        'after seven years of study he took MA degree from that '
        'university. The next six years he spent at Horton in '
        'unprofessional study. In 1638 he started his foreign tour. In '
        '1641 he married Mary Powell, a young girl of seventeen. But '
        'his wife died in 1652 leaving him with three daughters. So, he '
        'married second time in 1656 but two years after his second '
        'wife also died. Of all his works \u2018Paradise Lost\u2019 is '
        'said to be his greatest. He finished composing this epic in '
        '1663. But it was published four years later. By this time he '
        'lost his eyesight. At the age of 66, he died on November 8, '
        '1674.',
    q4Instr:
        'Complete the following table with information from the passage.',
    q4Table: const [
      ['Who/What', 'Year', 'Event', 'Where', 'Whom'],
      ['Milton', '(i) ——', 'born', 'London', ''],
      ['He', '', 'MA', '(ii) ——', ''],
      ['He', '1642', 'married', '', '(iii) ——'],
      ['(iv) ——', '1667', 'published', 'London', ''],
      ['Milton', '(v) ——', 'died', '', ''],
    ],
    q4BoldRows: const {0},
    q6A: const [
      '(a)  Now digital Bangladesh is not merely', '(b)  Already it',
      '(c)  Now, we perform',
      '(d)  At present trade and commerce are held',
      '(e)  The process of digitalization'
    ],
    q6B: const [
      'using internet', 'many activities through', 'has made',
      'has paved the way', 'an ambitious idea'
    ],
    q6C: const [
      'Internet, computer and mobile phone.',
      'rather it is now a reality.',
      'to build up smart Bangladesh.',
      'our life easier and more comfortable.', 'even staying home.'
    ],
    q7: const [
      'Belal\u2019s lot has changed radically.',
      'He is now very happy to be a self-sufficient man.',
      'He got a lease of land in his village.',
      'Poverty forced him to look for work.',
      'Then he joined the training programme of NHC and received '
      'training in vegetable cultivation.',
      'He has also been raising hybrid cows for milk as well as to '
      'produce manure.',
      'Belal was an unemployed youth of an impoverished family.',
      'He applied his new and improved knowledge for cultivating '
      'vegetables.',
    ],
    q8: const [
      'How does the poem "Books" describe each book?\n'
      '("Books" কবিতায় প্রতিটি বইকে কী বলে বর্ণনা করা হয়েছে?)',
      'What does "full circle" mean in the poem "Two Mothers '
      'Remembered"?\n("Two Mothers Remembered" কবিতাটিতে "পূর্ণ বৃত্ত" '
      'বলতে কী বোঝানো হয়েছে?)',
      'Where was Mary buried?\n(কোথায় মেরিকে সমাহিত করা হয়েছিল)',
      'Why does the poet call Time a "gipsy"?\n'
      '(কেন কবি সময়কে "যাযাবর" বলেছেন?)',
      "What is the significance of \"the darkest evening of the year\" "
      "in 'Stopping by Woods on a Snowy Evening'?\n"
      "(\"বছরের সবচেয়ে অন্ধকার রাত\" বাক্যাংশটির তাৎপর্য কী?)",
      'How does the world treat sorrow, according to the poet in the '
      'poem "Solitude"?\n("Solitude" কবিতায় কবির মতে, বিশ্ব দুঃখকে '
      'কীভাবে দেখে?)',
      'What is the poet\u2019s ultimate realization in the poem '
      '"O me! O Life"?\n(কবির চূড়ান্ত উপলব্ধি কী?)',
      'Do you find the answer section of the poem "O Me! O Life!" '
      'convincing?\n(ও আমি! ও জীবন! কবিতার উত্তর অংশটি কি তোমার কাছে '
      'যুক্তিসংগত মনে হয়েছে?)',
    ],
    q9: const [
      'What did Rosamond ask after seeing various things in the '
      'milliner\u2019s shop?',
      'What were the two things Rosamond wanted to buy?',
      'What was Rosamond\u2019s feeling when she bought the jar?',
      "The story 'The purple jar' tells us that all that glitters is "
      "not gold\" Explain.",
      'What would Bassanio do when he needed money?',
      'What was the conjecture of the prince of Morocco about '
      'Portia\u2019s portrait?',
      'How was the prince of Morocco misled?',
      'Why do you think the prince of Spain failed to choose the '
      'right one?',
    ],
    q10Instr:
        'Read the beginning of a story below. It is not complete. Add '
        'at least ten new sentences to complete it. Give a suitable '
        'title to it :',
    q10Starter:
        'Once there lived a poor rickshawpuller. He had to maintain '
        'his family consisting of eight members with great difficulty. '
        'One day while walking through the fields, he found a purse '
        'dropped by a passer-by. He.......',
    q11:
        'Suppose, you are Sumon/Sumona. You have a friend Rahim/Rahima. '
        'You are very interested in games and sports. Now write a '
        'dialogue between you and your friend emphasizing the '
        'importance of games and sports in our life.',
  ),
  // ══ 69 · MYMENSINGH BOARD–2024 ═══════════════════════════════════════
  EnglishFirstSet(
    serial: 69,
    board: 'Mymensingh Board–2024',
    passage1Intro: 'Read the passage. Then answer the questions below.',
    passage1Unit: 'Unit–12; Lesson–3(A)',
    passage1:
        'Michael Madhusudan Dutt was a celebrated 19th century '
        'Bangalee poet and dramatist. He was born in Sagordari on the '
        'bank of the Kopotaksho River, a village in Keshabpur Upazila '
        'under Jashore district.\n'
        'From an early age, Michael aspired to be an Englishman in '
        'form and manner. Though he was born in a sophisticated Hindu '
        'family, he converted to Christianity as a young man, much to '
        'the ire of his family, and adopted the first name Michael. In '
        'his childhood, he was recognised by his teachers as a precious '
        'child with a gift of literary talent. His early exposure to '
        'English education and European literature at home and his '
        'college inspired him to imitate the English in taste, manners '
        'and intellect.\n'
        'Since his adolescence he started believing that he was born '
        'on the wrong side of the planet, and that his society was '
        'unable to appreciate his talent. He also believed that the '
        'West would be more receptive to his creative genius.\n'
        'Madhusudan was an ardent follower of the famous English poet '
        'Lord Byron. So after adopting Christianity, he went to Europe '
        'and started composing poems and plays in English. They showed '
        'his higher level of intellectual ability. However, he failed '
        'to gain the right appreciation. To his utter frustration he '
        'found that he was not esteemed as a native writer of English '
        'literature. Out of his frustration, he composed a sonnet in '
        'Bangla "Kopotaksha Nad" which earned him huge reputation in '
        'Bangla. Gradually he could realise that his true identity lay '
        'in Bengal and he was a sojourner in Europe. Afterwards he '
        'regretted his fascination for England and the West. He came to '
        'Bengal and devoted himself to Bangla literature from this '
        'period. He has written the first Bangla epic Meghnad Badh '
        'Kabya.',
    q1Instr: 'Choose the correct answer from the following alternatives.',
    q1: const [
      EF1McqItem(
          'Michael Madhusudan Dutt was frustrated because of his ——.',
          ['being appreciated',
           'failure to gain right appreciation from the Bangalees',
           'receiving right honour',
           'not being evaluated properly by the West']),
      EF1McqItem(
          'His teachers appreciated his literary talents in ——.',
          ['school', 'college', 'youth', 'childhood']),
      EF1McqItem('—— attracted Michael in his college life.',
          ['English literature', 'Western novels', 'European culture',
           'English taste, manners and intellect']),
      EF1McqItem(
          '—— indicates Michael\u2019s higher level of intellectual '
          'ability best.',
          ['His humanitarian work', 'His adopting Christianity',
           'His literary work', 'His teacher\u2019s appreciation']),
      EF1McqItem(
          'A precious child with a gift of literary talent. Here the '
          'expression means a child ——.',
          ['devoid of literary talent',
           'with outstanding literary talent', 'with literary zeal',
           'without literary talent']),
      EF1McqItem(
          '\u2018He converted to Christianity as a young man, much to '
          'the ire of his family.\u2019 Here the word \u2018ire\u2019 '
          'means ——.',
          ['desire', 'consent', 'anger', 'passion']),
      EF1McqItem(
          'The main purpose of the author of this passage is ——.',
          ['to sketch Michael\u2019s life',
           'to show Michael\u2019s migration',
           'to state Michael\u2019s literary talent',
           'to highlight Michael\u2019s conversion to Christianity']),
    ],
    q2: const [
      'Who was Michael Madhusudan Dutt?',
      'What was the ambition of Michael in early age?',
      'Why did Michael start writing in Bangla?',
      'When did Michael compose Kopotaksho Nad?',
      'Why did Michael realize himself as a sojourner in Europe?',
    ],
    q3Source:
        'We have the ability to bring about a great change in our '
        'social, national and international life. But we cannot change '
        'everything. For example, humans can neither change the '
        'sun\u2019s radiation nor the earth\u2019s orbit around the '
        'sun. Rather we can control the increase in the amount of '
        'greenhouse gases and its effect on the atmosphere. It is a '
        'matter of great sorrow that only during the last hundred '
        'years the carbon dioxide concentration has been raised '
        'alarmingly in the atmosphere and we humans can be held '
        'responsible for this. Carbon dioxide level is increasing '
        'mainly for the burning of fossil fuels. Since the end of the '
        '19th century, industrial activities increased rapidly giving '
        'rise to many factories. These factories required energy, '
        'which was produced through the combustion of coal and other '
        'energy sources such as mineral oil and natural gas which were '
        'also burned to heat our houses, run cars and airplanes or to '
        'produce electricity. Nowadays, about 85 million barrels of '
        'crude oil are burned daily. Every time a fossil raw material '
        'is burned, it releases carbon dioxide into the air. Thus, we '
        'are generating more and more greenhouse gases worldwide.',
    q3Unit: '[Unit–2; Lesson–3(A)]',
    q3Cloze:
        'It is true that most of the natural phenomena are beyond our '
        'control, yet we can (a) —— some aspects like the greenhouse '
        'effect by our responsible activities. We are highly '
        'responsible for (b) —— radical climate change. Carbon dioxide '
        'is the main (c) —— of climate change. Carbon dioxide is being '
        '(d) —— in the atmosphere by the burning of fossil fuels. '
        'Moreover, mineral oil and natural gas are also used for '
        'various (e) ——.',
    passage2Intro:
        'Read the following text carefully and answer the questions '
        'no. 4 and 5 :',
    passage2:
        'The great men were born in different places of the world but '
        'their activities make them familiar and closer to us. Dr. '
        'Muhammad Shahidullah was one of those who contributed a lot '
        'towards Bangla language and literature. He was one of the '
        'greatest scholars of Bengal of his time. This great scholar '
        'was born on July, 1885 at 24 Pargonas in West Bengal, India. '
        'He passed his Entrance examination in 1904 and obtained his '
        'B.A. degree six years later. It took him two years to '
        'complete his M.A. and another two years for his Bachelor of '
        'Law Degree. He later joined the University of Dhaka in 1921 '
        'as a Professor of Sanskrit and Bengali. He was awarded the '
        'Doctorate Degree from Sorbonne University, Paris in 1928. '
        '"Bangla Shahitter Katha", the first well-arranged history of '
        'Bengali literature was composed by him and it was published '
        'in 1953. This great scholar remained busy with his work till '
        'he became seriously ill in 1967 and was confined to bed for '
        'about two and a half years. Dr. Shahidullah breathed his last '
        'on July \u201913, 1969 in Dhaka.',
    q4Instr:
        'Complete the following table with information from the passage.',
    q4Table: const [
      ['Dr. Muhammad Shahidullah'],
      ['Speciality', 'Great contribution to Bengali literature'],
      ['Time', 'Dr. Muhammad Shahidullah was born in (i) ——'],
      ['Who/ What', 'Event/ Activity', 'When', 'Where'],
      ['Dr. Muhammad Shahidullah', 'obtained BA degree', '(ii) ——', ''],
      ['He', 'joined as a Professor', 'in 1921', '(iii) ——'],
      ['He', '(iv) ——', 'in 1928', 'Sorbonne University, Paris'],
      ['(v) ——', 'was published', 'in 1953', ''],
    ],
    q4BoldRows: const {0, 3},
    q6A: const [
      '(a)  The present world is becoming',
      '(b)  Now a man from one part of the world',
      '(c)  Internet communication',
      '(d)  A man can make friendship',
      '(e)  A student sitting in the reading room'
    ],
    q6B: const [
      'is the latest invention', 'with anybody in any place',
      'can communicate with a person of another part',
      'can use the London Library', 'smaller day by day'
    ],
    q6C: const [
      'and collect various information.',
      'with the blessings of science.',
      'in a second through the Internet.',
      'in the communication system.',
      'or even a person can choose life partner through the Internet.'
    ],
    q7: const [
      'He got a lease of land in his village.',
      'As a result, his lot has been changed radically.',
      'Poverty forced him to look for work.',
      'He has also been raising hybrid cows for milk and manure.',
      'Shamim was an unemployed youth of an impoverished family.',
      'So, he joined the training in vegetable cultivation.',
      'He is now very happy to be a self-sufficient man.',
      'He applied his new and improved knowledge for cultivating '
      'vegetables.',
    ],
    q8: const [
      'What can a child do with a book according to the peom?\n'
      '(কবিতাটি অনুযায়ী একটি শিশু বইয়ের সাথে কী করতে পারে?)',
      'Why does the poet refer to herself as the strength of her '
      'mother?\n(কবি নিজেকে তার মায়ের শক্তি হিসেবে উল্লেখ করেছেন কেন?)',
      'What do the boatman still hear in the Poem "The Sands of Dee"?\n'
      '("The Sands of Dee" কবিতায় নৌকার মাঝিরা এখনও কী শুনতে পায়?)',
      'What does the caravan represent in the poem "Time, You Old '
      'Gipsy Man"?\n("Time, You Old Gipsy Man" কবিতায় কাফেলা কীসের '
      'প্রতিনিধিত্ব করে?)',
      'Why does the poet describe Time as tightening its rein?\n'
      '(কবি সময়কে লাগাম টানার মতো করে বর্ণনা করেছেন কেন?)',
      'What does the horse\u2019s reaction symbolize in Stopping by '
      'Woods on a Snowy Evening?\n(ঘোড়ার প্রতিক্রিয়া কী প্রতীকায়িত '
      'করে?)',
      'According to the peom "Solitude", what do people seek from you '
      'when you are successful?\n("Solitude" কবিতায় যখন তুমি সফল হও, '
      'তখন মানুষ তোমার কাছে কী চায়?)',
      'What is the main theme of the poem "O Me! O Life!"?\n'
      '("O me! O Life" কবিতাটির মূল ভাব কী?)',
    ],
    q9: const [
      'How were the windows of the milliner\u2019s shop decorated?',
      'What was Rosamond\u2019s last request to her mother?',
      '"She was to cry more for her folly." What does the writer want '
      'to mean?',
      'Why did Rosamond suffer for a whole month?',
      'Why didn\u2019t Antonio have much money with him?',
      'What is the reason of Bassanio\u2019s choosing the right casket?',
      'What does "Antonio must pay the penalty written in the bond" '
      'indicate?',
      'How could you say that Antonio was the best friend of Bassanio?',
    ],
    q10Instr:
        'Read the beginning of a story below. It is not complete. Add '
        'at least ten new sentences to complete it. Give a suitable '
        'title to it :',
    q10Starter:
        'A long time ago, the town of Hamelin faced with a great '
        'problem. It became full of rats. The situation became very '
        'unbearable .....',
    q11:
        'Suppose, you are Tanveer/Tanisa. You have a friend named '
        'Habib/Habiba who is fond of trees and nature. Now, write a '
        'dialogue between you and your friend about the importance of '
        'tree plantation.',
  ),
];

// ════════════════════════════════════════════════════════════════════════
//  🔀 English First Paper MIXER
//  প্রতিটি প্রশ্ন-গ্রুপ (passage1+Q1-Q2, Q3-cloze, passage2+Q4-Q5, Q6..Q11)
//  আলাদা আলাদা বোর্ড থেকে — passage ও তার প্রশ্নগুলো একই সেটের থাকে।
// ════════════════════════════════════════════════════════════════════════
class MixedFirstPaper {
  final EnglishFirstSet set;
  final List<int> sources; // ৯টি গ্রুপের উৎস-সিরিয়াল
  const MixedFirstPaper(this.set, this.sources);
}

class EnglishFirstMixer {
  EnglishFirstMixer._();

  static MixedFirstPaper mix({Random? rng}) {
    rng ??= Random();
    EnglishFirstSet pick() =>
        englishFirstSets2024[rng.nextInt(englishFirstSets2024.length)];
    final g = List<EnglishFirstSet>.generate(9, (_) => pick());
    final set = EnglishFirstSet(
      serial: 0,
      board: 'Mixed Board Set–2024',
      passage1Intro: g[0].passage1Intro,
      passage1Unit: g[0].passage1Unit,
      passage1: g[0].passage1,
      q1Instr: g[0].q1Instr,
      q1: g[0].q1,
      q2: g[0].q2,
      q3Instr: g[1].q3Instr,
      q3Source: g[1].q3Source,
      q3Unit: g[1].q3Unit,
      q3Cloze: g[1].q3Cloze,
      passage2Intro: g[2].passage2Intro,
      passage2: g[2].passage2,
      q4Instr: g[2].q4Instr,
      q4Table: g[2].q4Table,
      q4BoldRows: g[2].q4BoldRows,
      q6A: g[3].q6A,
      q6B: g[3].q6B,
      q6C: g[3].q6C,
      q7: g[4].q7,
      q8: g[5].q8,
      q9: g[6].q9,
      q10Instr: g[7].q10Instr,
      q10Starter: g[7].q10Starter,
      q11: g[8].q11,
    );
    return MixedFirstPaper(set, g.map((e) => e.serial).toList());
  }
}
