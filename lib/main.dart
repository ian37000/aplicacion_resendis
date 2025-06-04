import 'package:flutter/material.dart';
import 'package:project_resendis/data/notifiers.dart';
import 'package:project_resendis/data/user_preferences.dart';
import 'package:project_resendis/views/pages/start_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:project_resendis/styles/app_theme.dart';
import 'package:project_resendis/widgets/settings_button.dart';
//un lefsito
//Hola luis
//hola evan
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: UserPreferences.themeNotifier,
      builder: (context, themeType, child) {
        // Sincronizar el notificador de tema oscuro con el nuevo sistema de temas
        isDarkModeNotifier.value = themeType == AppThemeType.dark;
        
        return ValueListenableBuilder(
          valueListenable: UserPreferences.fontSizeNotifier,
          builder: (context, fontSize, _) {
            return ValueListenableBuilder(
              valueListenable: UserPreferences.fontNotifier,
              builder: (context, font, _) {
                // Obtener el nombre de la fuente seleccionada
                String fontFamily = _getFontFamily(font);
                
                return ValueListenableBuilder(
                  valueListenable: UserPreferences.languageNotifier,
                  builder: (context, language, _) {
                    return MaterialApp(
                      debugShowCheckedModeBanner: false,
                      theme: _getThemeData(themeType, false, fontFamily, fontSize),
                      darkTheme: _getThemeData(themeType, true, fontFamily, fontSize),
                      themeMode: _getThemeMode(themeType),
                      home: const AppWrapper(child: StartPage()),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
  
  // Método para obtener el nombre de la fuente según la selección
  String _getFontFamily(AppFont font) {
    switch (font) {
      case AppFont.roboto: return 'Roboto';
      case AppFont.openSans: return 'OpenSans';
      case AppFont.lato: return 'Lato';
      case AppFont.montserrat: return 'Montserrat';
      case AppFont.poppins: return 'Poppins';
      default: return 'Roboto';
    }
  }
  
  ThemeMode _getThemeMode(AppThemeType themeType) {
    switch (themeType) {
      case AppThemeType.light:
        return ThemeMode.light;
      case AppThemeType.dark:
        return ThemeMode.dark;
      default:
        // Para los temas personalizados, usamos el modo claro
        return ThemeMode.light;
    }
  }
  
  ThemeData _getThemeData(AppThemeType themeType, bool isDark, String fontFamily, double fontSize) {
    // Primero obtenemos el tema base (claro u oscuro)
    ThemeData baseTheme = isDark ? AppTheme.getDarkTheme() : AppTheme.getLightTheme();
    
    // Aplicar la fuente y el tamaño de fuente
    baseTheme = baseTheme.copyWith(
      textTheme: baseTheme.textTheme.apply(
        fontFamily: fontFamily,
        fontSizeFactor: fontSize,
      ),
      primaryTextTheme: baseTheme.primaryTextTheme.apply(
        fontFamily: fontFamily,
        fontSizeFactor: fontSize,
      ),
    );
    
    // Luego aplicamos los colores específicos según el tipo de tema seleccionado
    Color primaryColor;
    Color secondaryColor;
    
    switch (themeType) {
      case AppThemeType.light:
      case AppThemeType.dark:
        return baseTheme; // Usamos los temas base sin modificaciones de color
      case AppThemeType.teal:
        primaryColor = Colors.teal;
        secondaryColor = Colors.tealAccent;
        break;
      case AppThemeType.purple:
        primaryColor = Colors.purple;
        secondaryColor = Colors.purpleAccent;
        break;
      case AppThemeType.orange:
        primaryColor = Colors.orange;
        secondaryColor = Colors.orangeAccent;
        break;
      case AppThemeType.blue:
        primaryColor = Colors.blue;
        secondaryColor = Colors.blueAccent;
        break;
      case AppThemeType.green:
        primaryColor = Colors.green;
        secondaryColor = Colors.greenAccent;
        break;
      default:
        return baseTheme;
    }
    
    // Aplicar colores de manera más completa para temas personalizados
    return baseTheme.copyWith(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: isDark ? Colors.grey[900] : Colors.white,
      colorScheme: baseTheme.colorScheme.copyWith(
        primary: primaryColor,
        secondary: secondaryColor,
        // Asegurar que estos colores se apliquen a más elementos
        onPrimary: Colors.white,
        primaryContainer: primaryColor.withOpacity(0.8),
        secondaryContainer: secondaryColor.withOpacity(0.8),
      ),
      // Aplicar el color a más componentes
      appBarTheme: baseTheme.appBarTheme.copyWith(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),
      ),
      // Asegurar que el color se aplique a los botones de texto también
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
        ),
      ),
      // Aplicar color a los iconos
      iconTheme: IconThemeData(
        color: primaryColor,
      ),
    );
  }
}

class AppWrapper extends StatelessWidget {
  final Widget child;

  const AppWrapper({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      floatingActionButton: const SettingsButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
    );
  }
}

//holaaaaaaaaaaaaaa