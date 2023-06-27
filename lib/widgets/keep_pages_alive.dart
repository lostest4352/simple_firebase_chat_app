// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class KeepPageAlive extends StatefulWidget {
  final Widget child;
  const KeepPageAlive({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<KeepPageAlive> createState() => _KeepPageAliveState();
}

class _KeepPageAliveState extends State<KeepPageAlive>
    with AutomaticKeepAliveClientMixin<KeepPageAlive> {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }

  @override
  bool get wantKeepAlive => true;
}
