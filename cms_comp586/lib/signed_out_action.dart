import 'package:flutter/material.dart';

class SignedOutAction extends StatelessWidget {
  final Function(BuildContext) onPressed;

  const SignedOutAction(this.onPressed, {super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.exit_to_app),
      onPressed: () => onPressed(context),
    );
  }
}
