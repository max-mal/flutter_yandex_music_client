import 'package:flutter/material.dart';

class CounterIconButton extends StatelessWidget {
  final int counter;
  final Function onPressed;
  final Icon icon;

  const CounterIconButton({
    Key? key,
    required this.onPressed,
    required this.icon,
    this.counter = 0,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          onPressed: () {
            onPressed();
          },
          icon: icon,
        ),
        Positioned(
          top: 0,
          right: 0,
          child: counter == 0
              ? const SizedBox()
              : Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                  ),
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    "$counter",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
