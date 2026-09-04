import 'dart:math';

/// English (Compulsory) — Second Paper : Board Questions 2024.
///
/// Transcribed SAME-TO-SAME from the teacher's scanned board-question book
/// (Model Questions Based on Board Exam Questions [Paper-II], sets 51–59).
/// Layout (word boxes, 3-column matching tables, item letters) is preserved
/// exactly as printed; rendered via EnglishPaperAdapter + services/paper_pdf.dart.

/// One row of a Q2 three-column matching table. Empty cells stay ''.
class EBMatchRow {
  final String a, b, c;
  const EBMatchRow(this.a, this.b, this.c);
}

/// One Q4 item: sentence + transformation direction, e.g. (Assertive).
class EBTransformItem {
  final String sentence, direction;
  const EBTransformItem(this.sentence, this.direction);
}

/// One full board set (Part–A Grammar 60 + Part–B Composition 40).
/// Q6 root words are wrapped in {braces} → rendered bold + underlined.
class EnglishBoardSet {
  final int serial; // 51–59 as printed in the book
  final String board; // e.g. 'Dhaka Board–2024'
  final List<String> headerExtra; // extra centred lines under the banner
  final List<String> q1Box;
  final String q1Passage;
  final List<EBMatchRow> q2;
  final List<String> q3Box;
  final String q3Passage;
  final List<EBTransformItem> q4;
  final List<String> q5; // statements (a)–(e), trailing comma kept
  final String q6Passage; // {root} markers
  final String q7Passage;
  final String q8Passage;
  final String q9Text;
  final String q10, q11, q12; // composition prompts (10, 10, 20)

  const EnglishBoardSet({
    required this.serial,
    required this.board,
    this.headerExtra = const [],
    required this.q1Box,
    required this.q1Passage,
    required this.q2,
    required this.q3Box,
    required this.q3Passage,
    required this.q4,
    required this.q5,
    required this.q6Passage,
    required this.q7Passage,
    required this.q8Passage,
    required this.q9Text,
    required this.q10,
    required this.q11,
    required this.q12,
  });
}

// ── Fixed instructions / labels, common to every set ─────────────────────
const String ebBengaliNote =
    '[বি.দ্র. : প্রশ্নটি পরিবর্তিত মানবণ্টন অনুযায়ী পরিমার্জন করা হয়েছে।]';

const String ebInstrQ1 =
    'Fill in the blanks with the words from the box: You may need to change '
    'the forms of some of the words. You may need to use one word more than once.';
const String ebInstrQ2 =
    'Make five sentences using parts of sentences from each column of the table below.';
const String ebInstrQ3 =
    'Complete the following text with right forms of the verbs given in the box.';
const String ebInstrQ4 = 'Change the sentences according to directions.';
const String ebInstrQ5 = 'Make tag questions of these statements.';
const String ebInstrQ6 =
    'Complete the text adding suffixes, prefixes or the both with the root '
    'words given in the parenthesis.';
const String ebInstrQ7 = 'Fill in the blanks with prepositions.';
const String ebInstrQ8 = 'Complete the passage using suitable connectors.';
const String ebInstrQ9 =
    'Use capitals and punctuation marks where necessary in the following text.';

const String ebPartAHeader = 'Part–A : Grammar [60 Marks]';
const String ebPartBHeader = 'Part–B : Composition [40 Marks]';

/// The 9 board sets (2024), in the book's order 51–59.
final List<EnglishBoardSet> englishBoardSets2024 = [
  // ══ 51 · DHAKA BOARD–2024 ═════════════════════════════════════════════
  EnglishBoardSet(
    serial: 51,
    board: 'Dhaka Board–2024',
    headerExtra: const [
      'English (Compulsory)–Second Paper',
      'Full Marks : 100          Time : 3 hours',
    ],
    q1Box: const [
      'gentle', 'by', 'the', 'big', 'way', 'of', 'visit', 'hills', 'nature'
    ],
    q1Passage: 'The Kaptai Lake is located in the hilly district of Rangamati. '
        'This is the (a) ________ lake in Bangladesh. The (b) ________ beauty of '
        'this lake is well-known to all. This huge lake stretches for miles '
        'touching different parts (c) ________ Rangamati district. There are rows '
        'of high mountains all around. Between the hills flows the lake water in '
        'a zigzag (d) ________. The bottoms of the (e) ________ are submerged in '
        'water. When we look at them from a distance, it seems that (f) ________ '
        'hills are floating on water. Being attracted (g) ________ its '
        'captivating natural beauty, every year a great number of nature lovers '
        '(h) ________ it. There is an arrangement for boat journey as well. '
        'A number (i) ________ colourful boats are ready to welcome the '
        'tourists. A (j) ________ breeze is always blowing. It cools the '
        'tourists and soothes their minds.',
    q2: const [
      EBMatchRow('(a)  Good health', 'does not mean',
          'a vital role in attaining this wealth.'),
      EBMatchRow('(b)  Bulky body', 'makes',
          'the soundness of both body and mind.'),
      EBMatchRow('(c)  To be a healthy men one', 'leads',
          'our life happy and enjoyable'),
      EBMatchRow('(d)  Food habit', 'should have', 'an unhappy life.'),
      EBMatchRow('(e)  An unhealthy man', 'plays', 'good health.'),
    ],
    q3Box: const [
      'entertain', 'make', 'order', 'want', 'need',
      'wish', 'become', 'be', 'take', 'arrive'
    ],
    q3Passage: 'A birthday party is arranged to celebrate the day when one was '
        'born. It (a) ________ a happy occasion. Recently it (b) ________ a '
        'tradition to organize a birthday party. For organizing such a party, '
        'one (c) ________ to spend both time and money. He/she starts (d) '
        '________ preparation from some days ago. A birthday cake (e) ________ '
        'earlier. Then, he/she invites his/her close friends and relatives. '
        'Usually friends (f) ________ to miss such a party. On the appointed '
        'day, he/she puts on the best dress and eagerly waits for the invited '
        'guests to (g) ________. After the arrival of the guests, he/she cuts '
        'the birthday cake. By singing happy birthday to you, everybody (h) '
        '________ him/her. The guests are highly (i) ________ with delicious '
        'foods and snacks. Sometimes there is arrangement for music with a view '
        'to (j) ________ the party more enjoyable.',
    q4: const [
      EBTransformItem('How charming a moonlit night is!', 'Assertive'),
      EBTransformItem('It presents a very beautiful sight.', 'Exclamatory'),
      EBTransformItem('It dazzles our eyes and soothes our heart.', 'Negative'),
      EBTransformItem(
          'People of all ages enjoy a moonlit a night.', 'Interrogative'),
      EBTransformItem(
          'Little boys and girls make merriment to enjoy themselves.',
          'Complex'),
      EBTransformItem('Everybody likes a moonlit night.', 'Interrogative'),
      EBTransformItem(
          'Though the moon gives us light, it does not have the light of its '
          'own.',
          'Compound'),
      EBTransformItem(
          "Doesn't the moon borrow light from the sun?", 'Assertive'),
      EBTransformItem(
          'Unless one enjoys the beauty of a moonlit night, one cannot explain '
          'it properly.',
          'Simple'),
      EBTransformItem('In fact, a moonlit night is very pleasant.', 'Negative'),
    ],
    q5: const [
      'Many people hanker after money,',
      'But money is not as valuable as morality,',
      'Let us always keep this truth in mind,',
      'Money can hardly bring happiness,',
      'So, we should never have greed for money,',
    ],
    q6Passage: 'Books are our best friends. They introduce us to the realm of '
        '(a) {limited} knowledge. The books of great writers contain noble '
        'thoughts and great ideas. We can (b) {rich} our mind by reading books. '
        'The reading of books brings perfection. No spiritual progress and '
        'worldly (c) {prosper} can be imagined without reading books. (d) '
        '{true} speaking, reading books is such a thing which has no '
        'alternative. So, we should read books on (e) {vary} topics so that we '
        'may bring proper development of our spirit.',
    q7Passage: "Students teachers' relationship is regarded as the relationship "
        '(a) ________ parents and children. A teacher is next (b) ________ '
        'parents. Parents bring up children. On the other hand, a teacher '
        'guides the students to materialize their dreams. A teacher spreads the '
        'light of education to remove the darkness (c) ________ ignorance. As '
        'a result, a student can see the path of prosperity. Thus a teacher '
        'helps build (d) ________ a civilized nation. So he is really called '
        'the architect (e) ________ a nation.',
    q8Passage: 'It is known to all (a) ________ gold is a valuable metal. There '
        'are many metals cheaper than gold though they look like it. (b) '
        '________ they glitter for sometimes, they fade away in the long run. '
        'In our society there are also many people (c) ________ are outwardly '
        'very gentle and polished. Later on, their real identity is revealed '
        '(d) ________ they do not exercise moral value. That\u2019s why people '
        'say, "All (e) ________ glitters is not gold."',
    q9Text:
        'what kind of stories did Aesop tell said Abdullah fables replied mr '
        'rahman do you know what fables are no replied abduallah well continued '
        'mr rahman fables are stories with a message or a moral',
    q10: "Write a paragraph on 'The Life of a Farmer'.",
    q11: 'Suppose, you are Shuvo/Sova, a student of class IX. Your school is a '
        'reputed school but there is no canteen in your school. Now, write an '
        'application to the Headmaster of your school for setting up a canteen '
        'in your school.',
    q12: "Write a composition about 'The Importance of Reading Newspaper.'",
  ),
  // ══ 52 · RAJSHAHI BOARD–2024 ═══════════════════════════════════════════
  EnglishBoardSet(
    serial: 52,
    board: 'Rajshahi Board–2024',
    q1Box: const [
      'give', 'a', 'evil', 'contrary', 'from',
      'enough', 'justice', 'ensure', 'deeds', 'result'
    ],
    q1Passage: 'Self purification means to keep the soul free (a) ________ all '
        'kinds of sins as well as from (b) ________ deeds. This divine quality '
        'is (c) ________ must in our every day life. Only physical priority is '
        'not (d) ________, mental purity should be (e) ________ more priority. '
        'Self purification inspires one to do good (f) ________. On the (g) '
        '________ a bad man indulges in various sinful thoughts and deeds. He '
        'does not hesitate to do (h) ________ or any wrong doing. As a (i) '
        '________, social peace and order are disturbed. So the usefulness of '
        'self purification is undeniable for (j) ________ peace and harmony in '
        'the society.',
    q2: const [
      EBMatchRow('(a)  Global warming', 'is rising', 'mainly responsible for it.'),
      EBMatchRow('(b)  Irresponsible activities of human beings', 'refers',
          'due to global warming.'),
      EBMatchRow('(c)  Sea level', 'is',
          'to the increase in the temperature of the globe.'),
      EBMatchRow('(d)  As a result, the coastal areas', 'can reduce',
          'to be vulnerable.'),
      EBMatchRow('(e)  Using of renewable energy', 'are going',
          'temperature rise to a great extent.'),
    ],
    q3Box: const [
      'throw', 'kill', 'work', 'have', 'release',
      'ensure', 'be', 'live', 'originated', 'pollute'
    ],
    q3Passage: 'Rivers generally (a) ________ from a mountain or a lake. They '
        '(b) ________ very much important for our existence and economy. But '
        'unfortunately we are (c) ________ our rivers by throwing industrial '
        'and domestic wastes. Most of the industries (d) ________ waste '
        'treatment plants. These kinds of industries are (e) ________ liquid '
        'wastes directly and continuously (f) ________ the water. Our '
        'unconscious people also (g) ________ different kinds of waste '
        'materials into rivers. So, to keep the existence of fishes and other '
        'species (h) ________ in the water is impossible. It is high time the '
        'government and the people (i) ________ together to save the rivers. '
        'Otherwise a happy, prosperous and pollution free environment can\u2019t '
        'be (j) ________ for the next generation.',
    q4: const [
      EBTransformItem('Nothing is more useful in nature than water.',
          'Affirmative'),
      EBTransformItem('It is a very important asset.', 'Exclamatory'),
      EBTransformItem(
          'We cannot pass a single day without water.', 'Interrogative'),
      EBTransformItem(
          'Its main source is the rain that creates streams, lakes and rivers.',
          'Compound'),
      EBTransformItem('We have rain during the monsoon.', 'Complex'),
      EBTransformItem('Heavy rainfall often causes flood.', 'Complex'),
      EBTransformItem('Crops get damaged.', 'Interrogative'),
      EBTransformItem('Our winter is dry and rainless.', 'Negative'),
      EBTransformItem('Does rainless winter bring good harvest?', 'Assertive'),
      EBTransformItem(
          'We can grow more crops if we can make the best use of rain.',
          'Simple'),
    ],
    q5: const [
      'Bangladesh came into being at the cost of a bloody war,',
      'So, everyone has some duties and responsibilities to this country,',
      'As a citizen of this country, we can hardly forget our duties,',
      'I am proud to be a citizen of this country,',
      'Let us work together to build up our country,',
    ],
    q6Passage: "The nature of mother's love is the same in all countries. It is "
        '(a) {universe}. For our existence on earth, we (b) {great} owe to our '
        'father and mother, specially to our mother. A mother\u2019s love is '
        '(c) {parallel} and unique. A child\u2019s relation with its mother is '
        '(d) {heaven} and spiritual. We can (e) {hard} see a mother '
        'indifferent to her children.',
    q7Passage: 'The Padma multi-purpose bridge has started a new era (a) '
        '________ the history of Bangladesh. This mega project has been '
        'implemented (b) ________ any foreign aid. The southern 21 districts '
        'were cut off from the main-land (c) ________ the mighty Padma river. '
        'So, this vast area could not keep pace with the other parts '
        'considering economic development. But direct connection (d) ________ '
        'the capital by this bridge is going to expand trade and commerce. '
        'Besides, tourism is also going to speed up. All these are '
        'contributing much (e) ________ our economic growth and surely reduce '
        'the poverty of those districts. The construction of the bridge which '
        'was our long-cherished dream at last came true.',
    q8Passage: 'Facebook is a social medium (a) ________ is very popular. (b) '
        '________ it provides the users with various information, all do not '
        'use it for positive purposes. Many Facebook users (c) ________ some '
        'of the youngsters sometimes use it whimsically which creates (d) '
        '________ misunderstanding (e) ________ destroys social peace and '
        'order.',
    q9Text:
        'do you know me yes i know you from my childhood, whats your name my '
        'name is sumon thank you a lot said mr Jamal.',
    q10: 'Write a paragraph on "Our National Flag".',
    q11: 'Suppose, one of your friends borrowed one of your important books. '
        'Your exam is near at hand now. So you need the book urgently. Now, '
        'write an email to your friend asking him to return the book in no '
        'time.',
    q12: 'Write a composition on "Your Favourite Hobby".',
  ),
  // ══ 53 · JASHORE BOARD–2024 ════════════════════════════════════════════
  EnglishBoardSet(
    serial: 53,
    board: 'Jashore Board–2024',
    q1Box: const [
      'common', 'the', 'possible', 'of', 'by',
      'language', 'in', 'medium', 'with', 'them'
    ],
    q1Passage: 'Language is the means (a) ________ which we share our thoughts '
        'and ideas (b) ________ others. It is our primary (c) ________ of '
        'communication. There are thousands of (d) ________ in the world but it '
        'is (e) ________ for a person to learn (f) ________ all. English is '
        '(g) ________ language of international communication. It is the most '
        '(h) ________ used language in the world. It also plays an essential '
        'role (i) ________ our lives. So, the importance (j) ________ learning '
        'English cannot be ignored.',
    q2: const [
      EBMatchRow('(a)  A man without an aim', 'be', 'a definite aim.'),
      EBMatchRow('(b)  So, everybody', 'becomes',
          'more difficult than the choice of a profession.'),
      EBMatchRow('(c)  But nothing', 'should have',
          'like a ship without a rudder.'),
      EBMatchRow('(d)  Because there', '', 'very difficult for a student.'),
      EBMatchRow('(e)  That is why, to choose a profession', '',
          'many paths and courses open to all.'),
    ],
    q3Box: const [
      'focus', 'follow', 'control', 'wait', 'write',
      'understand', 'read', 'upgrade', 'play', 'be'
    ],
    q3Passage: 'Text books are the rich sources of information and knowledge. '
        'They (a) ________ a vital role in teaching-learning activities. If a '
        'student (b) ________ the text books thoroughly, he/she can get a clear '
        'idea about different topics. In the class room, teachers (c) ________ '
        'on the texts well. Unfortunately, some students (d) ________ the '
        'importance of reading text books. Again, in many schools guide books '
        'are (e) ________ in the class room. The concerned authority should '
        'monitor the class rooms with a view to (f) ________ this unexpected '
        'activity. Besides, teachers (g) ________ conscious of their duties and '
        'responsibilities. A strong foundation of knowledge is impossible '
        'without reading the text books well. These living sources of knowledge '
        '(h) ________ by the highly qualified educationists. The government is '
        'working relentlessly to (i) ________ the standard of the text books. '
        'The nation (j) ________ eagerly for the days when our students will '
        'lead Bangladesh applying their knowledge, skill and wisdom.',
    q4: const [
      EBTransformItem('Water is a liquid substance.', 'Interrogative'),
      EBTransformItem('What an useful element it is in our daily life?',
          'Assertive'),
      EBTransformItem('We drink water to satisfy our thirst.', 'Complex'),
      EBTransformItem('We get water from many sources.', 'Interrogative'),
      EBTransformItem('Surface water is not safe for drinking.', 'Affirmative'),
      EBTransformItem(
          'We can drink water from sources like tube-well and fountain.',
          'Compound'),
      EBTransformItem('Polluted water is very dangerous for our life.',
          'Exclamatory'),
      EBTransformItem(
          'If we throw wastage and dirts into water, we make it polluted.',
          'Simple'),
      EBTransformItem('We should drink nothing but pure water.', 'Affirmative'),
      EBTransformItem('Who can live without water?', 'Negative'),
    ],
    q5: const [
      'Patriotism persuades a man to do everything just,',
      'A patriot hardly fears anybody,',
      'Everybody respects a patriot,',
      'What an outstanding quality it is!',
      "Let's be patriots,",
    ],
    q6Passage: 'A computer consists of both hardwares and softwares. The (a) '
        '{touch} components are called hardwares. On the other hand the '
        'untouchable programmes are called softwares. Hardwares and softwares '
        'are interdependent. Without one, the other is (b) {value}. Software '
        'designers are called software engineers. Software engineering is a '
        '(c) {demand} subject in a university. A well designed software can '
        'solve any problem. Business organizations including banks are '
        'completely dependent on softwares. In fact, office (d) {manage} '
        'can\u2019t be thought of without the application of proper softwares. '
        'For the development of our software industry, the government has '
        'already set up a number of high-tech parks. Our software engineers '
        'are working (e) {restless} to develop newer softwares to make our '
        'life easy and comfortable.   [JB \u201924]',
    q7Passage: 'The earth is a vast planet. It is round in shape. One third of '
        'its total area is land while the other three portions are covered (a) '
        '________ water. The water areas are divided (b) ________ oceans, seas '
        'and rivers. The surface of the land area is full of variety. There '
        'are high hills, green forests and stretches of deserts. The land mass '
        'is divided into some continents. Under each continent, there are a '
        'number of countries. The interior of the earth is abundant in mineral '
        'resources. There is existence of life only (c) ________ the earth. '
        'But, this existence of life would be impossible (d) ________ '
        'sunlight. In fact, sunlight is the prerequisite (e) ________ the '
        'existence of all types of living beings.',
    q8Passage: 'We know that trees are very important (a) ________ they produce '
        'oxygen (b) ________ is a must for all living creatures. They are our '
        'best friends (c) ________ we are not conscious of it. Time is coming '
        '(d) ________ there will be no tree left for us. (e) ________, we '
        'should plant more and more trees for our own sake.',
    q9Text: "won't you go to school today raju he said dad i feel feverish i "
        'dont want to go to school ok take rest now said he.',
    q10: 'Write a paragraph on "A School Magazine".',
    q11: 'Imagine that one of your school friends is in England for six months. '
        'He/She is having some troubles with the new place and the new food. '
        'Write a letter advising him/her on how to adjust the new place and '
        'the new food.',
    q12: 'Write a composition on "The Season You Like Most".',
  ),
  // ══ 54 · CUMILLA BOARD–2024 ═══════════════════════════════════════════
  EnglishBoardSet(
    serial: 54,
    board: 'Cumilla Board–2024',
    q1Box: const [
      'nutrition', 'normal', 'illiterate', 'grow', 'ability',
      'malnutrition', 'due', 'rapid', 'aware', 'nutrition'
    ],
    q1Passage: 'Adolescence or puberty is a period after childhood. During this '
        'period physical and mental (a) ________ of boys and girls is so (b) '
        '________ that they need proper amount of (c) ________ food. But many '
        'boys and girls are not (d) ________ of this fact. So often they '
        'suffer from (e) ________ which hampers their (f) ________ growth. '
        'Even some parents do not have the (g) ________ to provide their '
        'children with the (h) ________ they need. Sometimes it happens (i) '
        '________ to the parents\u2019 reluctance, unawareness or (j) ________.',
    q2: const [
      EBMatchRow('Physical fitness', '', 'physical exercise regularly.'),
      EBMatchRow('Physical exercise', 'is',
          'a precondition to lead a healthy life.'),
      EBMatchRow('People of all ages', 'take',
          'essential for achieving physical fitness.'),
      EBMatchRow('Many changes', 'should take', 'a balanced diet.'),
      EBMatchRow('Beside physical exercise, everybody', '',
          'place inside body due to physical exercise.'),
    ],
    q3Box: const [
      'ensure', 'create', 'waste', 'divide', 'remain',
      'do', 'appear', 'save', 'execute', 'end'
    ],
    q3Passage: 'Proper time management makes it possible to complete any work '
        'timely. If a person (a) ________ his works into smaller portions and '
        '(b) ________ them accordingly, the whole work will be (c) ________ in '
        'time. Time is not (d) ________ because of doing the work in a planned '
        'way. As a result, enough time (e) ________. Besides proper use of '
        'time (f) ________ by doing the work in this process. As each piece of '
        'work (g) ________ quickly, opportunity to do additional works (h) '
        '________. Again due to time management, no part of work (i) ________ '
        'difficult and no work (j) ________ pending.',
    q4: const [
      EBTransformItem('We need strategy for the examination.', 'Interrogative'),
      EBTransformItem('Elaborating answer in the exam is very unnecessary.',
          'Exclamatory'),
      EBTransformItem(
          'When a student gets the question paper, he should read it '
          'attentively.',
          'Simple'),
      EBTransformItem('Initially the questions may seem difficult.', 'Negative'),
      EBTransformItem(
          'A student should try to answer all the questions to do good in the '
          'exam.',
          'Complex'),
      EBTransformItem(
          'If a student answers all the questions correctly, he will get good '
          'marks.',
          'Simple'),
      EBTransformItem('A student should not write irrelevant answers.',
          'Affirmative'),
      EBTransformItem(
          'How irritated the examiners become to see such irrelevant answers!',
          'Assertive'),
      EBTransformItem('The examinee should not waste time by doing so.',
          'Interrogative'),
      EBTransformItem(
          'By following the process, every student can achieve a good result '
          'in an examination.',
          'Negative'),
    ],
    q5: const [
      'Slow and steady wins the race,',
      'The mother has risen in her to see the orphan,',
      'He hardly cast a vote for me,',
      'Kindly do me a favour,',
      'I need not go there,',
    ],
    q6Passage: 'The other name of water is life. Clean water is (a) {drink}. '
        'Dirty water is unsafe. Clean water is (b) {contaminate} and suitable '
        'for drinking. Bangladesh is a (c) {river} country. But we get '
        'inadequate water for use. The water of most of our rivers is (d) '
        '{filth} and poisonous. We should keep surface water clean for our '
        'health and (e) {long}. The government should play an active role to '
        'keep water safe.',
    q7Passage: 'Man is a social being. So he lives (a) ________ a society. '
        'Mutual understanding and cooperation are needed to ensure a peaceful '
        'society. To produce ideal members (b) ________ a society, an ideal '
        'family contributes a lot. A child\u2019s future behaviour is greatly '
        'influenced (c) ________ the culture of his family. If a child is born '
        'and brought (d) ________ in a rude and chaotic environment, he also '
        'becomes rude (e) ________ behaviour and creates chaos and '
        'indiscipline in the society.',
    q8Passage: 'It is known to all (a) ________ about half of our population '
        'are women. They are entitled to equal rights and privileges (b) '
        '________ men enjoy. (c) ________ in reality, they do not get their '
        'dues. For the true development of our country, they should be given '
        'proper education and training. (d) ________ every woman is a '
        'potential mother and her influence on her children is very great. '
        '(e) ________, we should pay proper attention to our women folk.',
    q9Text: 'how dare you wake me up the lion roared i shall kill you for that '
        'please let me go the mouse cried.',
    q10: 'Write a paragraph on "Environment Pollution" in about 250 words.',
    q11: 'Suppose, you are Milon/Mili, a student of Pragati Bidya Niketon, '
        'Jhenidah. Your school needs a multimedia classroom with internet '
        'facilities, as technology is an integral part of modern education. '
        'Now, write an application to your Headmaster on behalf of all the '
        'students of the school requesting him to take necessary steps for '
        'setting up a multimedia classroom with internet facility in your '
        'school.',
    q12: 'Write a composition on "A Journey You have Recently Made."',
  ),
  // ══ 55 · CHATTOGRAM BOARD–2024 ═════════════════════════════════════════
  EnglishBoardSet(
    serial: 55,
    board: 'Chattogram Board–2024',
    q1Box: const [
      'about', 'between', 'of', 'basic', 'no',
      'educate', 'almost', 'right', 'will', 'light'
    ],
    q1Passage: 'Education removes our ignorance and gives us the (a) ________ '
        'of knowledge. In respect (b) ________ imparting education, there '
        'should be (c) ________ discrimination (d) ________ man and woman. '
        'Education is one of the (e) ________ human rights. If we deprive '
        'woman of the (f) ________ of education (g) ________ half of our '
        'population (h) ________ remain in darkness. No development can be '
        'brought (i) ________ without the participation of woman. So, the '
        'government is doing everything to (j) ________ the womenfolk.',
    q2: const [
      EBMatchRow('', 'gives', 'us news of home and abroad.'),
      EBMatchRow('Newspaper', 'has', 'useful to all section of people.'),
      EBMatchRow('It', 'are', 'great educative value too.'),
      EBMatchRow('They', 'present', 'really part and parcel of our life.'),
      EBMatchRow('', 'is', 'us the outside world like a mirror.'),
    ],
    q3Box: const [
      'command', 'prepare', 'claim', 'memorize', 'develop',
      'help', 'do', 'think', 'make', 'exercise'
    ],
    q3Passage: 'Most of the students of our country are expert in (a) ________ '
        'answers. They do not (b) ________ notes themselves. They get them (c) '
        '________ by their tutors. Their tutors (d) ________ their brain for '
        'the students. So, the (e) ________ power of the students does not (f) '
        '________. They do not have any (g) ________ of their language. They, '
        'of course, (h) ________ well in the examination. But for this, they '
        'can (i) ________ no credit of their own. This result does not (j) '
        '________ them in their later life.',
    q4: const [
      EBTransformItem('Internet is a computer-based networking system.',
          'Interrogative'),
      EBTransformItem('It is a speedy transmitting system of information.',
          'Complex'),
      EBTransformItem('Its functions are not only smooth but also rapid.',
          'Affirmative'),
      EBTransformItem('A man has an internet connection and gets a link soon.',
          'Simple'),
      EBTransformItem(
          'Many educational institutions are greatly benefited through the use '
          'of internet.',
          'Complex'),
      EBTransformItem(
          'A student can visit all the renowned libraries of the world without '
          'going there.',
          'Negative'),
      EBTransformItem(
          'It plays an effective role in the field of trade and commerce.',
          'Exclamatory'),
      EBTransformItem(
          'E-commerce has become one of the most popular topics to the '
          'customers.',
          'Interrogative'),
      EBTransformItem(
          'It helps the customers to buy anything easily without going to '
          'market.',
          'Compound'),
      EBTransformItem(
          'What an amazing milestone it is in the modern world of '
          'communication!',
          'Assertive'),
    ],
    q5: const [
      'Everybody believes this truth,',
      'We hardly forget the golden past,',
      'Nothing was said,',
      "Don't disturb me,",
      "Let's be sincere in our life,",
    ],
    q6Passage: 'Mobile phone is a great (a) {invent} of modern science. The '
        'consumption of mobile phone are increasing day by day. People are '
        'getting benefits. But it is (b) {fortunate} that mobile phone '
        'sometimes becomes a cause of health hazard, especially the (c) '
        '{child} are affected much. According to the scientists mobile phone '
        'causes brain tumours, genetic damage and many other (d) {cure} '
        'diseases. They believe that visibly uncontrolled radioactivity of '
        'mobile phone causes (e) {repairable} damage to human body. They say '
        'that the government should control radioactive sources.',
    q7Passage: 'Modern civilization is the gift of science. Science has worked '
        'like a magician in the world. We can\u2019t do even a single day (a) '
        '________ the help of science. Many quick means of communication like '
        'telephone, telex, fax, telegram, satellite etc. are the greatest '
        'wonders (b) ________ science. Nowadays a message can be sent (c) '
        '________ one corner of the world (d) ________ another in the twinkle '
        'of an eye. Science has brought a revolutionary change in all fields. '
        'In the field of medical science blind has got eyes, lame has got '
        'legs, deaf has got hearing power. The diseases which were incurable '
        '(e) ________ the past are now easily curable.',
    q8Passage: 'Morning walk is a good habit for all classes of people. (a) '
        '________ it is a simple exercise, it is good for health both '
        'physically (b) ________ mentally. (c) ________ the morning air is '
        'fresh and free from any kind of noise and pollutions, it keeps us '
        'sound and healthy. Morning walk costs nothing (d) ________ gives '
        'more. (e) ________ we should make the habit of morning walk.',
    q9Text: 'the teacher said to the girl do you think that honesty is the '
        'best policy yes sir i think so said the girl then learn to be honest '
        'from your childhood thank you sir said the girl may allah bless you '
        'said the teacher',
    q10: "Write a paragraph on 'The Life of a Farmer' in about 200 words.",
    q11: 'Inform your mother through email how you physically feel after '
        'recovery from an ailment.',
    q12: "Write a composition on 'Your Favourite Game' in about 250 words.",
  ),
  // ══ 56 · SYLHET BOARD–2024 ═════════════════════════════════════════════
  EnglishBoardSet(
    serial: 56,
    board: 'Sylhet Board–2024',
    q1Box: const [
      'with', 'for', 'compliment', 'of', 'from',
      'in', 'the', 'leisure', 'idle'
    ],
    q1Passage: 'Leisure is the moment when a person is free (a) ________ his '
        'work as well as his worries and tensions. It is (b) ________ free '
        'time when we can enjoy ourselves (c) ________ doing something. So '
        'leisure is pleasure but it is not wasting time in (d) ________. In '
        'fact, leisure and labour are (e) ________. In leisure we have freedom '
        '(f) ________ doing what gives us pleasure and refreshes our mind. '
        'Our life is full (g) ________ duties. Inspite of being very busy in '
        'the present age, we cannot deny the need of (h) ________ in life. '
        'A little leisure refreshes our mind and we can start working again '
        '(i) ________ renewed energy. Leisure makes us fit (j) ________ doing '
        'more difficult work.',
    q2: const [
      EBMatchRow('Independence', 'went', 'the war.'),
      EBMatchRow('No nation', 'joined', 'to the battle field.'),
      EBMatchRow('Our war of independence', 'is', 'to save the country.'),
      EBMatchRow('People of all walks of life', 'took place',
          'it without struggle.'),
      EBMatchRow('They', 'can achieve', 'in 1971.'),
      EBMatchRow('', '', 'the birth right of a man.'),
    ],
    q3Box: const [
      'enable', 'give', 'exercise', 'send', 'do',
      'compare', 'mean', 'be', 'bring'
    ],
    q3Passage: 'Science (a) ________ simply miracle. It (b) ________ about a '
        'change over the face of the globe. It (c) ________ man to control '
        'the forces of Nature and employ them to his service. With the help '
        'of science we can now (d) ________ messages across the seas, fly in '
        'the air like the winged bird. Modern science may (e) ________ to '
        'Aladin\u2019s magic lamp. Cinema, radio, television, gramophone, '
        'electric fan and watch (f) ________ all the gifts of modern science. '
        'The cinema (g) ________ the moving and talking pictures of men and '
        'women. It (h) ________ a great influence in our daily life. The '
        'radio (i) ________ us to listen to the talks of people living '
        'hundreds of miles away from us across seas and mountains. The '
        'television (j) ________ pictures seen through the wireless.',
    q4: const [
      EBTransformItem('Who does not want to succeed in life?', 'Assertive'),
      EBTransformItem('Being industrious, everyone can prosper in life.',
          'Negative'),
      EBTransformItem('It is not an easy thing.', 'Affirmative'),
      EBTransformItem('The idle always lag behind.', 'Complex'),
      EBTransformItem('We must work hard so that we can earn money.', 'Simple'),
      EBTransformItem('By working hard, we can improve our lot.', 'Compound'),
      EBTransformItem(
          'The light of prosperity can be seen by a hard working person.',
          'Negative'),
      EBTransformItem('Women should work as much as men.', 'Interrogative'),
      EBTransformItem(
          'We should not forget that industry is the key to success.',
          'Assertive'),
      EBTransformItem('An idle man leads a very miserable life.',
          'Exclamatory'),
    ],
    q5: const [
      'At present extended families are found in rural areas,',
      "There're many members in extended families,",
      'The house is always full of guests,',
      'It becomes very difficult for one to study,',
      'In the same room children are found reading, gossiping and sleeping,',
    ],
    q6Passage: 'Child labour is considered a matter of (a) {grace} for a '
        'nation. Wherever children are employed either it is domestic work or '
        'factory work, either it is rickshaw pulling or working in a shop or '
        'hotel, they are mistreated. Their (b) {employ} don\u2019t give them '
        'their due rights. Children work for longer period in unhealthy and '
        '(c) {favourable} condition and what is sorrowful they are not given '
        'due wages. Many children do the work of the adults and often do the '
        '(d) {risk} and dangerous work. Strict laws should be (e) {forced} '
        'against employing children in manual work. Their parents should be '
        'encouraged to send their children to school.',
    q7Passage: 'You are the students of class ten. The highest class (a) '
        '________ the school. To come (b) ________ this class you had to '
        'undergo a lot of hardship and had to make effort. None of you can '
        'deny the fact (c) ________ getting help from many dedicated and '
        'friendly teachers. This is however, a usual process. What tremendous '
        'jobs the teachers shouldered to bring you (d) ________ this stage. '
        'All these have been done to you to help you (e) ________ becoming a '
        'skilled person, having the ability and integrity attaining your own '
        'excellence.',
    q8Passage: 'Almost all countries of the world suffer from the curse of '
        'unemployment problem. (a) ________ nowhere in the world this problem '
        'is so acute as in our country. There are many reasons behind it. (b) '
        '________ our country is industrially backward. (c) ________ our '
        'system of education fails to give a student an independent start of '
        'life. It has little provision for vocational training. (d) ________ '
        'our students and youths have a false sense of dignity. (e) ________ '
        'they run after jobs only.',
    q9Text: "why don't you attend classes regularly the teacher said to the "
        'boy you cannot expect good results unless you attend classes as i '
        'tell you i am sorry sir said the student',
    q10: 'Write a paragraph on "Our National Flag".',
    q11: 'Suppose, you are Sohan/Sohana of 9, Mymensingh Road, Dhaka-1000. '
        'Recently you have enjoyed a picnic. Your friend Nahid/Nahida of '
        '71/C, Broad Lane, Khulna wants to know about the picnic. Now, write '
        'a letter to your friend telling him/her how you have enjoyed the '
        'picnic.',
    q12: 'Write a composition on "Importance of Reading Newspapers".',
  ),
  // ══ 57 · BARISHAL BOARD–2024 ═══════════════════════════════════════════
  EnglishBoardSet(
    serial: 57,
    board: 'Barishal Board–2024',
    q1Box: const [
      'female', 'organs', 'on', 'prevail', 'allow',
      'no', 'cause', 'bites', 'breed', 'a'
    ],
    q1Passage: 'Dengue fever is (a) ________ tropical virus-infected disease. '
        'It is (b) ________ in more than 110 countries. It is (c) ________ by '
        'dengue virus. The fever is spread by (d) ________ Aedes mosquitoes. '
        'When the mosquito (e) ________ a man, the virus enters the blood '
        'cell, grows rapidly and attacks many (f) ________ of the body. There '
        'is (g) ________ specific medicine to treat dengue infection. So, we '
        'must put emphasis (h) ________ preventive measures. For this we must '
        'keep our surroundings clean to stop (i) ________ of Aedes '
        'mosquitoes. Again we must not (j) ________ to accumulate water in '
        'any open space for more than two days.',
    q2: const [
      EBMatchRow('(a)  The Republic of Maldives', 'faces',
          'the tourists across the world.'),
      EBMatchRow('(b)  The location of the country', 'be',
          'the country every year.'),
      EBMatchRow('(c)  Its heavenly beaches', 'visit', 'a south Asian country.'),
      EBMatchRow('(d)  Millions of tourists from different countries',
          'attract', 'the bad impact of climate change.'),
      EBMatchRow('(e)  Unfortunately the country', 'be',
          'in the Indian ocean.'),
    ],
    q3Box: const [
      'throw', 'kill', 'work', 'have', 'release',
      'be', 'ensure', 'live', 'originate', 'pollute'
    ],
    q3Passage: 'Rivers generally (a) ________ from a mountain or a lake. They '
        '(b) ________ very much important for our existence and economy. But '
        'unfortunately we are (c) ________ our rivers by throwing industrial '
        'and domestic wastes. Most of the industries, (d) ________ waste '
        'treatment plants. These kinds of industries are (e) ________ liquid '
        'wastes and continuously (f) ________ the water. Our unconscious '
        'people also (g) ________ different kinds of waste materials into '
        'rivers. So, to keep the existence of fishes and other species (h) '
        '________ in the water is impossible. It is high time the government '
        'and the people (i) ________ together to save the rivers. Otherwise a '
        'happy, prosperous and pollution free environment can\u2019t be (j) '
        '________ for the next generation.',
    q4: const [
      EBTransformItem('The Padma is one of the mightiest rivers of '
          'Bangladesh.', 'Complex'),
      EBTransformItem('It is a very turbulent river.', 'Exclamatory'),
      EBTransformItem('When it is winter, the river remains calm and tranquil.',
          'Simple'),
      EBTransformItem(
          'But during the rainy season, the river assumes a terrible shape.',
          'Compound'),
      EBTransformItem('Everybody knows this.', 'Interrogative'),
      EBTransformItem('The river is used for different purposes.', 'Negative'),
      EBTransformItem(
          'As our farmers use its water for irrigation purpose, they can grow '
          'plenty of crops.',
          'Compound'),
      EBTransformItem('Everyone likes the Hilsa fish of the river.', 'Negative'),
      EBTransformItem(
          'The river destroys the houses of men but it is still very useful '
          'to us.',
          'Complex'),
      EBTransformItem('So, let us save the river.', 'Assertive'),
    ],
    q5: const [
      'Industry is the key to success,',
      'The industrious are prosperous,',
      'They hardly suffer from poverty,',
      'On the other hand, idleness is a curse,',
      'The idle seldom prosper,',
    ],
    q6Passage: 'Everybody wants to be happy. But (a) {happy} is not attained '
        'so easily. It is a relative term. A man with huge wealth may remain '
        '(b) {happy}. Whereas a day labourer may get ample happiness if he '
        'has (c) {satisfy} over the limited money he earns everyday. (c) '
        '{actual}, for being happy or unhappy, a man is Psychologically '
        'motivated. So, it (e) {full} depends on one\u2019s mentality.',
    q7Passage: 'Our forests are a part of our environment. To maintain '
        'ecological balance, forests are necessary. But the amount (a) '
        '________ forests of the country is being shrunk day by day. Some '
        'people remain busy (b) ________ their personal benefits. They do not '
        'think (c) ________ the environment. Trees produce oxygen and keep '
        'the environment cool and prevent the rise of temperature. Whereas, '
        'some greedy people, out of their self-interest, are destroying the '
        'forests (d) ________ cutting down trees at random. They should know '
        'and realize that indiscriminate cutting down of trees destroys the '
        'ecological balance. They should also realize that if this '
        'destruction continues one day our country may turn (e) ________ a '
        'desert. We hope that they will ultimately realize the '
        'consequence(s).',
    q8Passage: 'Facebook is a social medium (a) ________ is very popular. (b) '
        '________ it provides the users with various information, all do not '
        'use it for positive purposes. Many facebook users (c) ________ some '
        'of the youngsters sometimes use it whimsically which creates (d) '
        '________ misunderstanding (e) ________ destroys the social peace.',
    q9Text: 'the old woman said, can you give me some food i have been '
        'starving for three days the young man said why do you beg cant you '
        'work',
    q10: 'Suppose, one day you visited a tea stall in your locality. You '
        'stayed there for about an hour and had some experiences about the '
        'stall. Now, write a paragraph on "A Tea Stall".',
    q11: 'Suppose, you are Nabil/Nabila, a student of class 9 of Balaka Model '
        'High School, Rajshahi. Students of your school feel the necessity of '
        'opening a canteen in the school campus. Now, write an application to '
        'your Head Teacher, on behalf of the students of the whole school, '
        'praying for opening a canteen in the school campus.',
    q12: 'Suppose, as a student you are sincere in study and alongside your '
        'academic study, you read newspapers regularly. Now, write a '
        'composition on "The Importance of Reading Newspapers".',
  ),
  // ══ 58 · DINAJPUR BOARD–2024 ═══════════════════════════════════════════
  EnglishBoardSet(
    serial: 58,
    board: 'Dinajpur Board–2024',
    q1Box: const [
      'personality', 'between', 'beneficial', 'saying', 'for',
      'participation', 'an', 'popular', 'physically', 'on'
    ],
    q1Passage: 'Sports are very essential (a) ________ us. There are various '
        'types of sports. Among them cricket, football, swimming etc. are '
        'very (b) ________. All types of sports are (c) ________ to us. There '
        'is a relation (d) ________ the body and the mind. A sound mind lies '
        'in a sound body" is a wise (e) ________. In order to gain success in '
        'life, we should have sound health which depends (f) ________ regular '
        '(g) ________ in games and sports. Sports keep us (h) ________ fit. '
        'Sports play (i) ________ important role in forming one\u2019s (j) '
        '________.',
    q2: const [
      EBMatchRow('Everybody', 'creates',
          'love which is the food of our soul.'),
      EBMatchRow('Love', 'should', 'divine.'),
      EBMatchRow('We', 'is', 'love.'),
      EBMatchRow('It', 'need', 'inspiration to go ahead.'),
      EBMatchRow('', '', 'love all the creations of God.'),
    ],
    q3Box: const [
      'lag', 'reach', 'lead', 'follow', 'depend',
      'build', 'remember', 'be', 'idle', 'work'
    ],
    q3Passage: 'Bangladesh is full of natural resources. The prosperity of the '
        'country (a) ________ on the proper utilization of the resources. We '
        'should not (b) ________ lazy life. We should all (c) ________ up our '
        'country. For this reason, we have to (d) ________ hard. No nation '
        'can prosper without industry. We should (e) ________ that industry '
        'is the key to success. If we (f) ________ the days away, we (g) '
        '________ behind. The nations that (h) ________ industrious (i) '
        '________ the pinnacle of development. So, we should (j) ________ '
        'them.',
    q4: const [
      EBTransformItem('A Journey by train is always enjoyable.', 'Negative'),
      EBTransformItem('People are fond of a journey by train.',
          'Interrogative'),
      EBTransformItem('It is not unpleasant.', 'Affirmative'),
      EBTransformItem(
          'When a man makes a journey by train, he can enjoy natural scenery.',
          'Simple'),
      EBTransformItem('People like it as it is cheap.', 'compound'),
      EBTransformItem(
          'There are class distinction in a train and people can buy tickets '
          'of various classes.',
          'Complex'),
      EBTransformItem('Train is one of the most comfortable vehicles.',
          'Interrogative'),
      EBTransformItem('Can a man enjoy a train journey?', 'Assertive'),
      EBTransformItem('The British Govt. introduced train to us.', 'Complex'),
      EBTransformItem('A train journey is very safe.', 'Exclamatory'),
    ],
    q5: const [
      'None can solve this problem,',
      'Everybody hates them,',
      "Let's do the work,",
      'Telling lies is a great sin,',
      'How nice the bird is!',
    ],
    q6Passage: 'Honey is (a) {nature} produced by honey bees through '
        'collecting of nectar from (b) {differ} flowers and then store them '
        'in the hive. But now-a-days there are beekeepers who rear bees in '
        '(c) {wood} hives and produce honey commercially. This is (d) {full} '
        'chemical and hazard free activity. With the support of the govt. and '
        'non organizations (e) {approximate} 300 bee keepers have been '
        'trained for honey production.',
    q7Passage: 'English is a widely used language. (a) ________ our country we '
        'use it as a second language. It is not our mother tongue. Naturally, '
        'it is very hard to learn. We have a very poor base (b) ________ this '
        'language. As a result, we don\u2019t feel interest (c) ________ this '
        'language. (d) ________ all these reasons English is hard (e) '
        '________ us to learn.',
    q8Passage: 'Trees are very important (a) ________. They produce oxygen (b) '
        '________ is a must for man and all living beings. We must realize '
        '(c) ________ they help us in many ways. (d) ________ trees are less '
        'in number, there will be an increased amount of carbon di-oxide in '
        'the atmosphere (e) ________ it will enhance greenhouse effect.',
    q9Text: 'the man said to me where are you going i am going to Varsity '
        'said i did you go to Varsity yesterday no i replied why did you not '
        'go i was very busy said i.',
    q10: 'Write a paragraph on "A Winter Morning".',
    q11: 'Send a letter of advice to your younger brother by using his email '
        'address to be regular in his studies.',
    q12: 'Write a composition on "Your Favourite Hobby".',
  ),
  // ══ 59 · MYMENSINGH BOARD–2024 ═════════════════════════════════════════
  EnglishBoardSet(
    serial: 59,
    board: 'Mymensingh Board–2024',
    q1Box: const [
      'attract', 'fallen', 'through', 'and', 'subconscious',
      'when', 'its', 'special', 'childhood', 'at'
    ],
    q1Passage: 'A man cannot remember everything that happened in his (a) '
        '________. But certain events are vivid in his (b) ________ mind. '
        'They sometimes peep (c) ________ his mind\u2019s eye. Very simple and '
        'trifling things are the centre of (d) ________ to a child. When a '
        'man grows up, he may laugh (e) ________ those things. For example, '
        'at the age of 6 or 7, when children\u2019s teeth start to fall, they '
        'start looking for a rat\u2019s hole, (f) ________ in villages. '
        'Because they have heard that if they put the (g) ________ tooth in a '
        'rat\u2019s hole, the rat will give them one of (h) ________ teeth. '
        'Believing that they find out a rat\u2019s hole, (i) ________ put the '
        'fallen tooth inside it. This incident makes them laugh (j) ________ '
        'they grow up.',
    q2: const [
      EBMatchRow('Culture', '',
          'badly confluence by the negative impacts of western culture.'),
      EBMatchRow('It', 'be', 'Very fond of showing hospitality.'),
      EBMatchRow('Hospitality', 'represent', 'a term used for a way of life.'),
      EBMatchRow('We', '',
          "A society's beliefs, customs, languages, foods etc."),
      EBMatchRow('But nowadays our culture', '',
          'a part of Bangladeshi culture.'),
    ],
    q3Box: const [
      'talk', 'enable', 'live', 'prove', 'be',
      'choose', 'give', 'fail', 'suffer', 'take'
    ],
    q3Passage: 'There are several reasons why friendship (a) ________ so '
        'necessary in human life. A man without a friend feels like a man '
        '(b) ________ alone in an isolated place. Moreover, it (c) ________ '
        'him lead his life in a better way. By (d) ________ to a friend a man '
        'can get relief. The advice (e) ________ by a friend is sometimes '
        'more reliable than his own judgement. Thus, it (f) ________ that '
        'friendship is really important. But a man must (g) ________ time '
        'while (h) ________ a friend. If he (i) ________ to select the right '
        'person as a friend, he (j) ________ in the long run.',
    q4: const [
      EBTransformItem('Corruption is one of the worst evils.', 'Compound'),
      EBTransformItem('A corrupt person can do anything against morality.',
          'Complex'),
      EBTransformItem("People don't like a corrupt person.", 'Affirmative'),
      EBTransformItem('Nobody respects him.', 'Interrogative'),
      EBTransformItem(
          'Though we have strict laws, we are still affected by this evil.',
          'Compound'),
      EBTransformItem('No other person is as hated as a corrupt person.',
          'Affirmative'),
      EBTransformItem('We hope that Bangladesh will be free from this evil.',
          'Simple'),
      EBTransformItem('Everybody avoids a corrupt person.', 'Negative'),
      EBTransformItem('A corrupt person leads a very unhappy life.',
          'Exclamatory'),
      EBTransformItem(
          'Let us all work together to make Bangladesh a corruption free '
          'country.',
          'Assertive'),
    ],
    q5: const [
      'Patriotism is a noble virtue,',
      'Wise people teach us to love our own country,',
      'We should remember that motherland is above everything,',
      'Some people forget it,',
      'We hope that everybody will love his motherland,',
    ],
    q6Passage: 'Life without leisure and (a) {relax} is dull. Life becomes '
        'charmless if one does not have any time to enjoy the (b) {beauty} '
        'objects of nature. Monotonous work hinders the (c) {smooth} of '
        'work. Leisure enriches our spirit to work. Everybody knows that (d) '
        '{work} is harmful. Leisure does not mean (e) {idle}. It gives '
        'freshness by charging our energy.',
    q7Passage: 'To earn fame (a) ________ life man has to possess some good '
        'qualities. (b) ________ them honesty is the best. The man who '
        'possesses this quality is the happiest man in the earth. All the '
        'people respect him (c) ________ his honesty. On the other hand a '
        'dishonest man is hated (d) ________ all. By telling lies, a man may '
        'prosper for the time being, but finally he is to suffer a lot. We '
        'must be honest in our thoughts and deeds. Childhood is the best time '
        'to learn honesty. It is our moral duty to give our children proper '
        'idea (e) ________ what is right and what is wrong.',
    q8Passage: 'We can\u2019t deny the importance of tree plantation. (a) '
        '________ our lives on earth directly or indirectly depend on it. '
        '(b) ________ it is a matter of sorrow that we are cutting down '
        'trees indiscriminately. (c) ________ trees are planted more and '
        'more, soon our country will turn into a desert. (d) ________, there '
        'will be a harmful change in the climate. (e) ________, we should '
        'plant more and more trees for our own sake.',
    q9Text: 'hi Jhorna, Im coming to Bangladesh next month. Will you receive '
        'me at the airport said Meghla. Dont worry Ill be there Jhorna said.',
    q10: 'Write a paragraph in 250 words on Our National Flag.',
    q11: 'Suppose, you are Sayem/Samia. You and your parents went to '
        'Chattogram by train a few days ago. You wish to share this new '
        'experience with your friend Abrar/Anika. Now, write a letter to '
        'your friend sharing the experience of the train journey that you '
        'made.',
    q12: 'Write a composition on The Season You Like Most.',
  ),
];

// ════════════════════════════════════════════════════════════════════════
//  🔀 English Second Paper MIXER
//  প্রতিবার Generate = প্রতিটি প্রশ্ন আলাদা আলাদা বোর্ড থেকে (একই সেট কখনোই
//  একবারে আসে না)। sources-এ 12টি গ্রুপের (Q1..Q12) উৎস-সিরিয়াল থাকে।
// ════════════════════════════════════════════════════════════════════════
class MixedSecondPaper {
  final EnglishBoardSet set;
  final List<int> sources;
  const MixedSecondPaper(this.set, this.sources);
}

class EnglishBoardMixer {
  EnglishBoardMixer._();

  static MixedSecondPaper mix({Random? rng}) {
    final r = rng ?? Random();
    EnglishBoardSet pick() =>
        englishBoardSets2024[r.nextInt(englishBoardSets2024.length)];
    final g = List<EnglishBoardSet>.generate(12, (_) => pick());
    final set = EnglishBoardSet(
      serial: 0,
      board: 'Mixed Board Set–2024',
      headerExtra: const [
        'English (Compulsory)–Second Paper',
        'Full Marks : 100          Time : 3 hours',
      ],
      q1Box: g[0].q1Box,
      q1Passage: g[0].q1Passage,
      q2: g[1].q2,
      q3Box: g[2].q3Box,
      q3Passage: g[2].q3Passage,
      q4: g[3].q4,
      q5: g[4].q5,
      q6Passage: g[5].q6Passage,
      q7Passage: g[6].q7Passage,
      q8Passage: g[7].q8Passage,
      q9Text: g[8].q9Text,
      q10: g[9].q10,
      q11: g[10].q11,
      q12: g[11].q12,
    );
    return MixedSecondPaper(set, g.map((e) => e.serial).toList());
  }
}
