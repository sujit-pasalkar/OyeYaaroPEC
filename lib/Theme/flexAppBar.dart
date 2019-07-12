import 'package:flutter/material.dart';

class FlexAppbar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xffb578de3),
            Color(0xffb4fcce0),
          ],
        ),
      ),
    );
  }
}
