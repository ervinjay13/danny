import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
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
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  // The path of the image
  XFile? _image;

  // Controllers for form
  final TextEditingController ttsController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Check for cameras on the device
    availableCameras();

    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(widget.camera, ResolutionPreset.high,
        enableAudio: false, imageFormatGroup: ImageFormatGroup.jpeg);

    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _isValid() {
    return ttsController.text.isNotEmpty && _image != null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        title: const Text('New call'),
        actions: <Widget>[
          IconButton(
              onPressed: () {
                final tts = ttsController.text;
                String img64 = "";

                if (_image != null) {
                  final bytes = File(_image!.path).readAsBytesSync();
                  img64 = base64Encode(bytes);
                }

                widget.dao.insertCall(Call(null, tts, img64));
                Navigator.of(context).pop();
              },
              tooltip: "Save call",
              icon: const Icon(Icons.save))
        ],
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          var size = MediaQuery.of(context).size.width;

          Widget cameraPreview;

          // We need to determine what to display in the camera / photo section. This can either be
          // a loading indicator (for when the camera is loading), the existing image, or the camera
          // preview to take a new photo
          if (snapshot.connectionState == ConnectionState.done) {
            if (_image == null) {
              cameraPreview = AspectRatio(
                aspectRatio: 1.0,
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: CameraPreview(_controller)),
              );
            } else {
              cameraPreview = AspectRatio(
                aspectRatio: 1.0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.file(File(_image!.path),
                      fit: BoxFit.cover, alignment: Alignment.center),
                ),
              );
            }
          } else {
            cameraPreview = const Center(child: CircularProgressIndicator());
          }

          // Return the default style
          return Container(
            padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
            alignment: Alignment.topCenter,
            child: Form(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text("Click the photo button below to take a photo"),
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
                  cameraPreview,
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Handle the case of removing an existing image
          if (_image != null) {
            setState(() {
              _image = null;
            });

            return;
          }

          // Take the Picture in a try / catch block. If anything goes wrong,
          // catch the error.
          try {
            // Ensure that the camera is initialized.
            await _initializeControllerFuture;

            // Attempt to take a picture and get the file `image`
            // where it was saved.
            var image = await _controller.takePicture();

            // Set our state to ensure the UI is updated
            setState(() {
              _image = image;
            });
          } catch (e) {
            // Setup an alert dialog to show the error back to the user
            AlertDialog alert = AlertDialog(
              title: const Text("Error taking photo"),
              content: Text(e.toString()),
              actions: [
                TextButton(
                  child: const Text("OK"),
                  onPressed: () {},
                ),
              ],
            );

            // show the dialog
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return alert;
              },
            );
          }
        },
        shape: const CircleBorder(),
        tooltip: (_image == null ? "Take photo" : "Remove photo"),
        child: (_image == null
            ? const Icon(Icons.camera_alt)
            : const Icon(Icons.cancel)),
      ),
    );
  }
}
