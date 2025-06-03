import 'package:flutter/material.dart';
import 'package:project_resendis/data/user_preferences.dart';
import 'package:project_resendis/styles/app_dimensions.dart';
import 'package:project_resendis/styles/app_colors.dart';

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Variables para almacenar temporalmente las preferencias
  late AppThemeType _selectedTheme;
  late AppFont _selectedFont;
  late double _selectedFontSize;
  late AppLanguage _selectedLanguage;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Inicializar con los valores actuales
    _selectedTheme = UserPreferences.themeNotifier.value;
    _selectedFont = UserPreferences.fontNotifier.value;
    _selectedFontSize = UserPreferences.fontSizeNotifier.value;
    _selectedLanguage = UserPreferences.languageNotifier.value;
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Método para aplicar los cambios
  void _applyChanges() {
    // Aplicar los cambios a los notificadores
    UserPreferences.themeNotifier.value = _selectedTheme;
    UserPreferences.fontNotifier.value = _selectedFont;
    UserPreferences.fontSizeNotifier.value = _selectedFontSize;
    UserPreferences.languageNotifier.value = _selectedLanguage;
    
    // Forzar una reconstrucción de la interfaz
    setState(() {});
    
    // Mostrar un mensaje de confirmación
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Configuración actualizada'),
        duration: Duration(seconds: 2),
      ),
    );
    
    // Cerrar el diálogo
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
      ),
      elevation: 8,
      backgroundColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Título del diálogo
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Configuración',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Pestañas de configuración
            TabBar(
              controller: _tabController,
              labelColor: isDarkMode ? Colors.teal.shade300 : Colors.teal.shade700,
              unselectedLabelColor: isDarkMode ? Colors.white70 : Colors.black54,
              indicatorColor: isDarkMode ? Colors.teal.shade300 : Colors.teal.shade700,
              tabs: const [
                Tab(text: 'Tema', icon: Icon(Icons.color_lens)),
                Tab(text: 'Fuente', icon: Icon(Icons.text_fields)),
                Tab(text: 'Idioma', icon: Icon(Icons.language)),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Contenido de las pestañas
            SizedBox(
              height: 300,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildThemeTab(),
                  _buildFontTab(),
                  _buildLanguageTab(),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Botón de aceptar cambios
            ElevatedButton(
              onPressed: _applyChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check),
                  SizedBox(width: 8),
                  Text('Aceptar Cambios'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Pestaña de temas
  Widget _buildThemeTab() {
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      children: [
        _themeOption(AppThemeType.light, 'Claro', Colors.white, Colors.black),
        _themeOption(AppThemeType.dark, 'Oscuro', Colors.black, Colors.white),
        _themeOption(AppThemeType.teal, 'Turquesa', Colors.teal, Colors.white),
        _themeOption(AppThemeType.purple, 'Púrpura', Colors.purple, Colors.white),
        _themeOption(AppThemeType.orange, 'Naranja', Colors.orange, Colors.white),
        _themeOption(AppThemeType.blue, 'Azul', Colors.blue, Colors.white),
        _themeOption(AppThemeType.green, 'Verde', Colors.green, Colors.white),
      ],
    );
  }
  
  // Opción de tema
  Widget _themeOption(AppThemeType type, String name, Color color, Color textColor) {
    final isSelected = _selectedTheme == type;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTheme = type;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
          border: Border.all(
            color: isSelected ? Colors.teal.shade400 : Colors.grey.withOpacity(0.3),
            width: isSelected ? 3 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: textColor,
              size: 30,
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: TextStyle(
                color: textColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Pestaña de fuentes
  Widget _buildFontTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tipo de Fuente',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Column(
          children: [
            _fontOption(AppFont.roboto, 'Roboto'),
            _fontOption(AppFont.openSans, 'Open Sans'),
            _fontOption(AppFont.lato, 'Lato'),
            _fontOption(AppFont.montserrat, 'Montserrat'),
            _fontOption(AppFont.poppins, 'Poppins'),
          ],
        ),
        const SizedBox(height: 20),
        const Text(
          'Tamaño de Fuente',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Column(
          children: [
            Slider(
              value: _selectedFontSize,
              min: 0.8,
              max: 1.4,
              divisions: 6,
              label: _selectedFontSize == 1.0 ? 'Normal' : 
                     _selectedFontSize < 1.0 ? 'Pequeño' : 'Grande',
              onChanged: (value) {
                setState(() {
                  _selectedFontSize = value;
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Pequeño'),
                const Text('Normal'),
                const Text('Grande'),
              ],
            ),
          ],
        ),
      ],
    );
  }
  
  // Opción de fuente
  Widget _fontOption(AppFont font, String name) {
    final isSelected = _selectedFont == font;
    
    return ListTile(
      title: Text(
        name,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          // Aquí se podría aplicar la fuente real si estuviera disponible
        ),
      ),
      trailing: isSelected ? const Icon(Icons.check, color: Colors.teal) : null,
      onTap: () {
        setState(() {
          _selectedFont = font;
        });
      },
    );
  }
  
  // Pestaña de idiomas
  Widget _buildLanguageTab() {
    return Column(
      children: [
        _languageOption(AppLanguage.spanish, 'Español', '🇪🇸'),
        _languageOption(AppLanguage.english, 'English', '🇺🇸'),
        _languageOption(AppLanguage.chinese, '中文', '🇨🇳'),
        _languageOption(AppLanguage.german, 'Deutsch', '🇩🇪'),
        _languageOption(AppLanguage.french, 'Français', '🇫🇷'),
      ],
    );
  }
  
  // Opción de idioma
  Widget _languageOption(AppLanguage language, String name, String flag) {
    final isSelected = _selectedLanguage == language;
    
    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 24)),
      title: Text(name),
      trailing: isSelected ? const Icon(Icons.check, color: Colors.teal) : null,
      onTap: () {
        setState(() {
          _selectedLanguage = language;
        });
      },
    );
  }
}