import 'package:flutter/material.dart';
class ImageProcessor extends StatefulWidget {
  @override
  _ImageProcessorState createState() => _ImageProcessorState();
}

class _ImageProcessorState extends State<ImageProcessor> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Movie Maker'),),
      body: Center(
        child: Text('user multi_imge_picker plugin..'),
      ),
      
    );
  }
}