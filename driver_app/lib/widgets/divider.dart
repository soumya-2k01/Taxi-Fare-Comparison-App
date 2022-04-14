import 'package:flutter/material.dart';

class CustomDivider extends StatelessWidget {
  const CustomDivider({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      color: Colors.grey.shade900,
      thickness: 2.0,
    );
  }
}