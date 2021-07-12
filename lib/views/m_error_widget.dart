import 'package:flutter/material.dart';

class MErrorWidget extends StatelessWidget {
  final Widget? refreshWidget;
  final String error;

  const MErrorWidget({Key? key, this.refreshWidget, required this.error})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(
          child: Padding(
              padding: EdgeInsets.all(16.00),
              child: Text(error)),
        ),
        if (this.refreshWidget != null) Center(child: this.refreshWidget)
      ],
    );
  }
}
