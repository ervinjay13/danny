import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:project_danny/common/call.dart';
import 'package:project_danny/common/call_dao.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:project_danny/routes/settings_route.dart';

import 'common/database.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Setup TTS
  final tts = FlutterTts();

  await tts.setSharedInstance(true);

  await tts.setIosAudioCategory(
      IosTextToSpeechAudioCategory.playback,
      [
        IosTextToSpeechAudioCategoryOptions.allowBluetooth,
        IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
        IosTextToSpeechAudioCategoryOptions.mixWithOthers
      ],
      IosTextToSpeechAudioMode.voicePrompt);

  // Initialize the database
  final database =
      await $FloorAppDatabase.databaseBuilder('app_database.db').build();

  // dao that the app will interact with
  final dao = database.callDao;

  // Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();

  // Get a specific camera from the list of available cameras.
  final camera = cameras.first;

  runApp(MyApp(dao, camera, tts));
}

class MyApp extends StatelessWidget {
  final CallDao dao;
  final CameraDescription camera;
  final FlutterTts tts;

  const MyApp(this.dao, this.camera, this.tts, {super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Project Danny',
      theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          colorSchemeSeed: Colors.red),
      home: MyHomePage(dao: dao, camera: camera, tts: tts),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage(
      {super.key, required this.dao, required this.camera, required this.tts});

  final CallDao dao;
  final CameraDescription camera;
  final FlutterTts tts;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void _invokeButtonCall(Call call) {
    widget.tts.speak(call.tts);
  }

  @override
  Widget build(BuildContext context) {
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Danny'),
        actions: [
          IconButton(
              onPressed: () {
                // A little messy, show the input dialog here for the users PIN
                showDialog(
                    context: context,
                    builder: (context) {
                      final TextEditingController pinController =
                          TextEditingController();

                      return AlertDialog(
                        title: const Text('PIN Required'),
                        content: TextField(
                          obscureText: true,
                          controller: pinController,
                          autofocus: true,
                          maxLength: 4,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: const InputDecoration(
                              border: OutlineInputBorder()),
                        ),
                        actions: <Widget>[
                          MaterialButton(
                            child: const Text('Cancel'),
                            onPressed: () {
                              setState(() {
                                Navigator.pop(context);
                              });
                            },
                          ),
                          MaterialButton(
                            child: const Text('Continue'),
                            onPressed: () {
                              Navigator.pop(context);

                              if (pinController.text == '0000') {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SettingsRoute(
                                            dao: widget.dao,
                                            camera: widget.camera)));
                              }
                            },
                          ),
                        ],
                      );
                    });

                /*Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SettingsRoute(
                            dao: widget.dao, camera: widget.camera)));*/
              },
              tooltip: 'Settings',
              icon: const Icon(Icons.settings))
        ],
      ),
      body: StreamBuilder<List<Call>>(
        stream: widget.dao.getCallsAsStream(),
        builder: (_, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final calls = snapshot.requireData;

          if (calls.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('Hello!',
                      style:
                          TextStyle(fontSize: 58, fontWeight: FontWeight.w200)),
                  SizedBox(height: 34),
                  Text('Welcome to Project Danny',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  SizedBox(height: 8),
                  Text(
                      'To get started, tap the settings icon on the top right corner'),
                  SizedBox(height: 4),
                  Text(
                      'You will be required to enter a PIN, by default this is "0000"'),
                  SizedBox(height: 48),
                ],
              ),
            );
          }

          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isPortrait ? 2 : 4,
              mainAxisSpacing: 12.0,
              crossAxisSpacing: 12.0,
            ),
            padding: const EdgeInsets.all(12.0),
            itemCount: calls.length,
            itemBuilder: (_, index) {
              return Container(
                margin: const EdgeInsets.all(0.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.7),
                      spreadRadius: 2,
                      blurRadius: 6,
                      offset: const Offset(0, 4), // changes position of shadow
                    ),
                  ],
                ),
                child: GestureDetector(
                  onTap: () => _invokeButtonCall(calls[index]),
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      AspectRatio(
                        aspectRatio: 1.0,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Image.memory(
                              base64Decode(calls[index].imageBase64),
                              fit: BoxFit.cover,
                              alignment: Alignment.center),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          gradient: LinearGradient(
                            begin: FractionalOffset.topCenter,
                            end: FractionalOffset.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.0),
                              Colors.black.withOpacity(0.7),
                            ],
                            stops: const [0.7, 1.0],
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(8.0),
                        child: Text(
                          calls[index].tts,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 18.0,
                              color: Colors.white,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
