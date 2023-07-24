import 'package:flutter/material.dart';


class CameraDisplay extends StatelessWidget {
  const CameraDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
        // children: [SizedBox(
        // //   height: screenHeight * 0.4,
        //   width: screenWidth * 0.09,
        //   child: (cameraController!.value.isInitialized)
        //       ? AspectRatio(
        //       aspectRatio: cameraController!.value.aspectRatio,
        //       child: CameraPreview(cameraController!))
        //       :  Icon(
        //     Icons.hide_image_rounded,
        //     size: 100,
        //   ),
        // ), prototypeItem: Text(
        //   outputCam,
        //   style: const TextStyle(
        //       backgroundColor: Colors.black,
        //       color: Colors.white,
        //       fontSize: 30),textAlign: TextAlign.center,
        // ),
        //]
    );
  }
}
