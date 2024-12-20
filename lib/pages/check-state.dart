import 'package:flutter/material.dart';

class StatementCheckerPage extends StatefulWidget {
  const StatementCheckerPage({Key? key}) : super(key: key);

  @override
  State<StatementCheckerPage> createState() => _StatementCheckerPageState();
}

class _StatementCheckerPageState extends State<StatementCheckerPage> {
  final TextEditingController _controller = TextEditingController();
  String _result = '';
  Color _resultColor = Colors.black;
  List<String> _detectedPatterns = [];

  // Enhanced patterns list with more variations and categories
  final List<Map<String, dynamic>> _abusivePatterns = [
    {
      'category': 'Religious/Patriarchal Discrimination',
      'patterns': [
        'a woman’s job is to serve',
        'women should keep quiet',
        'women must submit to men',
        'don’t act out of line',
        'only men should decide',
        'don’t be forward; it’s unladylike',
        'be respectful to men’s authority',
        'a man knows better',
        'you’re too opinionated for a woman',
        'real women don’t argue',
        'traditional women respect their men',
        'a woman should always obey',
        'don’t dress provocatively',
        'be humble like a good woman',
        'you’re just a woman, remember?',
        'stick to women’s work',
        'don’t compete with men',
        'women aren’t meant to lead',
        'know your duties as a wife',
        'stop being so forward',
        'a lady should never argue',
        'you don’t have a man’s authority',
        'follow traditional values',
        'women should know their limits',
        'don’t step out of line',
        'it’s men’s role to lead',
        'women shouldn’t assert themselves',
        'being bold isn’t ladylike',
        'real women don’t act this way',
        'listen to your husband',
        'you’re acting out of place for a woman',
        'your value is in the home',
        'women aren’t fit to work outside',
        'dress modestly like a good woman',
        'respect male opinions over yours',
        'real women support their husbands',
        'a woman’s voice shouldn’t be loud',
        'stick to household duties',
        'don’t challenge men’s ideas',
        'you’re too bold for a woman',
        'only men should be assertive',
        'don’t question men’s authority',
        'you should serve, not lead',
        'women aren’t designed for power',
        'let the men take charge',
        'women belong in the background',
        'a woman’s place is at home',
        'focus on being a good wife',
        'women should respect men’s roles',
        'don’t dress for attention',
        'you’re too assertive for a woman',
        'traditional women know their limits',
        'don’t act like men',
        'support men, don’t challenge them',
        'you’re too aggressive for a woman',
        'women should be seen, not heard',
        'leave leadership to men',
        'dress more modestly',
        'women should be homemakers',
        'support your husband’s career',
        'don’t pursue male-dominated fields',
        'you’re not as capable as a man',
        'act according to our culture',
        'don’t dress to show off',
        'a woman shouldn’t be outspoken',
        'listen and don’t speak up',
        'a good woman is respectful',
        'your beauty is your value',
        'a quiet woman is a respectable woman',
        'women don’t make good leaders',
        'you’re too driven for a woman',
        'don’t outshine the men',
        'women should care for the family',
        'focus on being motherly',
        'don’t challenge traditions',
        'you’re acting unladylike',
        'a woman’s worth is in her family',
        'act modestly around men',
        'women shouldn’t work hard jobs',
        'don’t dress to impress men',
        'stay out of men’s conversations',
        'you’re too forward for a woman',
        'real women don’t dress flashy',
        'don’t be the center of attention',
        'you’re taking men’s roles',
        'women should care for children',
        'a loud woman is disrespectful',
        'show respect by being quiet',
        'women shouldn’t be outspoken',
        'you’re acting too independently',
        'men should handle the finances',
        'act demurely in public',
        'women aren’t for politics',
        'don’t be too ambitious',
        'dress to respect culture',
        'support men’s ideas over yours',
        'a good woman is obedient',
        'don’t try to control men',
        'men know better than women',
        'traditional women stay home',
        'a woman’s worth is in her family',
        'leave leadership to men',
        'don’t dress to impress men',
        'women’s role is to nurture',
        'stick to your husband’s opinions',
        'real women avoid confrontation',
        'don’t seek power over men',
        'you’re not fit for leadership',
        'respect men’s authority over yours',
        'women belong with children',
        'men are naturally stronger',
        'a modest woman is admirable',
        'don’t outshine your husband',
        'dress simply and respectably',
        'real women support their husbands',
        'a true woman respects her husband',
        'women should be gentle',
        'leave hard work to men',
        'men handle serious matters',
        'don’t dress provocatively',
        'traditional values honor women',
        'men lead, women follow',
        'men are heads of households',
        'don’t step out of your role',
        'be humble like a real woman',
        'a good wife respects her husband',
        'men decide what’s best',
        'women shouldn’t argue',
        'you’re acting out of line',
        'know your duties as a wife',
        'a woman’s place is at home',
        'dress for respect, not attention',
        'don’t try to compete with men',
        'you’re just a woman, remember?',
        'men lead, women support',
        'you don’t have a man’s authority',
        'focus on being a homemaker',
        'a woman’s strength is gentleness',
        'don’t dress for male attention',
        'women aren’t for serious jobs',
        'traditional women honor men',
        'real women aren’t assertive',
        'your role is to nurture',
        'be demure in public',
        'women shouldn’t challenge men',
        'a woman’s worth is in her family',
        'don’t dress to attract attention',
        'you’re too bold for a woman',
        'men make the best decisions',
        'respect men’s voices over yours',
        'stay out of serious matters',
        'you’re not as capable as a man',
        'leave the hard work to men',
        'women should care for others',
        'know your role as a woman',
        'a modest woman is admirable',
        'traditional women know their place',
        'dress simply for respect',
        'women shouldn’t act powerful',
        'a true woman is humble',
        'you’re acting too independently',
        'respect men’s roles over yours',
        'don’t step into men’s shoes',
        'stay out of men’s conversations',
        'your voice isn’t needed here',
        'real women are gentle',
        'don’t take on men’s jobs',
        'leave ambition to men',
        'women should be soft-spoken',
        'you’re too outspoken for a woman',
        'dress appropriately for a woman',
        'stay modest for respect',
        'focus on being nurturing',
        'traditional values suit women',
        'a real woman is humble',
        'men decide, women obey',
        'support men’s goals over yours',
        'be more modest and respectful',
        'men are made for hard work',
        'leave authority to men',
        'you’re too assertive for a woman',
        'focus on family, not career',
        'men are natural leaders',
        'don’t compete with men’s power',
        'know your limits as a woman',
        'traditional values honor men',
        'women should avoid leadership',
        'men handle important matters',
        'real women follow, not lead',
        'men are better suited for this job'
      ]
    },
    {
      'category': 'Professional Discrimination',
      'patterns': [
        'men are more suited for leadership',
        'women don’t handle stress well',
        'stick to support roles',
        'you’re not tough enough for this job',
        'leave the real work to men',
        'women are too emotional for management',
        'focus on your family instead',
        'better suited for assistant roles',
        'this job is for the guys',
        'not strong enough for this field',
        'don’t try to act like a man',
        'stick to softer professions',
        'women are better at clerical work',
        'too soft for the business world',
        'men are better at handling money',
        'you can’t handle the workload',
        'leave the leadership to us',
        'too nurturing to handle pressure',
        'you don’t have the drive for this',
        'not sharp enough for high-level jobs',
        'men are more logical',
        'don’t pretend to understand business',
        'women lack business acumen',
        'leave the decision-making to us',
        'you’re too caring to be effective',
        'this isn’t a job for women',
        'men are more focused',
        'support roles suit you better',
        'it’s a man’s world in this field',
        'not leadership material',
        'too emotional for serious tasks'
      ]
    },
    {
      'category': 'Gaslighting Phrases',
      'patterns': [
        'you’re overthinking everything',
        'it’s all in your imagination',
        'stop looking for problems',
        'don’t make a scene over nothing',
        'you’re making it a bigger deal than it is',
        'stop being dramatic',
        'nobody else has an issue',
        'you’re way too sensitive',
        'you’re blowing this out of proportion',
        'you’re reading into it too much',
        'that’s not what happened',
        'everyone thinks you’re overreacting',
        'you’re just confused',
        'you’re misremembering things',
        'that never happened',
        'you’re imagining things',
        'stop being paranoid',
        'no one else would care about this',
        'it’s not as serious as you think',
        'you’re always too emotional',
        'stop creating problems',
        'you’re just insecure',
        'you’re looking for reasons to be upset',
        'don’t make things up',
        'you’re only doing this for attention',
        'you’re way too fragile',
        'stop acting so delicate',
        'you need to lighten up',
        'nobody else cares like you do',
        'you’re making things up in your head',
        'you’re always trying to find faults'
      ]
    },
    {
      'category': 'Intimidation Tactics',
      'patterns': [
        'you don’t know who you’re dealing with',
        'better stay in your place',
        'don’t get on my bad side',
        'don’t test my patience',
        'be careful what you say next',
        'you won’t get away with this',
        'I know where you live',
        'you should watch yourself',
        'better stay quiet if you know what’s good',
        'don’t make me angry',
        'remember who’s in control',
        'I can ruin things for you',
        'you’re stepping over the line',
        'you’ll regret this later',
        'better think twice before crossing me',
        'you’re pushing your luck',
        'know who’s the boss here',
        'I have power over you',
        'don’t make me show you the hard way',
        'you don’t want to mess with me',
        'this isn’t over',
        'be ready for consequences',
        'you’re on thin ice',
        'remember your place',
        'don’t cross me again',
        'you’re not as powerful as you think',
        'don’t challenge me',
        'you’ll be sorry if you push this',
        'I’ll make sure you regret it',
        'you’ll wish you hadn’t done that'
      ]
    },
    {
      'category': 'Leadership Undermining',
      'patterns': [
        'you’re acting too big for your boots',
        'don’t get a big head',
        'stop trying to be in charge',
        'know your place in the team',
        'you’re not real leadership material',
        'people don’t see you as a leader',
        'don’t act like you know everything',
        'you’re too eager for control',
        'trying to be the boss doesn’t suit you',
        'stop trying to run the show',
        'you’re acting above your rank',
        'know your limits',
        'not everyone’s as impressed as you are',
        'don’t act like you’re in charge',
        'stay out of the leader’s way',
        'you’re not as skilled as you think',
        'others would do a better job',
        'you’re just showing off',
        'stop acting like you’re the authority',
        'leave the leading to those who can',
        'you’re stepping out of line',
        'not ready to handle this level',
        'stay in your lane',
        'acting way above your station',
        'you’re just a wannabe leader',
        'don’t act like you’re better than us',
        'you’re too overconfident for your own good',
        'no one respects your authority',
        'this role isn’t really for you'
      ]
    },
    {
      'category': 'Age-Based Discrimination',
      'patterns': [
        'leave it to someone younger',
        'you’re too old for this',
        'you’re not young enough to keep up',
        'too young to handle this responsibility',
        'don’t try to keep up with the youth',
        'this job is for someone more mature',
        'younger people handle this better',
        'older folks don’t get it',
        'you’re past your best years',
        'act more mature for your age',
        'you’re too young to understand',
        'someone with experience should handle this',
        'young people lack wisdom',
        'you don’t have the energy for this',
        'this field needs young blood',
        'getting too old for this line of work',
        'too inexperienced to understand the stakes',
        'leave it to the experienced hands',
        'older people are out of touch',
        'stick with people your age',
        'don’t try to fit in with the youth',
        'young ones can’t handle it',
        'not as sharp as you used to be',
        'too old to take on new ideas',
        'younger people adapt faster',
        'should consider retirement soon',
        'leave the ambitious stuff to the young',
        'not the same energy as before',
        'you’re too set in your ways',
        'too old for the modern approach'
      ]
    },
    {
      'category': 'Body Shaming',
      'patterns': [
        'too skinny for anyone to like',
        'need to eat more',
        'you’re getting fat',
        'no one likes a bony look',
        'dress to cover up',
        'your body isn’t attractive',
        'put on some weight',
        'nobody wants to see that',
        'you’re too curvy for that outfit',
        'showing too much of your body',
        'you look out of shape',
        'dress to hide your flaws',
        'need to work out more',
        'nobody likes seeing bones',
        'you don’t look healthy',
        'your body isn’t fit for that style',
        'stop drawing attention to your size',
        'too bulky to be attractive',
        'your body shape is wrong for that outfit',
        'not toned enough',
        'getting too old for tight clothes',
        'should dress for your body type',
        'need to lose weight',
        'too muscular for a woman',
        'you’re too big for that dress',
        'you’re letting yourself go',
        'people notice your weight gain',
        'stop eating so much',
        'your body doesn’t suit that',
        'dress your age and size'
      ]
    },
    {
      'category': 'Abusive Language',
      'patterns': [
        // Enhanced abusive patterns with variations and common misspellings
        'fuck', 'fck', 'f*ck', 'fu*k', 'fuk',
        'shit', 'sh*t', 'shyt',
        'bitch', 'b*tch', 'bytch', 'biatch',
        'ass', 'ass', 'a**',
        'bastard', 'b*stard',
        'dick', 'd*ck', 'dik',
        'whore', 'hoe', 'ho',
        'slut', 'sl*t',
        'idiot', 'idi*t',
        'stupid', 'stup*d',
        'dumb', 'dumm',
        'retard', 'r*tard',
        'moron', 'mor*n',
        'cunt', 'c*nt',
        'pussy', 'pu**y',
        'cock', 'c*ck',
        'piss', 'p*ss',
        'damn', 'd*mn',
        'hell', 'h*ll',
        'shut up',
        'stfu',
        'kys',
        'kill yourself',
        'die',
        'kys',
        'kms',
        'suicide',
        // Racial and ethnic slurs (censored)
        'n*****', 'n****',
        'ch***', 'ch****',
        'w*****', 'w****',
        // Additional abusive terms
        'loser', 'l*ser',
        'waste', 'w*ste',
        'trash', 'tr*sh',
        'garbage',
        'worthless',
        'useless',
        'piece of shit', 'pos',
        'scum', 'sc*m',
        'die', 'rot', 'burn',
        'hate you', 'hate u',
        'kys', 'kms',
        // Threatening language
        'kill', 'murder', 'hurt',
        'punch', 'beat', 'slap',
        'attack', 'fight', 'hit'
      ]
    },
    {
      'category': 'Harassment',
      'patterns': [
        'stalking',
        'stalk',
        'following',
        'watching you',
        'find you',
        'know where you',
        'come for you',
        'get you',
        'hunt you',
        'track you',
        'follow you home',
        'show up at',
        'wait for you',
        'coming for you'
      ]
    },
    {
      'category': 'Sexual Harassment',
      'patterns': [
        'sexy',
        'hot',
        'beautiful',
        'gorgeous',
        'pretty',
        'cute',
        'body',
        'figure',
        'curves',
        'dating',
        'date me',
        'go out',
        'single',
        'relationship',
        'marry',
        'wedding',
        'boyfriend',
        'girlfriend',
        'love you',
        'love u',
        'kiss',
        'touch',
        'feel',
        'sex',
        'bed',
        'sleep'
      ]
    }
  ];

  void _analyzeStatement() {
    String statement = _controller.text.toLowerCase();
    _detectedPatterns = [];
    Set<String> categories = {};

    // Split input into words for more accurate detection
    List<String> words = statement.split(RegExp(r'\s+'));

    // Check for exact matches and partial matches
    for (var patternGroup in _abusivePatterns) {
      for (var pattern in patternGroup['patterns'] as List<String>) {
        // Check for exact pattern matches
        if (statement.contains(pattern.toLowerCase())) {
          _detectedPatterns.add(pattern);
          categories.add(patternGroup['category'] as String);
        }

        // Check for partial matches in individual words
        for (var word in words) {
          if (pattern.toLowerCase().contains(word) ||
              word.contains(pattern.toLowerCase())) {
            if (word.length > 2) {
              // Avoid matching very short words
              _detectedPatterns.add(word);
              categories.add(patternGroup['category'] as String);
            }
          }
        }
      }
    }

    setState(() {
      if (_detectedPatterns.isEmpty) {
        _result =
            'No obvious abusive content detected. However, if you feel uncomfortable, trust your instincts and seek support.';
        _resultColor = Colors.green;
      } else {
        _result = 'WARNING: Potentially abusive content detected.\n\n'
            'Categories: ${categories.join(", ")}\n\n'
            'Detected patterns: ${_detectedPatterns.join(", ")}\n\n'
            'This statement contains concerning language. Consider reporting this incident and seeking support from relevant authorities or support groups.';
        _resultColor = Colors.red;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statement Abuse Detector'),
        backgroundColor: Colors.purple.shade100,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Enter the statement someone made towards you:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _controller,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Type the statement here...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _analyzeStatement,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Analyze Statement',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 24),
              if (_result.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _resultColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _resultColor),
                  ),
                  child: Text(
                    _result,
                    style: TextStyle(
                      color: _resultColor,
                      fontSize: 16,
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              const Text(
                'Note: This is a basic detection tool. If you feel unsafe or threatened, please contact local authorities or support services immediately.',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
