import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeSecondaryListItem extends StatelessWidget {
  final String title;
  final Icon icon;
  final Function onPressed;

  const HomeSecondaryListItem({
    Key? key,
    required this.title,
    required this.icon,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: GetPlatform.isMobile ? null : 200,
      color: Colors.grey.withOpacity(0.3),
      padding: const EdgeInsets.all(15.0),
      margin: const EdgeInsets.all(8.0),
      child: TextButton.icon(
        onPressed: () {
          onPressed();
        },
        icon: icon,
        label: Text(title),
      ),
    );
  }
}
