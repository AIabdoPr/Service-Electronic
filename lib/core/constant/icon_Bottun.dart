import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyIconBottun extends StatelessWidget {
  final void Function()? onTap;
  final int count;
  final IconData? icon;
  final Color color;
  final double posX, posY;
  final double? size;

  final double? radius;
  const MyIconBottun({
    Key? key,
    required this.count,
    this.icon,
    this.radius,
    this.color = Colors.red,
    this.posX = 0,
    this.posY = 0,
    this.size,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: w * 0.11,
        child: Stack(
          children: [
            Positioned(
              top: 12,
              left: 0,
              child: Icon(
                icon,
                size: 35,
              ),
            ),
            if (count != 0)
              Positioned(
                top: 10,
                left: posX,
                child: Container(
                  width: size ?? 20,
                  height: size ?? 20,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text('${count < 10 ? count : '9+'}'),
                ),
              )
          ],
        ),
      ),
    );
  }
}
