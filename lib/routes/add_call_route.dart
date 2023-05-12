import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:danny/routes/camera_route.dart';
import 'package:flutter/material.dart';

import '../common/call.dart';
import '../common/call_dao.dart';

class AddCallRoute extends StatefulWidget {
  const AddCallRoute({super.key, required this.dao, required this.camera});

  final CallDao dao;
  final CameraDescription camera;

  @override
  State<AddCallRoute> createState() => _AddCallRouteState();
}

class _AddCallRouteState extends State<AddCallRoute> {
  // The path of the image
  String? _imagePath;

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
                String img64 = "";
                                
                if (_imagePath != null) {
                  final bytes = File(_imagePath!).readAsBytesSync();
                  img64 = base64Encode(bytes);
                }
                
                widget.dao.insertCall(Call(null, name, tts, img64));
                Navigator.of(context).pop();
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
                        builder: (context) =>
                            CameraRoute(camera: widget.camera)),
                  ).then((value) {
                    setState(() {
                      _imagePath = value;
                    });
                  });
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                child: const Text('Take Photo'),
              ),
              const SizedBox(height: 15),
              (_imagePath != null
                  ? Image.file(File(_imagePath!))
                  : Container()),
              Text(_imagePath ?? "No Image"),
            ],
          ),
        ),
      ),
    );
  }
}
