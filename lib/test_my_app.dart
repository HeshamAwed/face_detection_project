import 'package:flutter/material.dart';

import 'face_detector/face_detector_view.dart';
import 'self_detector/selfie_segmenter_view.dart';
import 'utils/custom_card.dart';

class TestMyApp extends StatelessWidget {
  const TestMyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Face Detection"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ExpansionTile(
          title: const Text('Image Profile'),
          initiallyExpanded: true,
          children: [
            CustomCard('Face Detection', FaceDetectorView()),
            CustomCard('Selfie Segmentation', SelfieSegmenterView()),
          ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
