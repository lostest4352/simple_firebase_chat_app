// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class UserTextField extends StatefulWidget {
  final TextEditingController textController;
  final String hintText;
  final Widget? suffixIcon;
  final bool? obscureText;

  const UserTextField({
    Key? key,
    required this.textController,
    required this.hintText,
    this.suffixIcon,
    this.obscureText,
  }) : super(key: key);

  @override
  State<UserTextField> createState() => _UserTextFieldState();
}

class _UserTextFieldState extends State<UserTextField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 25,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          border: Border.all(
            color: Colors.grey,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: TextField(
            obscureText: widget.obscureText ?? false,
            onTapOutside: (event) {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            controller: widget.textController,
            decoration: InputDecoration(
              hintText: widget.hintText,
              border: InputBorder.none,
              suffixIcon: widget.suffixIcon,
            ),
          ),
        ),
      ),
    );
  }
}
