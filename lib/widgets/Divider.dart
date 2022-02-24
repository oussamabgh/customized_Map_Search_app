import 'package:flutter/material.dart';

class DividerWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 0.6,
      color: Colors.amber,
      thickness: 2.0,
      indent: 130.0,
      endIndent: 130.0,
    );
  }
}
