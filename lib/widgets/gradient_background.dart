import 'package:flutter/material.dart';
import 'package:project_resendis/data/user_preferences.dart';

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
    return ValueListenableBuilder(
      valueListenable: UserPreferences.themeNotifier,
      builder: (context, themeType, _) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        
        // Determinar los colores del gradiente según el tema seleccionado
        List<Color> gradientColors = colors ?? _getThemeColors(themeType, isDarkMode);
        
        return AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors,
            ),
          ),
          child: child,
        );
      },
    );
  }
  
  List<Color> _getThemeColors(AppThemeType themeType, bool isDarkMode) {
    switch (themeType) {
      case AppThemeType.light:
        return [Colors.blue.shade100, Colors.blue.shade300];
      case AppThemeType.dark:
        return [Colors.grey.shade900, Colors.black];
      case AppThemeType.teal:
        return [Colors.teal.shade300, Colors.teal.shade700];
      case AppThemeType.purple:
        return [Colors.purple.shade300, Colors.purple.shade700];
      case AppThemeType.orange:
        return [Colors.orange.shade300, Colors.orange.shade700];
      case AppThemeType.blue:
        return [Colors.blue.shade300, Colors.blue.shade700];
      case AppThemeType.green:
        return [Colors.green.shade300, Colors.green.shade700];
      default:
        return isDarkMode
            ? [Colors.grey.shade900, Colors.black]
            : [Colors.blue.shade100, Colors.blue.shade300];
    }
  }
}