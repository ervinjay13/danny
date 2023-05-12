import 'package:danny/routes/camera_route.dart';
import 'package:flutter/material.dart';

import '../common/call.dart';
import '../common/call_dao.dart';

class AddCallRoute extends StatelessWidget {
  AddCallRoute({super.key, required this.dao});

  final CallDao dao;

  // Controllers for form
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ttsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        title: const Text('Add Call'),
        actions: <Widget>[
          IconButton(
              onPressed: () {
                final name = nameController.text;
                final tts = ttsController.text;

                Navigator.of(context).pop();
                dao.insertCall(Call(null, name, tts, ""));
              },
              icon: const Icon(Icons.save))
        ],
      ),
      body: Container(
        padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
        alignment: Alignment.topCenter,
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
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
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        fullscreenDialog: true,
                        builder: (context) => const CameraRoute()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                child: const Text('Take Photo'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
