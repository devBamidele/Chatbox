import 'package:chatbox/res/style/component_style.dart';
import 'package:flutter/material.dart';

class LoginOptions extends StatelessWidget {
  const LoginOptions({
    Key? key,
    required this.onTap,
    required this.path,
    this.scale = 1,
  }) : super(key: key);

  final VoidCallback onTap;
  final String path;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: loginOptionsStyle,
      child: Transform.scale(
        scale: scale,
        child: Image.asset(path),
      ),
    );
  }
}
