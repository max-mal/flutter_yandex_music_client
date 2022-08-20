import 'package:flutter/material.dart';

class SplashCodeRequestButton extends StatelessWidget {
  final Function onPressed;
  const SplashCodeRequestButton({
    Key? key,
    required this.onPressed,
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
        label: const Text('Request code'),
      ),
    );
  }
}
