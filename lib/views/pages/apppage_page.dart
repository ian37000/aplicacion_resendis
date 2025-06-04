import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:io';
import 'package:project_resendis/styles/app_colors.dart';
import 'package:project_resendis/styles/dimensions.dart';
import 'package:project_resendis/widgets/animated_logo.dart';
import 'package:project_resendis/widgets/loading_indicator.dart';
import 'package:project_resendis/widgets/custom_card.dart';
import 'package:project_resendis/data/notifiers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppPage extends StatefulWidget {
  final bool isAdmin;
  final String userId;
  const AppPage({super.key, this.isAdmin = false, required this.userId});

  @override
  State<AppPage> createState() => _AppPageState();
}

class _AppPageState extends State<AppPage> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  bool _isCameraReady = false;
  // Add these new variables
  final _firestore = FirebaseFirestore.instance;
  int _points = 0;
  Set<String> _scannedItems = {};
  DateTime _lastResetDate = DateTime.now();

  // Initialize Gemini
  final model = GenerativeModel(
    model: 'gemini-1.5-flash',
    apiKey: 'AIzaSyDLOQV1U0bH1kegqEO-EX52rrAeFkFuSY4',
  );

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _loadUserData(); // Add this line
  }

  Future<void> _loadUserData() async {
    try {
      final userData =
          await _firestore.collection('users').doc(widget.userId).get();
      if (userData.exists) {
        setState(() {
          _points = userData.data()?['points'] ?? 0;
          _lastResetDate =
              (userData.data()?['lastResetDate'] as Timestamp?)?.toDate() ??
              DateTime.now();
          _scannedItems = Set<String>.from(
            userData.data()?['scannedItems'] ?? [],
          );
        });
      } else {
        // Initialize new user data
        await _firestore.collection('users').doc(widget.userId).set({
          'points': 0,
          'lastResetDate': Timestamp.fromDate(DateTime.now()),
          'scannedItems': [],
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading user data. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No cameras available'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      _controller = CameraController(cameras[0], ResolutionPreset.medium);
      _initializeControllerFuture = _controller?.initialize();

      await _initializeControllerFuture;

      if (mounted) {
        setState(() {
          _isCameraReady = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error initializing camera: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  String? _analysisResult;
  bool _isAnalyzing = false;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDarkMode, child) {
        return Scaffold(
          body: Stack(
            children: [
              // Fondo con gradiente adaptado al tema
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors:
                        isDarkMode
                            ? [Colors.black, Colors.blueGrey.shade900]
                            : [Colors.blue.shade100, Colors.teal.shade200],
                  ),
                ),
              ),

              // Contenido principal
              SafeArea(
                child: Column(
                  children: [
                    // Barra de título personalizada adaptada al tema
                    Padding(
                      padding: EdgeInsets.all(AppDimensions.paddingMedium),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppDimensions.paddingMedium,
                          vertical: AppDimensions.paddingSmall,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isDarkMode
                                  ? Colors.black.withOpacity(0.5)
                                  : Colors.white.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(
                            AppDimensions.borderRadiusMedium,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  isDarkMode ? Colors.black26 : Colors.black12,
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Logo más pequeño
                            AnimatedLogo(size: 30),
                            SizedBox(width: AppDimensions.paddingSmall),
                            // Add points counter here
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppDimensions.paddingSmall,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isDarkMode
                                        ? Colors.amber.withOpacity(0.2)
                                        : Colors.amber.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 20,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    '$_points pts',
                                    style: TextStyle(
                                      color:
                                          isDarkMode
                                              ? Colors.amber
                                              : Colors.amber.shade900,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: AppDimensions.paddingSmall),
                            // Texto con Expanded para que se ajuste al espacio disponible
                            Expanded(
                              child: Text(
                                'Recycling Assistant',
                                style: Theme.of(
                                  context,
                                ).textTheme.titleMedium?.copyWith(
                                  color:
                                      isDarkMode
                                          ? Colors.white
                                          : Colors.black87,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // Botón para cambiar el tema
                            IconButton(
                              onPressed: () {
                                isDarkModeNotifier.value =
                                    !isDarkModeNotifier.value;
                              },
                              icon: Icon(
                                isDarkMode ? Icons.light_mode : Icons.dark_mode,
                                color:
                                    isDarkMode ? Colors.amber : Colors.indigo,
                              ),
                              tooltip: 'Cambiar tema',
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Vista de la cámara
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(AppDimensions.paddingMedium),
                        child: FutureBuilder<void>(
                          future: _initializeControllerFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                    ConnectionState.done &&
                                _isCameraReady &&
                                _controller != null) {
                              return Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.borderRadiusLarge,
                                  ),
                                  border: Border.all(
                                    color:
                                        isDarkMode
                                            ? AppColors.primaryColor
                                            : Colors.teal.shade400,
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          isDarkMode
                                              ? AppColors.primaryColor
                                                  .withOpacity(0.3)
                                              : Colors.teal.shade200
                                                  .withOpacity(0.5),
                                      blurRadius: 15,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.borderRadiusLarge,
                                  ),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      CameraPreview(_controller!),

                                      // Overlay con instrucciones adaptado al tema
                                      Positioned(
                                        top: 0,
                                        left: 0,
                                        right: 0,
                                        child: Container(
                                          padding: EdgeInsets.all(
                                            AppDimensions.paddingMedium,
                                          ),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                isDarkMode
                                                    ? Colors.black.withOpacity(
                                                      0.7,
                                                    )
                                                    : Colors.teal.shade700
                                                        .withOpacity(0.7),
                                                Colors.transparent,
                                              ],
                                            ),
                                          ),
                                          child: Text(
                                            'Toma una foto para analizar si el objeto es reciclable',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),

                                      // Marco de enfoque adaptado al tema
                                      Center(
                                        child: Container(
                                          width: 200,
                                          height: 200,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color:
                                                  isDarkMode
                                                      ? Colors.white
                                                      : Colors.teal.shade400,
                                              width: 2,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              AppDimensions.borderRadiusMedium,
                                            ),
                                          ),
                                        ),
                                      ),

                                      // Indicador de análisis
                                      if (_isAnalyzing)
                                        Container(
                                          color: Colors.black.withOpacity(0.5),
                                          child: Center(
                                            child: LoadingIndicator(
                                              message: 'Analizando imagen...',
                                              color:
                                                  isDarkMode
                                                      ? AppColors.primaryColor
                                                      : Colors.teal.shade400,
                                              textColor:
                                                  Colors
                                                      .white, // Añadir esta línea
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            } else {
                              return Center(
                                child: LoadingIndicator(
                                  message: 'Inicializando cámara...',
                                  color:
                                      isDarkMode
                                          ? AppColors.primaryColor
                                          : Colors.teal.shade400,
                                  textColor: Colors.white, // Añadir esta línea
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ),

                    // Resultado del análisis adaptado al tema
                    if (_analysisResult != null)
                      Padding(
                        padding: EdgeInsets.all(AppDimensions.paddingMedium),
                        child: CustomCard(
                          child: Stack(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(
                                  AppDimensions.paddingMedium,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Resultado del análisis:',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color:
                                            isDarkMode
                                                ? Colors.white
                                                : Colors.black87,
                                      ),
                                    ),
                                    SizedBox(
                                      height: AppDimensions.paddingSmall,
                                    ),
                                    Text(
                                      _analysisResult!,
                                      style: TextStyle(
                                        color:
                                            isDarkMode
                                                ? Colors.white70
                                                : Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: IconButton(
                                  icon: Icon(
                                    Icons.close,
                                    color:
                                        isDarkMode
                                            ? Colors.white54
                                            : Colors.grey,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _analysisResult = null;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Botón de captura adaptado al tema
                    Padding(
                      padding: EdgeInsets.all(AppDimensions.paddingMedium),
                      child: SizedBox(
                        width: double.infinity,
                        child: Material(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.borderRadiusLarge,
                          ),
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.borderRadiusLarge,
                            ),
                            onTap: () async {
                              try {
                                if (_controller != null &&
                                    _initializeControllerFuture != null) {
                                  await _initializeControllerFuture;

                                  setState(() {
                                    _isAnalyzing = true;
                                  });

                                  final image =
                                      await _controller!.takePicture();

                                  if (mounted) {
                                    await analyzeImage(image.path);
                                  }

                                  setState(() {
                                    _isAnalyzing = false;
                                  });
                                }
                              } catch (e) {
                                setState(() {
                                  _isAnalyzing = false;
                                });

                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            }, // Añadir esta coma aquí
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: AppDimensions.paddingMedium,
                                horizontal: AppDimensions.paddingLarge,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors:
                                      isDarkMode
                                          ? [
                                            AppColors.primaryColor,
                                            AppColors.primaryColor.withOpacity(
                                              0.7,
                                            ),
                                          ]
                                          : [
                                            Colors.teal.shade400,
                                            Colors.teal.shade300,
                                          ],
                                ),
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.borderRadiusLarge,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        isDarkMode
                                            ? AppColors.primaryColor
                                                .withOpacity(0.3)
                                            : Colors.teal.shade200.withOpacity(
                                              0.5,
                                            ),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.camera_alt, color: Colors.white),
                                    SizedBox(width: AppDimensions.paddingSmall),
                                    Text(
                                      'Tomar Foto',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar:
              widget.isAdmin
                  ? BottomNavigationBar(
                    items: const [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.camera_alt),
                        label: 'Cámara',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.admin_panel_settings),
                        label: 'Panel Admin',
                      ),
                    ],
                    onTap: (index) {
                      // Handle navigation between camera and admin panel
                      if (index == 1) {
                        // Navigate to admin panel
                        // You'll need to create an AdminPanel page
                      }
                    },
                  )
                  : null,
        );
      },
    );
  }

  Future<void> analyzeImage(String imagePath) async {
    try {
      final bytes = await File(imagePath).readAsBytes();

      final prompt = TextPart(
        '(start with just the name of the item) Analyze this item and tell me: 1. Which color recycling bin it should go in (options: blue, green, yellow, gray, or black), 2. What materials it is made of, 3. Ways to recycle it. 4.Say everything in Spanish. Keep the response brief and direct.',
      );
      final imagePart = DataPart('image/jpeg', bytes);

      final response = await model.generateContent([
        Content.multi([prompt, imagePart]),
      ]);

      final responseText = response.text;

      setState(() {
        _analysisResult = responseText;
      });

      // Add this: Handle points for the new item
      if (responseText != null) {
        await _handleNewItem(responseText);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error analyzing image: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      print('Error details: $e');
    }
  }

  Future<void> _handleNewItem(String responseText) async {
    // Extract the item type from the response (first line or relevant part)
    final itemType = responseText.split('.')[0].trim();

    // Check if it's a new day
    final now = DateTime.now();
    if (now.day != _lastResetDate.day ||
        now.month != _lastResetDate.month ||
        now.year != _lastResetDate.year) {
      _scannedItems.clear();
      _lastResetDate = now;

      // Update last reset date in Firebase
      await _firestore.collection('users').doc(widget.userId).update({
        'lastResetDate': Timestamp.fromDate(_lastResetDate),
        'scannedItems': [],
      });
    }

    // Check if item is new for today
    if (!_scannedItems.contains(itemType)) {
      setState(() {
        _points += 100;
        _scannedItems.add(itemType);
      });

      // Update points and scanned items in Firebase
      try {
        await _firestore.collection('users').doc(widget.userId).update({
          'points': _points,
          'scannedItems': _scannedItems.toList(),
        });
      } catch (e) {
        print('Error updating points: $e');
        // Rollback points if update fails
        setState(() {
          _points -= 100;
          _scannedItems.remove(itemType);
        });
        throw Exception('Failed to update points');
      }
    }
  }
}
