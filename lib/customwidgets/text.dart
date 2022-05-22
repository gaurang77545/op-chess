import 'package:flutter/material.dart';

class TextPlain extends StatefulWidget {
  String title;
  FontWeight? fontWeight;
  double? fontSize;
  double? letterSpacing;
  Color? color;
  TextOverflow? overflow;
  TextAlign? textAlign;
  TextPlain(this.title,
      {this.color,
      this.fontWeight,
      this.fontSize,
      this.letterSpacing,
      this.textAlign,
      this.overflow});

  @override
  State<TextPlain> createState() => _TextPlainState();
}

class _TextPlainState extends State<TextPlain> {
  @override
  Widget build(BuildContext context) {
    return Text(widget.title,
        style: TextStyle(
          color: widget.color,
          fontWeight: widget.fontWeight,
          fontSize: widget.fontSize,
          letterSpacing: widget.letterSpacing,
        ),
        textAlign: widget.textAlign,
        overflow: widget.overflow);
  }
}
