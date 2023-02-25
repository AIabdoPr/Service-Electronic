import 'package:flutter/material.dart';

class BottunScreen extends StatelessWidget {
  final Decoration? decoration;
  final double? height;
  final double? width;
  final String assetName;
  final String text;
  final Color? color;
  final void Function()? onPressed;
  const BottunScreen({
    Key? key,
    required this.text,
    this.color,
    this.onPressed,
    this.decoration,
    required this.assetName,
    this.height,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.height;
    final h = MediaQuery.of(context).size.width;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Colors.black87,
            spreadRadius: 4,
            blurRadius: 10,
            offset: Offset(0, 0),
          )
        ],
      ),
      margin: EdgeInsets.symmetric(vertical: 20),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color.fromARGB(255, 236, 236, 236),
          elevation: 0,
          shadowColor: Color.fromARGB(230, 0, 0, 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: onPressed,
        child: Flex(
          direction: Axis.vertical,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Image.asset(
                assetName,
                fit: BoxFit.fill,
              ),
            ),
            FittedBox(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            )
          ],
        ),
      ),
    );
  }
}
