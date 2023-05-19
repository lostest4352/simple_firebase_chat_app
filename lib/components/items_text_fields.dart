// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class ItemsTextField extends StatefulWidget {
  final TextEditingController textController;
  final String hintText;
  final Widget? suffixIcon;
  final bool? obscureText;

  const ItemsTextField({
    Key? key,
    required this.textController,
    required this.hintText,
    this.suffixIcon,
    this.obscureText,
  }) : super(key: key);

  @override
  State<ItemsTextField> createState() => _ItemsTextFieldState();
}

class _ItemsTextFieldState extends State<ItemsTextField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 25,
      ),
      child: TextField(
        obscureText: widget.obscureText ?? false,
        onTapOutside: (event) {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        controller: widget.textController,
        decoration: InputDecoration(
          hintText: widget.hintText,
          // border: InputBorder.none,
          suffixIcon: widget.suffixIcon,
        ),
      ),
    );
  }
}
