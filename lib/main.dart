import 'dart:convert';

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

  // TODO: Remove. This is used for testing to ensure we don't get into
  // a state where the app does not work while testing
  await dao.deleteAllCalls();

  runApp(MyApp(dao));
}

class MyApp extends StatelessWidget {
  final CallDao dao;

  const MyApp(this.dao, {super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Danny',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: MyHomePage(dao: dao),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key, required this.dao});

  final CallDao dao;
  final FlutterTts tts = FlutterTts();

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void _invokeButtonCall(Call call) {
    widget.tts.speak(call.tts);
  }

// Future event which will show a dialog for adding a new Call
  Future<void> _showMyDialog() async {
    // Controllers for form
    final TextEditingController nameController = TextEditingController();
    final TextEditingController ttsController = TextEditingController();

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Call'),
          content: SingleChildScrollView(
            child: Form(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  ElevatedButton(
                      onPressed: () => {}, child: Text('Hello World')),
                  const SizedBox(height: 15),
                  TextFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Name',
                    ),
                    controller: nameController,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Text to Speech',
                    ),
                    controller: ttsController,
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                final name = nameController.text;
                final tts = ttsController.text;

                Navigator.of(context).pop();
                widget.dao.insertCall(Call(null, name, tts, ""));
              },
            ),
          ],
        );
      },
    );
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
                height: 50,
                margin: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 0.0),
                color: const Color(0xFFFFFFFF),
                child: IconButton(
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0),
                      ),
                    ),
                  ),
                  onPressed: () => _invokeButtonCall(calls[index]),
                  padding: const EdgeInsets.all(0.0),
                  icon: (calls[index].imageBase64.isEmpty
                      ? const Icon(Icons.favorite)
                      : Image.memory(base64Decode(calls[index].imageBase64))),
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
                builder: (context) => AddCallRoute(dao: widget.dao)),
          );
        },
        tooltip: 'Add Call',
        child: const Icon(Icons.add),
      ),
    );
  }
}
