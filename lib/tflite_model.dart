import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_class_iden_project/camera_display.dart';
import 'package:image_class_iden_project/photo_display.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

import 'main.dart';

class TfliteModel extends StatefulWidget {
  const TfliteModel({super.key});

  @override
  State<TfliteModel> createState() => _TfliteModelState();
}

class _TfliteModelState extends State<TfliteModel> {
  int displaySelect = 0;
  bool noDisplay =true;
  
  File? image;
  List result = [];
  bool imageSelect = false;

  
  String outputCam = "";
  CameraController? cameraController;
  CameraImage? cameraImage;

  @override
  void initState() {
    super.initState();
    displaySelect = 2;
    loadModel().then((value) {
      setState(() {});
    });
    //loadCamera();
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    await Tflite.close();
    cameraController?.dispose();
  }

  Future loadModel() async {
    String res;
    res = (await Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt",
    ))!;
    print("Models loading status: $res");
  }

  loadCamera() {
    cameraController = CameraController(cameras[0], ResolutionPreset.medium);
    cameraController!.initialize().then((value) {
      noDisplay =false;
      if (!mounted) {
        return;
      } else {
        setState(() {
          noDisplay =false;
          displaySelect =1;

          cameraController!.startImageStream((image) {
            cameraImage = image;
            runModel();

          });
        });
      }
    });
  }

  runModel() async {
    if (cameraImage != null) {
      var pred = await Tflite.runModelOnFrame(
          bytesList: cameraImage!.planes.map((plane) {
            return plane.bytes;
          }).toList(),
          imageHeight: cameraImage!.height,
          imageWidth: cameraImage!.width,
          imageMean: 127.5,
          imageStd: 127.5,
          rotation: 90,
          numResults: 5,
          threshold: 0.1,
          asynch: true);
      for (var element in pred!) {
        setState(() {
          outputCam = element['label'] +
              " " +
              (element['confidence'] as double).toStringAsFixed(2) +
              "\n\n";
        });
      }
    }
  }

  Future pickImage(ImageSource imageSource) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: imageSource);
      final imageTemporary = File(image!.path);
      setState(() {
        imageSelect = true;
        this.image = imageTemporary;

        noDisplay =false;
        displaySelect =0;
      });
      imageClassification(imageTemporary);
    } on PlatformException catch (e) {
      print("Failed to pick image $e");
    }
  }

  Future imageClassification(File img) async {
    final List? recognitions = await Tflite.runModelOnImage(
        path: img.path,
        // required
        imageMean: 127.5,
        // defaults to 117.0
        imageStd: 127.5,
        // defaults to 1.0
        numResults: 6,
        // defaults to 5
        threshold: 0.5,
        // defaults to 0.1
        asynch: true // defaults to true
        );
    setState(() {
      result = recognitions!;
      image = img;
      imageSelect = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height*0.4;
    double screenWidth = MediaQuery.of(context).size.width*0.9;

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [display(screenHeight, screenWidth),
          // SizedBox(
          //   height: screenHeight * 0.4,
          //   width: screenWidth * 0.09,
          //   child: (cameraController!.value.isInitialized)
          //       ? AspectRatio(
          //           aspectRatio: cameraController!.value.aspectRatio,
          //           child: CameraPreview(cameraController!))
          //       : const Icon(
          //             Icons.hide_image_rounded,
          //             size: 100,
          //           ),
          // ),
          // Text(
          //   outputCam,
          //   style: const TextStyle(
          //       backgroundColor: Colors.black,
          //       color: Colors.white,
          //       fontSize: 30),textAlign: TextAlign.center,
          // ),
          // imageSelect
          //     ? Image.file(
          //         image!,
          //         height: screenHeight * 0.4,
          //         width: screenWidth * 0.09,
          //       )
          //     : const Icon(
          //         Icons.hide_image_rounded,
          //         size: 100,
          //       ),
          // const SizedBox(height: 20),
          // SingleChildScrollView(
          //     child: Column(
          //   children: imageSelect
          //       ? result.map((result) {
          //           return Card(
          //             child: Container(
          //               margin: const EdgeInsets.all(8),
          //               child: Text(
          //                 "${result["label"]} - ${result["confidence"].toStringAsFixed(2)}", // toStringAsFixed(2)
          //                 style:
          //                     const TextStyle(color: Colors.blue, fontSize: 20),
          //               ),
          //             ),
          //           );
          //         }).toList()
          //       : [],
          // )),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              loadCamera(); //pickImage(ImageSource.camera);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            icon: const Icon(Icons.camera_alt),
            label: const Text('pick camera'),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              pickImage(ImageSource.gallery);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            icon: const Icon(Icons.image),
            label: const Text('pick Image'),
          )
        ],
      ),
    );
  }
Widget display (height,width){
   return noDisplay ? const Icon(
     Icons.hide_image_rounded,
     size: 100,
   ):
   (displaySelect ==0) ?
   Column(
     children: [
       imageSelect
           ? Image.file(
         image!,
         height: height,
         width: width,
       )
           : const Icon(
         Icons.hide_image_rounded,
         size: 100,
       ),
       const SizedBox(height: 20),
       SingleChildScrollView(
           child: Column(
             children: imageSelect
                 ? result.map((result) {
               return Card(
                 child: Container(
                   margin: const EdgeInsets.all(8),
                   child: Text(
                     "${result["label"]} - ${result["confidence"].toStringAsFixed(2)}", // toStringAsFixed(2)
                     style:
                     const TextStyle(color: Colors.blue, fontSize: 20),
                   ),
                 ),
               );
             }).toList()
                 : [],
           )),
     ],
   )
       
       
       
       
       : Column(
       children: [SizedBox(
         height: height,
         width: width,
         child: (cameraController!.value.isInitialized)
             ? AspectRatio(
             aspectRatio: cameraController!.value.aspectRatio,
             child: CameraPreview(cameraController!))
             :  const Icon(
           Icons.hide_image_rounded,
           size: 100,
         ),
       ),  Text(
         outputCam,
         style: const TextStyle(
             backgroundColor: Colors.black,
             color: Colors.white,
             fontSize: 30),textAlign: TextAlign.center,
       ),
       ]);
       
}
}
