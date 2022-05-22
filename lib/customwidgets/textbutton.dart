import 'package:flutter/material.dart';

class TextButtonSimple extends StatefulWidget {
  Widget child;
  final VoidCallback? onPressed;
  TextButtonSimple({required this.child, this.onPressed});

  @override
  State<TextButtonSimple> createState() => _TextButtonSimpleState();
}

class _TextButtonSimpleState extends State<TextButtonSimple> {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: widget.onPressed,
      child: widget.child,
      
    );
  }
}
