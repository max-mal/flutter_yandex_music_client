import 'package:flutter/material.dart';

class SplashCodeRequestButton extends StatelessWidget {
  final Function onPressed;
  final String text;
  const SplashCodeRequestButton({
    Key? key,
    required this.onPressed,
    this.text = 'Request code',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextButton.icon(
        onPressed: () {
          onPressed();
        },
        icon: const Icon(Icons.login),
        label: Text(text),
      ),
    );
  }
}
