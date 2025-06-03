import 'package:flutter/material.dart';
import 'package:project_resendis/widgets/settings_dialog.dart';
import 'package:project_resendis/data/user_preferences.dart';

class SettingsButton extends StatelessWidget {
  const SettingsButton({super.key});

  void _openSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const SettingsDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: UserPreferences.themeNotifier,
      builder: (context, themeType, _) {
        // Determinar el color del botón según el tema
        Color buttonColor;
        Color iconColor;
        
        switch (themeType) {
          case AppThemeType.light:
            buttonColor = Colors.white.withOpacity(0.8);
            iconColor = Colors.black87;
            break;
          case AppThemeType.dark:
            buttonColor = Colors.grey[800]!.withOpacity(0.8);
            iconColor = Colors.white;
            break;
          case AppThemeType.teal:
            buttonColor = Colors.teal.withOpacity(0.8);
            iconColor = Colors.white;
            break;
          case AppThemeType.purple:
            buttonColor = Colors.purple.withOpacity(0.8);
            iconColor = Colors.white;
            break;
          case AppThemeType.orange:
            buttonColor = Colors.orange.withOpacity(0.8);
            iconColor = Colors.white;
            break;
          case AppThemeType.blue:
            buttonColor = Colors.blue.withOpacity(0.8);
            iconColor = Colors.white;
            break;
          case AppThemeType.green:
            buttonColor = Colors.green.withOpacity(0.8);
            iconColor = Colors.white;
            break;
          default:
            buttonColor = Colors.white.withOpacity(0.8);
            iconColor = Colors.black87;
        }
        
        return Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: buttonColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 5,
                spreadRadius: 1,
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(Icons.settings, color: iconColor),
            onPressed: () => _openSettingsDialog(context),
            tooltip: 'Configuración',
          ),
        );
      },
    );
  }
}