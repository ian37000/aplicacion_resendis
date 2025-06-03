import 'package:flutter/material.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;
  final List<Color>? colors;

  const GradientBackground({
    Key? key,
    required this.child,
    this.colors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors ?? (isDark 
            ? [
                Colors.black.withOpacity(0.9),
                Colors.black,
              ] 
            : [
                Theme.of(context).primaryColor.withOpacity(0.1),
                Colors.white,
              ]),
        ),
      ),
      child: child,
    );
  }
}