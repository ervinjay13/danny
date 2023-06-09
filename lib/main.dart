import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:danny/common/call.dart';
import 'package:danny/common/call_dao.dart';
import 'package:danny/routes/add_call_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'common/database.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the database
  final database =
      await $FloorAppDatabase.databaseBuilder('app_database.db').build();

  // dao that the app will interact with
  final dao = database.callDao;

  // Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();

  // Get a specific camera from the list of available cameras.
  final camera = cameras.first;

  runApp(MyApp(dao, camera));
}

class MyApp extends StatelessWidget {
  final CallDao dao;
  final CameraDescription camera;

  const MyApp(this.dao, this.camera, {super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Danny',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: MyHomePage(dao: dao, camera: camera),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key, required this.dao, required this.camera});

  final CallDao dao;
  final CameraDescription camera;
  final FlutterTts tts = FlutterTts();

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void _invokeButtonCall(Call call) {
    widget.tts.speak(call.tts);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        title: const Text('Danny (Dev)'),
      ),
      body: StreamBuilder<List<Call>>(
        stream: widget.dao.getCallsAsStream(),
        builder: (_, snapshot) {
          if (!snapshot.hasData) return Container();

          final calls = snapshot.requireData;

          return ListView.builder(
            itemCount: calls.length,
            itemBuilder: (_, index) {
              return Container(
                // height: 500,
                margin: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 0.0),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      // height: 500,
                      child: GestureDetector(
                        onTap: () => _invokeButtonCall(calls[index]),
                        child: Image.memory(
                            base64Decode(calls[index].imageBase64),
                            fit: BoxFit.cover,
                            alignment: Alignment.center),
                      ),
                    ),
                    Container(
                      child: Text('this is a test message',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 25.0)),
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                fullscreenDialog: true,
                builder: (context) =>
                    AddCallRoute(dao: widget.dao, camera: widget.camera)),
          );
        },
        tooltip: 'Add Call',
        child: const Icon(Icons.add),
      ),
    );
  }
}
