import 'package:flutter/material.dart';

class MyTab extends StatelessWidget {
  final IconData iconData;
  final String text;

  const MyTab({Key? key, required this.iconData, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tab(
      height: 90,
      child: Container(
        padding: EdgeInsets.all(12),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
            Icon(
              iconData,
              size: 35,
            ),
            Text(
              text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            )
          ]
        )
      ),
    );
  }
}
