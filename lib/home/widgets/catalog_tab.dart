import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'dart:math';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:madinaapp/models/models.dart';
import 'package:madinaapp/products/products.dart';
import 'package:madinaapp/home/view/product_detail_page.dart';
import 'filter_button.dart';

class CatalogTab extends StatefulWidget {
  const CatalogTab({super.key});

  @override
  State<CatalogTab> createState() => _CatalogTabState();
}

class _CatalogTabState extends State<CatalogTab> with TickerProviderStateMixin {
  Map<String, dynamic> _filters = {};
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Voice search related variables
  late stt.SpeechToText _speech;
  bool _isVoiceSearchActive = false;
  bool _isListening = false;
  bool _isSpeaking = false;
  String _voiceText = '';
  List<double> _audioLevels = [];
  late AnimationController _pulseController;
  late AnimationController _micPulseController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _micPulseAnimation;
  Timer? _audioLevelTimer;
  Timer? _speakingTimer;
  String _statusText = 'Слушаю...';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initializeAudioLevels();

    // Initialize animation controllers
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _micPulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _micPulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _micPulseController,
      curve: Curves.easeInOut,
    ));

    // Refresh products when catalog tab initializes to ensure latest data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🔄 CATALOG: Initializing with fresh data');
      context.read<ProductsBloc>().add(const ProductsLoaded());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _pulseController.dispose();
    _micPulseController.dispose();
    _audioLevelTimer?.cancel();
    _speakingTimer?.cancel();
    if (_isListening) {
      _speech.stop();
    }
    super.dispose();
  }

  void _initializeAudioLevels() {
    _audioLevels = List.generate(30, (index) => 0.1);
  }

  void _updateAudioLevels() {
    if (_isSpeaking && _isListening) {
      setState(() {
        _audioLevels = List.generate(30, (index) {
          // Create more natural wave pattern when speaking
          double baseLevel = 0.2;
          double randomLevel = Random().nextDouble() * 0.6;
          double waveLevel =
              sin((DateTime.now().millisecondsSinceEpoch + index * 100) / 200) *
                  0.2;
          return baseLevel + randomLevel + waveLevel.abs();
        });
      });
    } else {
      // Reset to minimal levels when not speaking
      setState(() {
        _audioLevels =
            List.generate(30, (index) => 0.1 + Random().nextDouble() * 0.05);
      });
    }
  }

  void _startAudioLevelAnimation() {
    _audioLevelTimer =
        Timer.periodic(const Duration(milliseconds: 80), (timer) {
      if (_isListening) {
        _updateAudioLevels();
      } else {
        timer.cancel();
      }
    });
  }

  void _onSoundLevelChange(double level) {
    // Determine if user is speaking based on sound level
    bool wasSpeaking = _isSpeaking;
    _isSpeaking = level > 0.3; // Threshold for detecting speech

    if (_isSpeaking != wasSpeaking) {
      setState(() {
        _statusText = _isSpeaking ? 'Говорите...' : 'Слушаю...';
      });

      // Start/stop visual effects based on speaking state
      if (_isSpeaking && !wasSpeaking) {
        _pulseController.repeat(reverse: true);
        _micPulseController.repeat(reverse: true);
      } else if (!_isSpeaking && wasSpeaking) {
        _pulseController.stop();
        _micPulseController.stop();
        _pulseController.reset();
        _micPulseController.reset();

        // Reset speaking timer to avoid rapid changes
        _speakingTimer?.cancel();
        _speakingTimer = Timer(const Duration(milliseconds: 500), () {
          if (!_isSpeaking) {
            setState(() {
              _statusText = 'Слушаю...';
            });
          }
        });
      }
    }
  }

  Future<void> _requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      // Permission denied
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Микрофон необходим для голосового поиска')),
        );
      }
    }
  }

  Future<void> _startVoiceSearch() async {
    await _requestMicrophonePermission();

    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          setState(() {
            _isListening = false;
            _isSpeaking = false;
          });
          _audioLevelTimer?.cancel();
          _speakingTimer?.cancel();
          _pulseController.stop();
          _micPulseController.stop();

          // Auto-apply search after a brief delay
          if (_voiceText.isNotEmpty) {
            Timer(const Duration(milliseconds: 500), () {
              _applyVoiceSearch();
            });
          }
        }
      },
      onError: (error) {
        setState(() {
          _isListening = false;
          _isVoiceSearchActive = false;
          _isSpeaking = false;
        });
        _audioLevelTimer?.cancel();
        _speakingTimer?.cancel();
        _pulseController.stop();
        _micPulseController.stop();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ошибка распознавания речи: ${error.errorMsg}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );

    if (available) {
      setState(() {
        _isVoiceSearchActive = true;
        _isListening = true;
        _isSpeaking = false;
        _voiceText = '';
        _statusText = 'Слушаю...';
      });

      // Start audio level animation
      _startAudioLevelAnimation();

      await _speech.listen(
        onResult: (result) {
          setState(() {
            _voiceText = result.recognizedWords;
          });
        },
        localeId: 'ru_RU',
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        onSoundLevelChange: _onSoundLevelChange,
      );
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Голосовой поиск недоступен'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _stopVoiceSearch() {
    if (_isListening) {
      _speech.stop();
    }

    _audioLevelTimer?.cancel();
    _speakingTimer?.cancel();
    _pulseController.stop();
    _micPulseController.stop();

    setState(() {
      _isVoiceSearchActive = false;
      _isListening = false;
      _isSpeaking = false;
    });

    // Apply voice search if we have text
    if (_voiceText.isNotEmpty) {
      _applyVoiceSearch();
    }
  }

  Future<void> _handleRefresh() async {
    print('🔄 CATALOG: Pull-to-refresh triggered');

    // Show a brief feedback to user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 12),
            Text('Обновление каталога...'),
          ],
        ),
        duration: const Duration(milliseconds: 1500),
        backgroundColor: const Color(0xFF006FFD),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );

    // Trigger ProductsLoaded event to refresh all products
    context.read<ProductsBloc>().add(const ProductsLoaded());

    // Wait a bit for the event to process
    await Future<void>.delayed(const Duration(milliseconds: 800));
  }

  void _applyVoiceSearch() {
    setState(() {
      _searchController.text = _voiceText;
      _searchQuery = _voiceText;
      _isVoiceSearchActive = false;
      _isListening = false;
    });

    // Update search in ProductsBloc
    context.read<ProductsBloc>().add(ProductsSearched(_voiceText));

    // Show success feedback
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Поиск: "$_voiceText"'),
          backgroundColor: const Color(0xFF006FFD),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _handleRefresh,
          child: SingleChildScrollView(
            physics:
                const AlwaysScrollableScrollPhysics(), // Enable pull-to-refresh
            child: Column(
              children: [
                const SizedBox(height: 16),
                // Search bar
                _buildSearchBar(),
                const SizedBox(height: 24),
                // Filter buttons
                _buildFilterButtons(),
                const SizedBox(height: 12),
                // Product grid
                _buildProductGrid(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
        // Voice search overlay
        if (_isVoiceSearchActive) _buildVoiceSearchOverlay(),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FE),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                  // Update search in ProductsBloc
                  context.read<ProductsBloc>().add(ProductsSearched(value));
                },
                decoration: const InputDecoration(
                  hintText: 'Поиск тканей...',
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF8F9098),
                    fontFamily: 'Inter',
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    size: 16,
                    color: Color(0xFF2F3036),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1F2024),
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _startVoiceSearch,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF006FFD), width: 1.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.mic, size: 20, color: Color(0xFF006FFD)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildSortButton(),
          _buildFilterButton(),
        ],
      ),
    );
  }

  Widget _buildSortButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFC5C6CC), width: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.sort, size: 12, color: Color(0xFF8F9098)),
          SizedBox(width: 8),
          Text(
            'Сортировка',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF1F2024),
            ),
          ),
          SizedBox(width: 8),
          Icon(Icons.keyboard_arrow_down, size: 10, color: Color(0xFFC5C6CC)),
        ],
      ),
    );
  }

  Widget _buildFilterButton() {
    return FilterButton(
      filters: _filters,
      onFiltersChanged: (filters) {
        setState(() {
          _filters = filters;
        });
        // Update filters in ProductsBloc
        context.read<ProductsBloc>().add(ProductsFiltered(filters));
      },
    );
  }

  Widget _buildProductGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: BlocConsumer<ProductsBloc, ProductsState>(
        listener: (context, state) {
          // Listen for state changes and log them
          if (state.status == ProductsStatus.success) {
            print(
                '🔄 CATALOG LISTENER: Products updated! Total: ${state.products.length}, Filtered: ${state.filteredProducts.length}');
          }
        },
        builder: (context, state) {
          print(
              'DEBUG CATALOG: Building with ${state.filteredProducts.length} filtered products');
          print('DEBUG CATALOG: Status: ${state.status}');
          print('DEBUG CATALOG: Total products: ${state.products.length}');

          if (state.status == ProductsStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == ProductsStatus.failure) {
            return Center(child: Text('Error: ${state.error}'));
          }

          final filteredProducts = state.filteredProducts;

          return GridView.builder(
            shrinkWrap: true,
            physics:
                const NeverScrollableScrollPhysics(), // Keep this for proper scrolling behavior
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: filteredProducts.length,
            itemBuilder: (context, index) {
              final product = filteredProducts[index];
              return _buildCatalogProductCard(product);
            },
          );
        },
      ),
    );
  }

  Widget _buildCatalogProductCard(Product product) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (context) => ProductDetailPage(product: product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FE),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              width: double.infinity,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Image.asset(
                  product.imagePath,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: const Color(0xFFEAF2FF),
                      child: const Center(
                        child: Icon(
                          Icons.image,
                          size: 32,
                          color: Color(0xFFB4DBFF),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF1F2024),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'C ${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2024),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceSearchOverlay() {
    return Positioned.fill(
      child: Material(
        color: Colors.transparent,
        child: Container(
          color: const Color(0xFF1F2024).withOpacity(0.9),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Status text
              Text(
                _statusText,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 16),
              // Voice text display
              Container(
                height: 60,
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Center(
                  child: _voiceText.isNotEmpty
                      ? Text(
                          _voiceText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Inter',
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        )
                      : Container(),
                ),
              ),
              const SizedBox(height: 32),
              // Audio waveform visualization
              _buildAudioWaveform(),
              const SizedBox(height: 40),
              // Large microphone button with animation
              AnimatedBuilder(
                animation: _micPulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _isSpeaking ? _micPulseAnimation.value : 1.0,
                    child: GestureDetector(
                      onTap: _stopVoiceSearch,
                      child: Container(
                        width: 82,
                        height: 82,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isSpeaking
                              ? const Color(0xFF00D4AA)
                              : const Color(0xFF006FFD),
                          boxShadow: _isSpeaking
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF00D4AA)
                                        .withOpacity(0.3),
                                    spreadRadius: 8,
                                    blurRadius: 16,
                                  ),
                                ]
                              : null,
                        ),
                        child: const Icon(
                          Icons.mic,
                          size: 32,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              // Tap to stop hint
              Text(
                'Нажмите, чтобы остановить',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 14,
                  fontFamily: 'Inter',
                ),
              ),
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAudioWaveform() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _isSpeaking ? _pulseAnimation.value : 1.0,
          child: Container(
            height: 50,
            width: 280,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: _isSpeaking
                    ? const Color(0xFF00D4AA).withOpacity(0.5)
                    : Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: _audioLevels.asMap().entries.map((entry) {
                int index = entry.key;
                double level = entry.value;

                // Create a more natural wave pattern
                double height;
                if (_isSpeaking) {
                  height = (level * 30 + 4).clamp(4.0, 34.0);
                } else {
                  height = 4.0 + (sin(index.toDouble()) * 1.5).abs();
                }

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 50),
                  width: 3,
                  height: height,
                  decoration: BoxDecoration(
                    color: _isSpeaking
                        ? const Color(0xFF00D4AA)
                        : Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}
