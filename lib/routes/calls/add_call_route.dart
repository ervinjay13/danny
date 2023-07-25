import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

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
  bool _loading = false;

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

  Future<String> _cropSizeAndConvertImage(String path) async {
    var image = await img.decodeImageFile(path);
    if (image == null) throw Exception("Unable to decode image");

    // By default, this size
    var size = 1024;

    // Ensure we can crop to width
    if (image.width <= size) {
      size = image.width;
    }

    // Ensure we can crop to height
    if (image.height <= size) {
      size = image.height;
    }

    // Crop and resize the image so we are always a square format, and
    // not too big
    image = img.copyResizeCropSquare(image, size: size);

    // Always store as a JPG to try keep formats consistent (and smaller)
    final bytes = img.encodeJpg(image, quality: 100);

    return base64Encode(bytes);
  }

  @override
  Widget build(BuildContext context) {
    // Build our custom FABs

    List<Widget> fabList = [];

    var takePhotoFAB = FloatingActionButton.extended(
      onPressed: () async {
        // Do nothing while loading
        if (_loading) {
          return;
        }

        setState(() {
          _loading = true;
        });

        var image = await picker.pickImage(source: ImageSource.camera);
        final croppedImage64 = await _cropSizeAndConvertImage(image!.path);

        setState(() {
          _image64 = croppedImage64;
          _loading = false;
        });
      },
      label: const Text("Take photo"),
      icon: const Icon(Icons.camera_alt),
    );

    var uploadImageFAB = FloatingActionButton.extended(
      onPressed: () async {
        // Do nothing while loading
        if (_loading) {
          return;
        }

        setState(() {
          _loading = true;
        });

        var image = await picker.pickImage(source: ImageSource.gallery);
        final croppedImage64 = await _cropSizeAndConvertImage(image!.path);

        setState(() {
          _image64 = croppedImage64;
          _loading = false;
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

    return LayoutBuilder(
      builder: (context, constraints) => Scaffold(
        appBar: AppBar(
          title: (widget.call == null
              ? const Text('New Call')
              : const Text('Edit call')),
          actions: <Widget>[
            IconButton(
                onPressed: () {
                  // Do nothing while loading
                  if (_loading) {
                    return;
                  }

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
            // Show a loading indicator
            if (_loading == true) {
              return const Center(child: CircularProgressIndicator());
            }

            Widget imagePreview;

            if (_image64 == null) {
              imagePreview = Container();
            } else {
              imagePreview = ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: constraints.maxHeight - 240,
                ),
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.memory(base64Decode(_image64!),
                        fit: BoxFit.cover, alignment: Alignment.center),
                  ),
                ),
              );
            }

            // Return the default style
            return Container(
              padding: const EdgeInsets.all(20.0),
              alignment: Alignment.topCenter,
              child: Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                        "Take a photo or upload an existing image using the buttons below"),
                    const SizedBox(height: 16),
                    TextFormField(
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Text to Speech',
                      ),
                      controller: ttsController,
                    ),
                    const SizedBox(height: 16),
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
      ),
    );
  }
}
