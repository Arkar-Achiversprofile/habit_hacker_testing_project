import 'dart:async';
import 'dart:developer';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  Timer? _timer;

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

  int selectedDay = 0;
  int selectedHour = 0;
  int selectedMinute = 0;
  int selectedSecond = 0;

  final List<int> days = List.generate(31, (index) => index);
  final List<int> hours = List.generate(24, (index) => index);
  final List<int> minutes = List.generate(60, (index) => index);
  final List<int> seconds = List.generate(60, (index) => index);

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
    setState(() {
      _isListening = true;
    });
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
    setState(() {
      _isListening = false;
    });
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

  void _showDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text(
                'Please select the duration as you want to get notification. Notification will be send to you every duration time you set.'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
            ],
          );
        });
  }

  Future<void> requestExactAlarmPermission() async {
    // DateTime selectedTime = DateTime.now().add(const Duration(seconds: 10));
    Duration duration = Duration(
        days: selectedDay,
        hours: selectedHour,
        minutes: selectedMinute,
        seconds: selectedSecond);
    _timer?.cancel();
    _timer = Timer.periodic(duration, (Timer timer) {
      NotificationService.showNotification(
          "Show Notification", "This is show notification!");
      // NotificationService.scheduleNotification(
      //   "Android Notification", "Hello testing hello", selectedTime);
    });
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
        title: const Text('Habit Hacker'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DropdownButton<int>(
                  value: selectedDay,
                  items: days.map((int day) {
                    return DropdownMenuItem<int>(
                      value: day,
                      child: CustomText(
                        text: '$day Day${day > 1 ? 's' : ''}',
                        fontWeight: FontWeight.bold,
                        textAlign: TextAlign.center,
                      ),
                    );
                  }).toList(),
                  onChanged: (int? newValue) {
                    setState(() {
                      selectedDay = newValue!;
                    });
                  },
                  hint: const Text('Select Day'),
                ),
                const SizedBox(width: 15),
                DropdownButton<int>(
                  value: selectedHour,
                  items: hours.map((int hour) {
                    return DropdownMenuItem<int>(
                      value: hour,
                      child: CustomText(
                        text: '$hour Hour${hour > 1 ? 's' : ''}',
                        fontWeight: FontWeight.bold,
                        textAlign: TextAlign.center,
                      ),
                    );
                  }).toList(),
                  onChanged: (int? newValue) {
                    setState(() {
                      selectedHour = newValue!;
                    });
                  },
                  hint: const Text('Select Hour'),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DropdownButton<int>(
                  value: selectedMinute,
                  items: minutes.map((int minute) {
                    return DropdownMenuItem<int>(
                      value: minute,
                      child: CustomText(
                        text: '$minute Minute${minute > 1 ? 's' : ''}',
                        fontWeight: FontWeight.bold,
                        textAlign: TextAlign.center,
                      ),
                    );
                  }).toList(),
                  onChanged: (int? newValue) {
                    setState(() {
                      selectedMinute = newValue!;
                    });
                  },
                  hint: const Text('Select Minute'),
                ),
                const SizedBox(width: 15),
                DropdownButton<int>(
                  value: selectedSecond,
                  items: seconds.map((int second) {
                    return DropdownMenuItem<int>(
                      value: second,
                      child: CustomText(
                        text: '$second Second${second > 1 ? 's' : ''}',
                        fontWeight: FontWeight.bold,
                        textAlign: TextAlign.center,
                      ),
                    );
                  }).toList(),
                  onChanged: (int? newValue) {
                    setState(() {
                      selectedSecond = newValue!;
                    });
                  },
                  hint: const Text('Select Second'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (selectedDay == 0 &&
                        selectedHour == 0 &&
                        selectedMinute == 0 &&
                        selectedSecond == 0) {
                      _showDialog(context);
                    } else {
                      requestExactAlarmPermission();
                    }
                  },
                  child: const CustomText(
                    text: 'Show Notification',
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    _timer?.cancel();
                    _timer = null;
                  },
                  child: const CustomText(
                    text: 'Cancel Schedule',
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Container(
              // padding: const EdgeInsets.all(16),
              child: const CustomText(
                text: 'Recognized words:',
                fontSize: 25,
                color: Colors.black,
                fontWeight: FontWeight.bold,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 15),
            Expanded(
                child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: SingleChildScrollView(
                  child: Column(
                children: [
                  CustomText(
                    // If listening is active show the recognized words
                    // _speechToText.isListening
                    text: _speechEnabled
                        ? _isListening
                            ? 'Microphone is listening'
                            : 'Tap the microphone to start listening...'
                        : 'Speech not available',
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _speechTextcontroller,
                    minLines: 5,
                    maxLines: 10,
                    decoration: const InputDecoration(
                      border: const OutlineInputBorder(),
                    ),
                    style:
                        GoogleFonts.caveat(color: Colors.black, fontSize: 18),
                    onChanged: (text) => {
                      setState(() {
                        speechText = text;
                      })
                    },
                  ),
                  // CustomText(
                  //   text: _fullText,
                  //   fontSize: 20,
                  //   color: Colors.black,
                  //   fontWeight: FontWeight.bold,
                  //   textAlign: TextAlign.center,
                  // ),
                ],
              )),
            )),
          ],
        ),
      ),
      floatingActionButton:
          //  GestureDetector(
          //   onLongPress: _startListening,
          //   onLongPressUp: _stopListening,
          //   child:
          FloatingActionButton(
        onPressed:
            // If not yet listening for speech start, otherwise stop
            _isListening ? _stopListening : _startListening,
        // tooltip: 'Listen',
        child: Icon(_isListening ? Icons.mic : Icons.mic_off),
      ),
      // ),
    );
  }
}
