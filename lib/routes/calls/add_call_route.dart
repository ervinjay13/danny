import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../common/call.dart';
import '../../common/call_dao.dart';

class AddCallRoute extends StatefulWidget {
  const AddCallRoute({super.key, required this.dao, this.call});

  final CallDao dao;
  final Call? call;

  @override
  State<AddCallRoute> createState() => _AddCallRouteState();
}

class _AddCallRouteState extends State<AddCallRoute> {
  // Raw image data
  String? _image64;

  // Controllers for form
  final TextEditingController ttsController = TextEditingController();

  // The actual picker used to grab images
  final ImagePicker picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    // Set existing data (if not null, aka we are editing)
    if (widget.call != null) {
      ttsController.text = widget.call!.tts;
      _image64 = widget.call!.imageBase64;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Build our custom FABs

    List<Widget> fabList = [];

    var takePhotoFAB = FloatingActionButton.extended(
      onPressed: () async {
        var image = await picker.pickImage(
            source: ImageSource.camera, maxWidth: 1024, maxHeight: 1024);

        final bytes = await File(image!.path).readAsBytes();

        setState(() {
          _image64 = base64Encode(bytes);
        });
      },
      label: const Text("Take photo"),
      icon: const Icon(Icons.camera_alt),
    );

    var uploadImageFAB = FloatingActionButton.extended(
      onPressed: () async {
        var image = await picker.pickImage(
            source: ImageSource.gallery, maxWidth: 1024, maxHeight: 1024);

        final bytes = await File(image!.path).readAsBytes();

        setState(() {
          _image64 = base64Encode(bytes);
        });
      },
      label: const Text("Upload image"),
      icon: const Icon(Icons.file_upload_outlined),
    );

    var removeImageFAB = FloatingActionButton.extended(
      onPressed: () {
        setState(() {
          _image64 = null;
        });
      },
      label: const Text("Remove image"),
      icon: const Icon(Icons.cancel),
    );

    if (_image64 == null) {
      fabList.add(takePhotoFAB);
      fabList.add(const SizedBox(width: 30));
      fabList.add(uploadImageFAB);
    } else {
      fabList.add(removeImageFAB);
    }

    return Scaffold(
      appBar: AppBar(
        title: (widget.call == null
            ? const Text('New Call')
            : const Text('Edit call')),
        actions: <Widget>[
          IconButton(
              onPressed: () {
                final tts = ttsController.text;
                var existingCall = widget.call;

                if (tts.isNotEmpty && _image64 != null) {
                  if (existingCall == null) {
                    widget.dao.insertCall(Call(null, tts, _image64!));
                  } else {
                    widget.dao
                        .updateCall(Call(existingCall.id, tts, _image64!));
                  }

                  Navigator.of(context).pop();
                }
              },
              tooltip: "Save call",
              icon: const Icon(Icons.save))
        ],
      ),
      body: Builder(
        builder: (context) {
          Widget imagePreview;

          if (_image64 == null) {
            imagePreview = Container();
          } else {
            imagePreview = AspectRatio(
              aspectRatio: 1.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.memory(base64Decode(_image64!),
                    fit: BoxFit.cover, alignment: Alignment.center),
              ),
            );
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
                  imagePreview,
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: fabList,
      ),
    );
  }
}
