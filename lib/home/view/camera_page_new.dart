import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:madinaapp/models/models.dart';
import 'package:madinaapp/products/products.dart';
import 'package:madinaapp/widgets/product_edit_screen.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isInitialized = false;
  bool _isRecording = false;
  bool _isProcessing = false;
  bool _isSuccess = false;
  bool _isPermissionDenied = false;
  bool _isInitializing = false;
  bool _isConfirming = false;
  String _currentStep = 'video';
  int _recordingDuration = 0;
  Timer? _recordingTimer;
  Timer? _stepTimer; // Timer for _nextStep delays
  String _instructionText = 'Удерживать, чтобы записать видео . . .';
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  List<Product> _createdProducts = []; // Store created products
  List<Product> _draftProducts = []; // Store draft products for confirmation
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _selectedVideo; // Store selected video from gallery
  bool _isProcessingGalleryVideo = false; // Track if processing gallery video
  bool _isEditing = false; // Track if in editing mode
  Product? _editingProduct; // Product being edited
  int? _editingProductIndex; // Index of product being edited

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initPulseAnimation();

    // Try to initialize camera immediately if permissions are already granted
    // This provides faster camera startup for users who have already granted permissions
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tryQuickCameraInit();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    _recordingTimer?.cancel();
    _stepTimer?.cancel(); // Cancel step timer to prevent setState after dispose
    _pulseController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('🔄 App lifecycle state changed to: $state');
    final CameraController? cameraController = _controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      if (state == AppLifecycleState.resumed) {
        _handleAppResumed();
      }
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCameraController(cameraController.description);
    }
  }

  Future<void> _handleAppResumed() async {
    print('🔄 App resumed - checking current state');
    print('   - _isPermissionDenied: $_isPermissionDenied');
    print('   - _isInitialized: $_isInitialized');
    print(
        '   - _controller initialized: ${_controller?.value.isInitialized ?? false}');

    // Always re-check permission status when app resumes
    final currentStatus = await Permission.camera.status;
    print('🎥 Current permission status after resume: $currentStatus');

    // If permission is now granted and we were in a denied state
    if (currentStatus == PermissionStatus.granted) {
      if (_isPermissionDenied || !_isInitialized) {
        print('✅ Permission granted - reinitializing camera');
        setState(() {
          _isPermissionDenied = false;
        });
        await _initializeCamera();
      } else if (_controller != null && !_controller!.value.isInitialized) {
        // Reinitialize camera if it was disposed but permission is still granted
        print('🔄 Reinitializing disposed camera');
        await _initializeCamera();
      }
    } else if (currentStatus == PermissionStatus.permanentlyDenied) {
      // Update UI to show permanently denied state
      if (!_isPermissionDenied) {
        print('🚫 Permission now permanently denied');
        _showPermissionDeniedState();
      }
    } else if (currentStatus == PermissionStatus.denied) {
      // Update UI to show denied state (can still request)
      if (!_isPermissionDenied) {
        print('⚠️ Permission still denied');
        _showPermissionRequestState();
      }
    }
  }

  void _initPulseAnimation() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  Future<void> _checkPermissionsAndInitialize() async {
    setState(() {
      _isInitializing = true;
      _isPermissionDenied = false;
    });

    try {
      // First check current permission status
      var cameraStatus = await Permission.camera.status;
      var microphoneStatus = await Permission.microphone.status;

      print('🎥 Current camera permission: $cameraStatus');
      print('🎤 Current microphone permission: $microphoneStatus');

      // If camera is granted, check microphone and initialize
      if (cameraStatus == PermissionStatus.granted) {
        // For video recording, we also need microphone permission
        if (microphoneStatus != PermissionStatus.granted) {
          print('🎤 Need to request microphone permission');
          await _requestMicrophonePermission();
        } else {
          await _initializeCamera();
        }
        return;
      }

      // If permanently denied, show settings option
      if (cameraStatus == PermissionStatus.permanentlyDenied) {
        print('🚫 Permission permanently denied - showing settings option');
        _showPermissionDeniedState();
        return;
      }

      // For denied or undetermined status, we need to force request the permission
      // This is critical for iOS - we must actively request to trigger the native dialog
      print('📱 Camera permission not granted - forcing permission request');
      await _requestCameraPermission();
    } catch (e) {
      print('❌ Error checking permissions: $e');
      _showErrorState('Ошибка проверки разрешений');
    }
  }

  Future<void> _requestMicrophonePermission() async {
    try {
      print('🎤 Requesting microphone permission...');
      final status = await Permission.microphone.request();
      print('🎤 Microphone permission result: $status');

      switch (status) {
        case PermissionStatus.granted:
          print('✅ Microphone granted - initializing camera');
          await _initializeCamera();
          break;
        case PermissionStatus.denied:
          print('⚠️ Microphone denied - camera will work without audio');
          await _initializeCamera(); // Camera can still work without microphone
          break;
        case PermissionStatus.permanentlyDenied:
          print('🚫 Microphone permanently denied');
          _showErrorState(
              'Доступ к микрофону заблокирован. Видео будет без звука.');
          await _initializeCamera(); // Still try to initialize camera
          break;
        default:
          print('❓ Unknown microphone permission status: $status');
          await _initializeCamera(); // Try anyway
      }
    } catch (e) {
      print('❌ Error requesting microphone permission: $e');
      await _initializeCamera(); // Continue without microphone
    }
  }

  Future<void> _requestCameraPermission() async {
    setState(() {
      _isInitializing = true;
    });

    try {
      print('🎥 FORCE requesting camera permission...');

      // For iOS: Force trigger the native permission dialog
      // This is critical - we bypass status checking and directly request
      final status = await Permission.camera.request();
      print('🎥 Permission request result: $status');

      switch (status) {
        case PermissionStatus.granted:
          print('✅ Permission granted - checking microphone next');
          // Now check microphone permission for video recording
          final micStatus = await Permission.microphone.status;
          if (micStatus != PermissionStatus.granted) {
            await _requestMicrophonePermission();
          } else {
            await _initializeCamera();
          }
          break;
        case PermissionStatus.denied:
          print('⚠️ Permission denied by user');
          _showPermissionDeniedState();
          break;
        case PermissionStatus.permanentlyDenied:
          print('🚫 Permission permanently denied');
          _showPermissionPermanentlyDeniedDialog();
          break;
        case PermissionStatus.restricted:
          print('🚫 Permission restricted (parental controls?)');
          _showErrorState('Доступ к камере ограничен системными настройками');
          break;
        case PermissionStatus.limited:
          print('⚠️ Permission limited');
          _showErrorState('Ограниченный доступ к камере');
          break;
        default:
          print('❓ Unknown permission status: $status');
          _showErrorState('Неизвестный статус разрешения');
      }
    } catch (e) {
      print('❌ Error requesting permission: $e');
      _showErrorState('Ошибка запроса разрешения: $e');
    }
  }

  Future<void> _initializeCamera() async {
    try {
      setState(() {
        _isInitializing = true;
      });

      print('📷 Initializing camera...');

      // Get available cameras
      _cameras = await availableCameras();
      print('📷 Found ${_cameras.length} cameras');

      if (_cameras.isEmpty) {
        _showErrorState('Камера не найдена');
        return;
      }

      // Initialize camera controller
      _controller = CameraController(
        _cameras.first,
        ResolutionPreset.high,
        enableAudio: true,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _controller!.initialize();
      print('✅ Camera initialized successfully');

      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isInitializing = false;
          _isPermissionDenied = false;
        });
      }
    } catch (e) {
      print('❌ Camera initialization error: $e');
      _showErrorState('Ошибка инициализации камеры');
    }
  }

  /// Initialize camera controller for lifecycle handling
  Future<void> _initializeCameraController(
      CameraDescription cameraDescription) async {
    try {
      print('📷 Re-initializing camera controller...');

      _controller = CameraController(
        cameraDescription,
        ResolutionPreset.high,
        enableAudio: true,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _controller!.initialize();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }

      print('✅ Camera controller re-initialized successfully');
    } catch (e) {
      print('❌ Camera controller re-initialization error: $e');
      _showErrorState('Ошибка переинициализации камеры');
    }
  }

  void _showPermissionRequestState() {
    setState(() {
      _isInitializing = false;
      _isPermissionDenied = false;
      _isInitialized = false;
    });
  }

  void _showPermissionDeniedState() {
    setState(() {
      _isPermissionDenied = true;
      _isInitializing = false;
      _isInitialized = false;
    });
  }

  void _showErrorState(String message) {
    setState(() {
      _isInitializing = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showPermissionPermanentlyDeniedDialog() {
    setState(() {
      _isInitializing = false;
      _isPermissionDenied = true;
    });

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.camera_alt, color: Colors.blue.shade600),
              const SizedBox(width: 8),
              const Text('Доступ к камере'),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Камера необходима для создания продуктов',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Пожалуйста, включите камеру в настройках устройства:',
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(height: 12),
              Text(
                '1. Откройте Настройки\n2. Найдите это приложение\n3. Нажмите "Камера"\n4. Вернитесь в приложение',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'После включения камера заработает автоматически.',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006FFD),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Открыть настройки'),
            ),
          ],
        );
      },
    );
  }

  void _startRecording() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }

    try {
      await _controller!.startVideoRecording();
      _pulseController.repeat(reverse: true);

      setState(() {
        _isRecording = true;
        _recordingDuration = 0;
      });

      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() {
            _recordingDuration++;
          });
        }
      });
    } catch (e) {
      _showErrorState('Ошибка записи: $e');
    }
  }

  void _stopRecording() async {
    if (_controller == null || !_isRecording) return;

    try {
      await _controller!.stopVideoRecording();
      _recordingTimer?.cancel();
      _pulseController.stop();
      _pulseController.reset();

      setState(() {
        _isRecording = false;
        _currentStep = 'materials';
        _instructionText =
            'Теперь скажите подробности материалов и Zoom к тканям . . .';
      });

      _stepTimer = Timer(const Duration(seconds: 2), () {
        _nextStep();
      });
    } catch (e) {
      _showErrorState('Ошибка остановки записи: $e');
    }
  }

  void _nextStep() {
    if (!mounted) return; // Check if widget is still mounted

    setState(() {
      switch (_currentStep) {
        case 'materials':
          _currentStep = 'pricing';
          _instructionText = 'Наконец, скажем, цена и баланс акций . . .';
          _stepTimer = Timer(const Duration(seconds: 3), () {
            _nextStep();
          });
          break;
        case 'pricing':
          _currentStep = 'processing';
          _instructionText = 'AI создает ваши продукты . . .';
          _isProcessing = true;
          _stepTimer = Timer(const Duration(seconds: 4), () {
            _nextStep();
          });
          break;
        case 'processing':
          _currentStep = 'success';
          _isProcessing = false;
          _isSuccess = true;
          _isProcessingGalleryVideo = false; // Reset flag
          _addNewProducts();
          break;
      }
    });
  }

  void _addNewProducts() {
    print('🎥 CAMERA: Starting to add new products...');

    final newProducts = [
      Product(
        id: 'new_${DateTime.now().millisecondsSinceEpoch}_1',
        name: 'Турецкий шелк с цветами',
        description:
            'Приятный на ощупь турецкий шелк белого цвета с синими цветами. Подходит для женской и национальной одежды. Плотность 120 г/м², ширина 150 см.',
        price: 350.00,
        imagePath: 'assets/images/9.png',
        category: 'Шелковая ткань',
        color: 'Белый',
        images: [
          'assets/images/9.png',
        ],
        availableColors: [
          const ProductColor(
              name: 'Белый', colorValue: 0xFFFFFFFF, isSelected: true),
          const ProductColor(
              name: 'Синий', colorValue: 0xFF0000FF, isSelected: false),
        ],
        unit: 'м²',
        isFavorite: false,
      ),
    ];

    print('🎥 CAMERA: Created ${newProducts.length} new products');

    // Store created products in state
    setState(() {
      _createdProducts = newProducts;
    });

    // Add products to ProductsBloc
    print('🎥 CAMERA: Adding products to ProductsBloc...');
    for (final product in newProducts) {
      print('🎥 CAMERA: Adding product: ${product.name} (ID: ${product.id})');
      context.read<ProductsBloc>().add(ProductAdded(product));
    }

    print('🎥 CAMERA: Finished adding all products to bloc');
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')} с';
  }

  @override
  Widget build(BuildContext context) {
    if (_isEditing) {
      return _buildEditingScreen();
    }

    if (_isSuccess) {
      return _buildSuccessScreen();
    }

    if (_isProcessing) {
      return _buildProcessingScreen();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera preview or permission screens
          _buildCameraContent(),

          // Top navigation bar
          _buildNavigationBar(),

          // Bottom content (only show if camera is ready)
          if (_isInitialized && !_isPermissionDenied) _buildBottomContent(),

          // Recording timer
          if (_isRecording) _buildRecordingTimer(),
        ],
      ),
      // Debug floating action button (only in debug mode)
      floatingActionButton: _buildDebugButton(),
    );
  }

  Widget _buildCameraContent() {
    if (_isInitialized &&
        _controller != null &&
        _controller!.value.isInitialized) {
      return Positioned.fill(
        child: CameraPreview(_controller!),
      );
    }

    if (_isPermissionDenied) {
      return _buildPermissionDeniedScreen();
    }

    if (_isInitializing) {
      return _buildLoadingScreen();
    }

    return _buildPermissionRequestScreen();
  }

  Widget _buildPermissionRequestScreen() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFF006FFD).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 60,
                  color: Color(0xFF006FFD),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Разрешите доступ к камере',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Inter',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Чтобы создавать продукты с помощью видео, нужна камера',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontFamily: 'Inter',
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _forceIOSCameraPermission,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006FFD),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt, size: 24),
                      SizedBox(width: 12),
                      Text(
                        'Разрешить камеру',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionDeniedScreen() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.videocam_off,
                  size: 60,
                  color: Colors.red.shade400,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Камера заблокирована',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Inter',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Включите камеру в настройках устройства',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontFamily: 'Inter',
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Как включить камеру:',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Inter',
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '1. Нажмите "Открыть настройки"\n2. Найдите это приложение\n3. Включите "Камера"\n4. Вернитесь в приложение',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontFamily: 'Inter',
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => openAppSettings(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006FFD),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.settings, size: 24),
                      SizedBox(width: 12),
                      Text(
                        'Открыть настройки',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _forceRefreshPermissions,
                child: const Text(
                  'Проверить снова',
                  style: TextStyle(
                    color: Color(0xFF006FFD),
                    fontSize: 16,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Container(
      color: Colors.black,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Color(0xFF006FFD),
              strokeWidth: 3,
            ),
            SizedBox(height: 24),
            Text(
              'Запуск камеры...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.only(top: 44, bottom: 16),
        child: Row(
          children: [
            const SizedBox(width: 24),
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: const Text(
                'Отмена',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF006FFD),
                  fontFamily: 'Inter',
                ),
              ),
            ),
            const Spacer(),
            const Text(
              'Создать продукт',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2024),
                fontFamily: 'Inter',
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Container(
                  width: 13,
                  height: 13,
                  decoration: BoxDecoration(
                    color: const Color(0xFF006FFD),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    size: 8,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  'Гид',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF006FFD),
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
            const SizedBox(width: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomContent() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black],
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _instructionText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  fontFamily: 'Inter',
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: _pickVideoFromGallery,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF006FFD).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF006FFD),
                        width: 1,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.photo_library_outlined,
                          size: 16,
                          color: Color(0xFF006FFD),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Загрузить',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF006FFD),
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Record button
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _isRecording ? _pulseAnimation.value : 1.0,
                      child: GestureDetector(
                        onTapDown: (_) => _startRecording(),
                        onTapUp: (_) => _stopRecording(),
                        onTapCancel: () => _stopRecording(),
                        child: Container(
                          width: 82,
                          height: 82,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isRecording
                                ? Colors.red
                                : const Color(0xFF006FFD),
                            border: Border.all(
                              color: Colors.white,
                              width: 4,
                            ),
                            boxShadow: _isRecording
                                ? [
                                    BoxShadow(
                                      color: Colors.red.withOpacity(0.3),
                                      spreadRadius: 8,
                                      blurRadius: 16,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Icon(
                            _isRecording ? Icons.stop : Icons.circle,
                            size: 32,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 80),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordingTimer() {
    return Positioned(
      top: 100,
      right: 24,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              _formatDuration(_recordingDuration),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessingScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Container(
            color: Colors.black.withOpacity(0.7),
          ),
          _buildNavigationBar(),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _isProcessingGalleryVideo
                          ? 'AI анализирует загруженное видео . . .'
                          : 'AI создает ваши продукты . . .',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        fontFamily: 'Inter',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    width: 286,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: 0.87,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF006FFD),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'пожалуйста, подождите',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontFamily: 'Inter',
                      letterSpacing: 0.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'По оценкам 2 мин',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                      fontFamily: 'Inter',
                      letterSpacing: 0.12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            height: 44,
            color: Colors.white,
          ),
          Container(
            height: 56,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context)
                      .pop(true), // Return true when products were created
                  child: const Text(
                    'Готово',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF006FFD),
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
                const Spacer(),
                const Text(
                  'Продукты созданы',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2024),
                    fontFamily: 'Inter',
                  ),
                ),
                const Spacer(),
                const SizedBox(width: 60),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00D4AA).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    size: 32,
                    color: Color(0xFF00D4AA),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Продукция',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2024),
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Всего ${_createdProducts.length} продукта, созданных с AI',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF007AFF),
                    fontFamily: 'Inter',
                    letterSpacing: 0.12,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _createdProducts.isNotEmpty
                  ? GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.8,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: _createdProducts.length,
                      itemBuilder: (context, index) {
                        return _buildSuccessProductCard(
                            _createdProducts[index]);
                      },
                    )
                  : const Center(
                      child: Text(
                        'Продукты не найдены',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF6B7280),
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  // Show success snackbar
                  _showSuccessSnackbar();
                  // Pop the screen with a result indicating products were added
                  Navigator.of(context).pop(true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF006FFD),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Готово',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessProductCard(Product product) {
    final productIndex = _createdProducts.indexOf(product);

    return GestureDetector(
      onTap: () {
        // Navigate to edit mode for this product
        _startEditingProduct(product, productIndex);
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FE),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFEAF2FF),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: Image.asset(
                      product.imagePath,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 120,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF006FFD),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        product.category,
                        style: const TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ),
                  // Edit button overlay
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.edit,
                        size: 16,
                        color: Color(0xFF006FFD),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F2024),
                            fontFamily: 'Inter',
                            letterSpacing: 0.12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          product.description,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF6B7280),
                            fontFamily: 'Inter',
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Color(
                                    product.availableColors.first.colorValue),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              product.color,
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF6B7280),
                                fontFamily: 'Inter',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${product.price.toStringAsFixed(0)} ₽/${product.unit}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1F2024),
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget? _buildDebugButton() {
    // Only show debug button in debug mode and when there are permission issues
    if (!kDebugMode || (_isInitialized && !_isPermissionDenied)) {
      return null;
    }

    return FloatingActionButton.small(
      onPressed: () async {
        print('🔧 DEBUG: Complete permission reset requested');
        await _completePermissionReset();
      },
      backgroundColor: Colors.red.withOpacity(0.8),
      child: const Icon(Icons.refresh, color: Colors.white),
    );
  }

  // Force refresh permission status and reinitialize
  Future<void> _forceRefreshPermissions() async {
    print('🔄 Force refreshing permissions...');

    setState(() {
      _isInitializing = true;
      _isPermissionDenied = false;
      _isInitialized = false;
    });

    // Dispose current controller if it exists
    if (_controller != null) {
      try {
        await _controller!.dispose();
        _controller = null;
        print('📷 Disposed existing camera controller');
      } catch (e) {
        print('⚠️ Error disposing controller: $e');
      }
    }

    // Small delay to ensure state is reset
    await Future<void>.delayed(const Duration(milliseconds: 500));

    // Re-check permissions with fresh state
    await _checkPermissionsAndInitialize();
  }

  // iOS-specific permission troubleshooting
  Future<void> _iOSPermissionTroubleshooting() async {
    print('🍎 iOS Permission Troubleshooting:');

    try {
      // Check multiple permission states
      final cameraStatus = await Permission.camera.status;
      final microphoneStatus = await Permission.microphone.status;

      print('   📱 Camera permission: $cameraStatus');
      print('   🎤 Microphone permission: $microphoneStatus');

      // Check if permission can be requested
      final canRequestCamera = await Permission.camera.request();
      print('   🔄 Can request camera: $canRequestCamera');

      // Try to get cameras (this sometimes forces a permission check)
      try {
        final cameras = await availableCameras();
        print('   📷 Available cameras: ${cameras.length}');
      } catch (e) {
        print('   ❌ Error getting cameras: $e');
      }
    } catch (e) {
      print('   ❌ Error in iOS troubleshooting: $e');
    }
  }

  // iOS-specific method to force trigger camera permission dialog
  Future<void> _forceIOSCameraPermission() async {
    try {
      print('📱 iOS: Attempting to force camera permission dialog...');

      // Method 1: Try to access cameras directly (sometimes triggers dialog)
      try {
        final cameras = await availableCameras();
        print('📱 iOS: Found ${cameras.length} cameras via direct access');
        if (cameras.isNotEmpty) {
          // If we got cameras, permission is granted
          await _initializeCamera();
          return;
        }
      } catch (e) {
        print('📱 iOS: Direct camera access failed: $e');
      }

      // Method 2: Force request permission
      print('📱 iOS: Forcing permission request...');
      final status = await Permission.camera.request();
      print('📱 iOS: Force request result: $status');

      if (status == PermissionStatus.granted) {
        await _initializeCamera();
      } else if (status == PermissionStatus.permanentlyDenied) {
        _showPermissionPermanentlyDeniedDialog();
      } else {
        _showPermissionDeniedState();
      }
    } catch (e) {
      print('📱 iOS: Error in force permission: $e');
      _showErrorState('Ошибка получения разрешения камеры');
    }
  }

  // Complete app permission reset - for debugging and troubleshooting
  Future<void> _completePermissionReset() async {
    print('🔄 COMPLETE PERMISSION RESET STARTED');

    try {
      // Step 1: Dispose all camera resources
      if (_controller != null) {
        await _controller?.dispose();
        _controller = null;
        print('✅ Camera controller disposed');
      }

      // Step 2: Reset all state variables
      setState(() {
        _isInitialized = false;
        _isRecording = false;
        _isProcessing = false;
        _isSuccess = false;
        _isPermissionDenied = false;
        _isInitializing = false;
        _currentStep = 'video';
        _recordingDuration = 0;
        _createdProducts = []; // Reset created products
        _isProcessingGalleryVideo = false; // Reset gallery flag
        _selectedVideo = null; // Reset selected video
      });
      print('✅ State variables reset');

      // Step 3: Cancel timers
      _recordingTimer?.cancel();
      _pulseController.reset();
      print('✅ Timers canceled');

      // Step 4: Run iOS-specific troubleshooting
      await _iOSPermissionTroubleshooting();

      // Step 5: Force garbage collection delay
      await Future<void>.delayed(const Duration(milliseconds: 1000));

      // Step 6: Check current permissions
      final cameraStatus = await Permission.camera.status;
      final micStatus = await Permission.microphone.status;
      print('📱 Current permissions - Camera: $cameraStatus, Mic: $micStatus');

      // Step 7: Force new permission request cycle
      print('🚀 Starting fresh permission request...');
      await _forceIOSCameraPermission();
    } catch (e) {
      print('❌ Error in complete reset: $e');
      _showErrorState('Ошибка полного сброса разрешений');
    }
  }

  // Quick camera initialization attempt - tries to start camera immediately if permissions exist
  Future<void> _tryQuickCameraInit() async {
    try {
      print('🚀 Attempting quick camera initialization...');

      // Step 0: Ultra-quick attempt - try direct camera access first
      await _tryUltraQuickCameraInit();
      if (_isInitialized) {
        print('⚡ Ultra-quick initialization succeeded!');
        return;
      }

      // Step 1: Quick permission check (non-blocking)
      final cameraStatus = await Permission.camera.status;
      final microphoneStatus = await Permission.microphone.status;

      print('🎥 Quick check - Camera: $cameraStatus, Mic: $microphoneStatus');

      // Step 2: If camera permission is granted, try direct initialization
      if (cameraStatus == PermissionStatus.granted) {
        print('✅ Camera permission already granted - initializing directly');

        // Try to initialize camera directly
        await _initializeCamera();

        // If camera init succeeded and microphone is not granted, request it in background
        if (_isInitialized && microphoneStatus != PermissionStatus.granted) {
          print('🎤 Requesting microphone permission in background...');
          // Request microphone permission without blocking UI
          Permission.microphone.request().then((micStatus) {
            print('🎤 Background microphone request result: $micStatus');
          }).catchError((Object e) {
            print('🎤 Background microphone request error: $e');
          });
        }

        return; // Success - camera is ready
      }

      // Step 3: If permissions not granted, fall back to normal permission flow
      print(
          '⚠️ Permissions not granted - falling back to permission request flow');
      await _checkPermissionsAndInitialize();
    } catch (e) {
      print('❌ Quick camera init failed: $e');
      // Fallback to normal permission flow
      await _checkPermissionsAndInitialize();
    }
  }

  // Ultra-quick camera initialization - attempts direct camera access
  Future<void> _tryUltraQuickCameraInit() async {
    try {
      print('⚡ Attempting ultra-quick camera access...');

      // Try to access cameras directly - this sometimes works on devices
      // where permission was previously granted in other apps
      final cameras = await availableCameras();
      print('⚡ Direct camera access found ${cameras.length} cameras');

      if (cameras.isNotEmpty) {
        // Try to initialize camera controller directly
        _controller = CameraController(
          cameras.first,
          ResolutionPreset.high,
          enableAudio: true,
          imageFormatGroup: ImageFormatGroup.jpeg,
        );

        await _controller!.initialize();
        print('⚡ Ultra-quick camera initialization successful!');

        if (mounted) {
          setState(() {
            _isInitialized = true;
            _isInitializing = false;
            _isPermissionDenied = false;
          });
        }

        return; // Success!
      }
    } catch (e) {
      print('⚡ Ultra-quick camera init failed (expected): $e');
      // This is expected to fail if permissions aren't granted
      // Dispose any partially created controller
      try {
        await _controller?.dispose();
        _controller = null;
      } catch (disposeError) {
        print('⚡ Error disposing failed controller: $disposeError');
      }
    }
  }

  // Method to pick video from gallery
  Future<void> _pickVideoFromGallery() async {
    try {
      // Check if gallery access permission is needed
      var status = await Permission.photos.status;
      if (status.isDenied) {
        status = await Permission.photos.request();
        if (status.isDenied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Доступ к галерее необходим для выбора видео'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }

      final XFile? pickedFile = await _imagePicker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 5), // Limit video duration
      );

      if (pickedFile != null) {
        setState(() {
          _selectedVideo = pickedFile;
          _isProcessingGalleryVideo = true;
          _currentStep = 'processing';
          _instructionText = 'AI анализирует ваше видео . . .';
          _isProcessing = true;
        });

        // Simulate processing time like camera recording
        _stepTimer = Timer(const Duration(seconds: 3), () {
          _nextStep();
        });
      }
    } catch (e) {
      print('Error picking video: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ошибка при выборе видео'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Method to start editing a product
  void _startEditingProduct(Product product, int index) {
    setState(() {
      _isEditing = true;
      _editingProduct = product;
      _editingProductIndex = index;
    });
  }

  // Method to save edited product
  void _saveEditedProduct(Product editedProduct) {
    if (_editingProductIndex != null) {
      setState(() {
        _createdProducts[_editingProductIndex!] = editedProduct;
        _isEditing = false;
        _editingProduct = null;
        _editingProductIndex = null;
      });

      // Update the dummy data as well
      // Update product in ProductsBloc instead of DummyData directly
      context.read<ProductsBloc>().add(ProductUpdated(editedProduct));

      _showSuccessSnackbar('Продукт успешно обновлен');
    }
  }

  // Method to cancel editing
  void _cancelEditing() {
    setState(() {
      _isEditing = false;
      _editingProduct = null;
      _editingProductIndex = null;
    });
  }

  // Build editing screen
  Widget _buildEditingScreen() {
    if (_editingProduct == null) return Container();

    return ProductEditScreen(
      product: _editingProduct!,
      onSave: _saveEditedProduct,
      onCancel: _cancelEditing,
    );
  }

  void _showSuccessSnackbar([String? customMessage]) {
    final message = customMessage ?? 'Продукты успешно созданы!';

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Color(0xFF00D4AA),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  size: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      message,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontFamily: 'Inter',
                      ),
                    ),
                    Text(
                      '${_createdProducts.length} новых продуктов добавлено в каталог',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.white70,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF00D4AA),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          action: SnackBarAction(
            label: 'Открыть каталог',
            textColor: Colors.white,
            onPressed: () {
              // Close the snackbar
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              // Pop back to home and optionally navigate to catalog tab
              Navigator.of(context).pop();
              // Note: You could add a callback here to switch to catalog tab
              // if the parent widget provides such functionality
            },
          ),
        ),
      );
    }
  }
}
