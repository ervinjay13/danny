import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraRoute extends StatefulWidget {
  const CameraRoute({super.key, required this.camera});

  final CameraDescription camera;

  @override
  State<CameraRoute> createState() => _CameraRouteState();
}

class _CameraRouteState extends State<CameraRoute> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        title: const Text('Take Photo'),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            var size = MediaQuery.of(context).size.width;

            return SizedBox(
              width: size,
              height: size,
              child: ClipRect(
                child: OverflowBox(
                  alignment: Alignment.center,
                  child: FittedBox(
                    fit: BoxFit.fitWidth,
                    child: SizedBox(
                      width: size,
                      height: size / _controller.value.aspectRatio,
                      child: CameraPreview(_controller),
                    ),
                  ),
                ),
              ),
            );

            // If the Future is complete, display the preview (as a square image).
            /*  return AspectRatio(
              aspectRatio: 1,
              child: ClipRect(
                child: Transform.scale(
                  scale: 1 / _controller.value.aspectRatio,
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: CameraPreview(_controller),
                    ),
                  ),
                ),
              ),
            );*/
          } else {
            // Otherwise, display a loading indicator.
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        // Provide an onPressed callback.
        onPressed: () async {
          // Take the Picture in a try / catch block. If anything goes wrong,
          // catch the error.
          try {
            // Ensure that the camera is initialized.
            await _initializeControllerFuture;

            // Attempt to take a picture and get the file `image`
            // where it was saved.
            final image = await _controller.takePicture();

            if (!mounted) return;

            // Go back, but with context of the path to the image.
            Navigator.of(context).pop(image.path);

            // If the picture was taken, display it on a new screen.
            //await Navigator.of(context).push(
            //  MaterialPageRoute(
            //    builder: (context) => DisplayPictureScreen(
            // Pass the automatically generated path to
            // the DisplayPictureScreen widget.
            //     imagePath: image.path,
            //   ),
            // ),
            //  );
          } catch (e) {
            // If an error occurs, log the error to the console.
            print(e);
          }
        },
        shape: const CircleBorder(),
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}
