import 'package:flutter/material.dart';
import 'package:todo/ui/theme.dart';

class MyButton extends StatelessWidget {
  const MyButton({
    Key? key,
    required this.label,
    required this.onTop,
  }) : super(key: key);
  final String label;
  final Function() onTop;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTop,
      child: Container(
          alignment: Alignment.center,
          width: 100,
          height: 45,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10), color: primaryClr),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          )),
    );
  }
}
