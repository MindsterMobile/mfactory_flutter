import 'package:flutter/material.dart';
import '../utils/colors.dart';

class AppProgressWidget extends StatelessWidget {
  final Color? color;
  final double size;

  const AppProgressWidget({
    super.key,
    this.color,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          color: color ?? FactoryColors.primary,
          strokeWidth: 3,
        ),
      ),
    );
  }
}
