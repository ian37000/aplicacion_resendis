import 'package:flutter/material.dart';

// Enumeración para los idiomas disponibles
enum AppLanguage { spanish, english, chinese, german, french }

// Enumeración para los temas disponibles
enum AppThemeType { light, dark, teal, purple, orange, blue, green }

// Enumeración para las fuentes disponibles
enum AppFont { roboto, openSans, lato, montserrat, poppins }

// Clase para manejar las preferencias del usuario
class UserPreferences {
  static final ValueNotifier<AppLanguage> languageNotifier = 
      ValueNotifier(AppLanguage.spanish);
      
  static final ValueNotifier<AppThemeType> themeNotifier = 
      ValueNotifier(AppThemeType.dark);
      
  static final ValueNotifier<AppFont> fontNotifier = 
      ValueNotifier(AppFont.roboto);
      
  static final ValueNotifier<double> fontSizeNotifier = 
      ValueNotifier(1.0); // Factor de escala (1.0 = normal)
      
  // Método para obtener el nombre del idioma actual
  static String getCurrentLanguageName() {
    switch (languageNotifier.value) {
      case AppLanguage.spanish: return 'Español';
      case AppLanguage.english: return 'English';
      case AppLanguage.chinese: return '中文';
      case AppLanguage.german: return 'Deutsch';
      case AppLanguage.french: return 'Français';
    }
  }
  
  // Método para obtener el nombre del tema actual
  static String getCurrentThemeName() {
    switch (themeNotifier.value) {
      case AppThemeType.light: return 'Claro';
      case AppThemeType.dark: return 'Oscuro';
      case AppThemeType.teal: return 'Turquesa';
      case AppThemeType.purple: return 'Púrpura';
      case AppThemeType.orange: return 'Naranja';
      case AppThemeType.blue: return 'Azul';
      case AppThemeType.green: return 'Verde';
    }
  }
  
  // Método para obtener el nombre de la fuente actual
  static String getCurrentFontName() {
    switch (fontNotifier.value) {
      case AppFont.roboto: return 'Roboto';
      case AppFont.openSans: return 'Open Sans';
      case AppFont.lato: return 'Lato';
      case AppFont.montserrat: return 'Montserrat';
      case AppFont.poppins: return 'Poppins';
    }
  }
}