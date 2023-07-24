import 'dart:io';

import 'package:flutter/material.dart';

class PhotoDisplay extends StatelessWidget {
  File? image;
  PhotoDisplay({Key? key, required this.image}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Column(
      // children: [
      //   imageSelect
      //       ? Image.file(
      //           image!,
      //           height: screenHeight * 0.4,
      //           width: screenWidth * 0.09,
      //         )
      //       : const Icon(
      //           Icons.hide_image_rounded,
      //           size: 100,
      //         ),
      //   const SizedBox(height: 20),
      //   SingleChildScrollView(
      //       child: Column(
      //     children: imageSelect
      //         ? result.map((result) {
      //             return Card(
      //               child: Container(
      //                 margin: const EdgeInsets.all(8),
      //                 child: Text(
      //                   "${result["label"]} - ${result["confidence"].toStringAsFixed(2)}", // toStringAsFixed(2)
      //                   style:
      //                       const TextStyle(color: Colors.blue, fontSize: 20),
      //                 ),
      //               ),
      //             );
      //           }).toList()
      //         : [],
      //   )),
      // ],
    );
  }
}
