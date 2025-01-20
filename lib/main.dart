import 'dart:developer';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:habit_hacker_testing_project/components/custom_text.dart';
import 'package:habit_hacker_testing_project/notifications/notification_service.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  tz.initializeTimeZones();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _speechToText = SpeechToText();
  bool _speechEnabled = false;
  bool _isListening = false;
  var _fullText = '';

  final TextEditingController _pauseForController =
      TextEditingController(text: '5');
  final TextEditingController _listenForController =
      TextEditingController(text: '30');
  double level = 0.0;
  double minSoundLevel = 50000;
  double maxSoundLevel = -50000;
  String _currentLocaleId = '';

  String speechText = '';
  final TextEditingController _speechTextcontroller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  /// This has to happen only once per app
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    if (_speechEnabled) {
      var systemLocale = await _speechToText.systemLocale();
      _currentLocaleId = systemLocale?.localeId ?? '';
    }
    setState(() {});
  }

  /// Each time to start a speech recognition session
  void _startListening() async {
    _isListening = true;
    final pauseFor = int.tryParse(_pauseForController.text);
    final listenFor = int.tryParse(_listenForController.text);
    final options = SpeechListenOptions(
        onDevice: false,
        listenMode: ListenMode.confirmation,
        cancelOnError: true,
        partialResults: true,
        autoPunctuation: true,
        enableHapticFeedback: true);
    await _speechToText.listen(
        onResult: _onSpeechResult,
        listenFor: Duration(seconds: listenFor ?? 30),
        pauseFor: Duration(seconds: pauseFor ?? 3),
        localeId: _currentLocaleId,
        onSoundLevelChange: soundLevelListener,
        listenOptions: options);
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  void _stopListening() async {
    await _speechToText.stop();
    _isListening = false;
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      if (result.finalResult) {
        _fullText += ('${result.recognizedWords} ');
        _speechTextcontroller.text = _fullText;
      }
    });
    // _stopListening();
    _startListening();
  }

  void soundLevelListener(double level) {
    minSoundLevel = min(minSoundLevel, level);
    maxSoundLevel = max(maxSoundLevel, level);
    // _logEvent('sound level $level: $minSoundLevel - $maxSoundLevel ');
    setState(() {
      this.level = level;
    });
  }

  Future<void> requestExactAlarmPermission() async {
    DateTime selectedTime =
        DateTime.now().add(const Duration(seconds: 10)); // For testing purposes
    // NotificationService().scheduleDailyNotification(selectedTime);
    NotificationService.scheduleNotification(
        "Android Notification", "Hello testing hello", selectedTime);
  }

  // String recognizedWordsToShow(lastWords) {
  //   var displayWords = _words;
  //   displayWords = displayWords + lastWords;
  //   setState(() {
  //     _words = displayWords;
  //   });
  //   return displayWords;
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Speech Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                NotificationService.showNotification(
                    "Show Notification", "This is show notification!");
              },
              child: const Text('Show Notification'),
            ),
            ElevatedButton(
              onPressed: () {
                requestExactAlarmPermission();
              },
              child: const Text('Schedule Notification'),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              child: const Text(
                'Recognized words:',
                style: TextStyle(fontSize: 20.0),
              ),
            ),
            Expanded(
                child: Container(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                  child: Column(
                children: [
                  TextField(
                    controller: _speechTextcontroller,
                    decoration: const InputDecoration(
                      border: const OutlineInputBorder(),
                      hintText: 'Enter a search term',
                    ),
                    onChanged: (text) => {
                      setState(() {
                        speechText = text;
                      })
                    },
                  ),
                  Text(
                    // If listening is active show the recognized words
                    // _speechToText.isListening
                    _speechEnabled
                        ? _isListening
                            ? 'Microphone is listening'
                            : 'Tap the microphone to start listening...'
                        : 'Speech not available',
                  ),
                  CustomText(
                    text: _fullText,
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    textAlign: TextAlign.center,
                  ),
                ],
              )),
            )),
          ],
        ),
      ),
      floatingActionButton: GestureDetector(
        onLongPress: _startListening,
        onLongPressUp: _stopListening,
        child: FloatingActionButton(
          onPressed: null,
          // If not yet listening for speech start, otherwise stop
          // _isListening ? _stopListening : _startListening,
          // tooltip: 'Listen',
          child: Icon(_isListening ? Icons.mic : Icons.mic_off),
        ),
      ),
    );
  }
}
