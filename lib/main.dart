import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:project_danny/common/call.dart';
import 'package:project_danny/common/call_dao.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:project_danny/routes/manage_calls_route.dart';

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
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyan),
          useMaterial3: true),
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
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        title: const Text('Project Danny'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ManageCallsRoute(
                          dao: widget.dao, camera: widget.camera)),
                );
              },
              tooltip: 'Manage calls',
              icon: const Icon(Icons.list_alt_outlined))
        ],
      ),
      body: StreamBuilder<List<Call>>(
        stream: widget.dao.getCallsAsStream(),
        builder: (_, snapshot) {
          if (!snapshot.hasData) return Container();

          final calls = snapshot.requireData;

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
                          border: Border.all(
                            color: Colors.black.withOpacity(0.8),
                            width: 2.0,
                          ),
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.0),
                          gradient: LinearGradient(
                            begin: FractionalOffset.topCenter,
                            end: FractionalOffset.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.0),
                              Colors.black.withOpacity(0.5),
                            ],
                            stops: const [0.75, 1.0],
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(8.0),
                        child: Text(
                          calls[index].tts,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 20.0,
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
