import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:record/record.dart'; // Mantener ^6.0.0
import 'package:audio_streamer/audio_streamer.dart'; // Mantener ^4.2.2

// --- Colores y estilos para la cara ---
const Color idlePrimaryColor = Color(0xFF00FFFF);
const Color idleSecondaryColor = Color(0xFF0088FF);
const Color speakingPrimaryColor = Color(0xFFff00ff);
const Color speakingSecondaryColor = Color(0xFFff0088);

class FuturisticFaceAnimation extends StatefulWidget {
  final bool isSpeaking;

  const FuturisticFaceAnimation({
    super.key,
    this.isSpeaking = false,
  });

  @override
  State<FuturisticFaceAnimation> createState() => _FuturisticFaceAnimationState();
}

class _FuturisticFaceAnimationState extends State<FuturisticFaceAnimation>
    with TickerProviderStateMixin {
  late AnimationController _mouthController;
  late Animation<double> _mouthAnimation;
  late AnimationController _eyeGlowController;
  late Animation<double> _eyeGlowAnimation;
  late AnimationController _facePulseController;
  late Animation<double> _facePulseAnimation;
  late AnimationController _energyLineController;
  late AnimationController _particleController;

  final AudioRecorder _audioRecorder = AudioRecorder();
  StreamSubscription<List<double>>? _audioStreamSubscription;
  double _currentVolume = 0.0;
  Timer? _silenceTimer;

  static const double _speechThreshold = 0.02;
  static const Duration _silenceDuration = Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();

    _mouthController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    )..repeat(reverse: true);
    _mouthAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mouthController, curve: Curves.easeOut),
    );

    _eyeGlowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..repeat(reverse: true);
    _eyeGlowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _eyeGlowController, curve: Curves.easeInOut),
    );

    _facePulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
    _facePulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _facePulseController, curve: Curves.easeInOut),
    );

    _energyLineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _initAudioStream();
  }

  Future<void> _initAudioStream() async {
    bool hasPermission = await _audioRecorder.hasPermission();
    if (!hasPermission) {
      print('Permiso de micrófono denegado. No se puede iniciar el stream de audio.');
      return;
    }

    print('Preparando suscripción a AudioStreamer.');

    _audioStreamSubscription = AudioStreamer().audioStream.listen((audioData) {
      final double rms = _calculateRMS(audioData);

      if (mounted) {
        setState(() {
          _currentVolume = rms;
        });

        if (rms > _speechThreshold) {
          _silenceTimer?.cancel();
          if (!widget.isSpeaking) {
             _setMicrophoneSpeakingState(true);
          }
        } else {
          if (_silenceTimer == null || !_silenceTimer!.isActive) {
            _silenceTimer = Timer(_silenceDuration, () {
              if (mounted && _currentVolume <= _speechThreshold) {
                if (!widget.isSpeaking) {
                  _setMicrophoneSpeakingState(false);
                }
              }
            });
          }
        }
      }
    }, onError: (error) {
      print('Error en el stream de audio: $error');
      _setMicrophoneSpeakingState(false);
    });
  }

  double _calculateRMS(List<double> audioData) {
    if (audioData.isEmpty) return 0.0;

    double sumOfSquares = 0.0;
    for (double sample in audioData) {
      sumOfSquares += sample * sample;
    }

    final double rms = sqrt(sumOfSquares / audioData.length);
    return rms * 5.0;
  }

  bool _isMicrophoneSpeaking = false;

  void _setMicrophoneSpeakingState(bool speaking) {
    if (_isMicrophoneSpeaking != speaking) {
      setState(() {
        _isMicrophoneSpeaking = speaking;
      });
      _updateAnimationSpeeds();
    }
  }

  void _updateAnimationSpeeds() {
    final bool currentSpeakingState = widget.isSpeaking || _isMicrophoneSpeaking;

    if (currentSpeakingState) {
      _mouthController.duration = const Duration(milliseconds: 100);
      _eyeGlowController.duration = const Duration(milliseconds: 200);
      _facePulseController.duration = const Duration(milliseconds: 400);
      _energyLineController.duration = const Duration(seconds: 1);
      _particleController.duration = const Duration(seconds: 1);
    } else {
      _mouthController.duration = const Duration(milliseconds: 500);
      _eyeGlowController.duration = const Duration(milliseconds: 500);
      _facePulseController.duration = const Duration(milliseconds: 800);
      _energyLineController.duration = const Duration(seconds: 2);
      _particleController.duration = const Duration(seconds: 3);
    }
    if (!_mouthController.isAnimating || _mouthController.duration != (currentSpeakingState ? const Duration(milliseconds: 100) : const Duration(milliseconds: 500))) {
      _mouthController.repeat(reverse: true);
    }
    if (!_eyeGlowController.isAnimating || _eyeGlowController.duration != (currentSpeakingState ? const Duration(milliseconds: 200) : const Duration(milliseconds: 500))) {
      _eyeGlowController.repeat(reverse: true);
    }
    if (!_facePulseController.isAnimating || _facePulseController.duration != (currentSpeakingState ? const Duration(milliseconds: 400) : const Duration(milliseconds: 800))) {
      _facePulseController.repeat(reverse: true);
    }
    if (!_energyLineController.isAnimating || _energyLineController.duration != (currentSpeakingState ? const Duration(seconds: 1) : const Duration(seconds: 2))) {
      _energyLineController.repeat();
    }
    if (!_particleController.isAnimating || _particleController.duration != (currentSpeakingState ? const Duration(seconds: 1) : const Duration(seconds: 3))) {
      _particleController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant FuturisticFaceAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSpeaking != oldWidget.isSpeaking) {
      _updateAnimationSpeeds();
    }
  }

  @override
  void dispose() {
    _mouthController.dispose();
    _eyeGlowController.dispose();
    _facePulseController.dispose();
    _energyLineController.dispose();
    _particleController.dispose();
    _audioStreamSubscription?.cancel(); // Cancelar la suscripción al stream
    _audioRecorder.dispose(); // Disponer del grabador de audio
    // Eliminada la línea AudioStreamer().stop();
    _silenceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool currentSpeakingState = widget.isSpeaking || _isMicrophoneSpeaking;
    final Color currentPrimaryColor = currentSpeakingState ? speakingPrimaryColor : idlePrimaryColor;
    final Color currentSecondaryColor = currentSpeakingState ? speakingSecondaryColor : idleSecondaryColor;

    double mouthHeightFactor = 0.0;
    if (currentSpeakingState) {
      mouthHeightFactor = min(1.0, _currentVolume + _mouthAnimation.value * 0.5);
    } else {
      mouthHeightFactor = 0.0;
    }

    return AnimatedBuilder(
      animation: Listenable.merge([
        _mouthController,
        _eyeGlowController,
        _facePulseController,
        _energyLineController,
        _particleController,
      ]),
      builder: (context, child) {
        final faceScale = 1.0 + (_facePulseAnimation.value * (currentSpeakingState ? 0.05 : 0.02));
        final eyeScale = 1.0 + (_eyeGlowAnimation.value * (currentSpeakingState ? 0.2 : 0.1));
        final mouthBaseHeight = 40.0;
        final mouthSpeakingHeight = 70.0;
        final currentMouthHeight = mouthBaseHeight + (mouthSpeakingHeight - mouthBaseHeight) * mouthHeightFactor;

        return Center(
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: currentPrimaryColor.withOpacity(0.7),
                width: 3,
              ),
              gradient: RadialGradient(
                colors: [currentPrimaryColor.withOpacity(0.1), Colors.transparent],
                stops: const [0.0, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: currentPrimaryColor.withOpacity(currentSpeakingState ? 0.8 : 0.5),
                  blurRadius: currentSpeakingState ? 80.0 : 50.0,
                  spreadRadius: 0,
                ),
              ],
            ),
            transform: Matrix4.identity()..scale(faceScale, faceScale),
            child: Stack(
              children: [
                Positioned(
                  top: 120,
                  left: 100,
                  child: _buildEye(
                    currentPrimaryColor,
                    currentSecondaryColor,
                    eyeScale,
                    currentSpeakingState,
                  ),
                ),
                Positioned(
                  top: 120,
                  right: 100,
                  child: _buildEye(
                    currentPrimaryColor,
                    currentSecondaryColor,
                    eyeScale,
                    currentSpeakingState,
                  ),
                ),
                Positioned(
                  bottom: 100,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: 120,
                      height: currentMouthHeight,
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide.none,
                          left: BorderSide(color: currentPrimaryColor, width: 3),
                          right: BorderSide(color: currentPrimaryColor, width: 3),
                          bottom: BorderSide(color: currentPrimaryColor, width: 3),
                        ),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(60),
                          bottomRight: Radius.circular(60),
                        ),
                      ),
                    ),
                  ),
                ),
                ..._buildEnergyLines(currentPrimaryColor, _energyLineController.value, currentSpeakingState),
                ..._buildParticles(currentPrimaryColor, _particleController.value, currentSpeakingState),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEye(Color primaryColor, Color secondaryColor, double scale, bool isSpeakingState) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [primaryColor, secondaryColor],
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(isSpeakingState ? 0.8 : 0.5),
            blurRadius: isSpeakingState ? 30.0 : 20.0,
            spreadRadius: 0,
          ),
        ],
      ),
      transform: Matrix4.identity()..scale(scale, scale),
    );
  }

  List<Widget> _buildEnergyLines(Color color, double animationValue, bool isSpeakingState) {
    return [
      Positioned(
        top: 80,
        left: 100,
        width: 200,
        height: 2,
        child: EnergyLine(
          color: color,
          animationValue: animationValue,
          speedFactor: isSpeakingState ? 2.0 : 1.0,
        ),
      ),
      Positioned(
        top: 160,
        left: 125,
        width: 150,
        height: 2,
        child: EnergyLine(
          color: color,
          animationValue: animationValue,
          speedFactor: isSpeakingState ? 2.0 : 1.0,
          delayFactor: 0.5,
        ),
      ),
      Positioned(
        top: 240,
        left: 110,
        width: 180,
        height: 2,
        child: EnergyLine(
          color: color,
          animationValue: animationValue,
          speedFactor: isSpeakingState ? 2.0 : 1.0,
          delayFactor: 1.0,
        ),
      ),
    ];
  }

  List<Widget> _buildParticles(Color color, double animationValue, bool isSpeakingState) {
    return [
      Particle(
        color: color,
        animationValue: animationValue,
        speedFactor: isSpeakingState ? 2.0 : 1.0,
        delayFactor: 0.0,
        initialPosition: const Offset(50, 50),
      ),
      Particle(
        color: color,
        animationValue: animationValue,
        speedFactor: isSpeakingState ? 2.0 : 1.0,
        delayFactor: 0.25,
        initialPosition: const Offset(300, 100),
      ),
      Particle(
        color: color,
        animationValue: animationValue,
        speedFactor: isSpeakingState ? 2.0 : 1.0,
        delayFactor: 0.5,
        initialPosition: const Offset(80, 250),
      ),
      Particle(
        color: color,
        animationValue: animationValue,
        speedFactor: isSpeakingState ? 2.0 : 1.0,
        delayFactor: 0.75,
        initialPosition: const Offset(320, 280),
      ),
    ];
  }
}

class EnergyLine extends StatelessWidget {
  final Color color;
  final double animationValue;
  final double speedFactor;
  final double delayFactor;

  const EnergyLine({
    super.key,
    required this.color,
    required this.animationValue,
    this.speedFactor = 1.0,
    this.delayFactor = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveAnimationValue = (animationValue * speedFactor + delayFactor) % 1.0;
    return CustomPaint(
      painter: _EnergyLinePainter(color, effectiveAnimationValue),
    );
  }
}

class _EnergyLinePainter extends CustomPainter {
  final Color color;
  final double animationValue;

  _EnergyLinePainter(this.color, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [color.withOpacity(0.0), color, color.withOpacity(0.0)],
        stops: const [0.0, 0.5, 1.0],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final segmentWidth = size.width * 0.3;
    final start = -segmentWidth + (size.width + segmentWidth) * animationValue;

    canvas.drawRect(Rect.fromLTWH(start, 0, segmentWidth, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant _EnergyLinePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue || oldDelegate.color != color;
  }
}

class Particle extends StatelessWidget {
  final Color color;
  final double animationValue;
  final double speedFactor;
  final double delayFactor;
  final Offset initialPosition;

  const Particle({
    super.key,
    required this.color,
    required this.animationValue,
    this.speedFactor = 1.0,
    this.delayFactor = 0.0,
    required this.initialPosition,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveAnimationValue = (animationValue * speedFactor + delayFactor) % 1.0;

    double opacity = 0.0;
    double translateY = 0.0;
    double scale = 0.0;

    if (effectiveAnimationValue < 0.5) {
      opacity = effectiveAnimationValue * 2;
      translateY = -60 * effectiveAnimationValue;
      scale = effectiveAnimationValue * 2;
    } else {
      opacity = 1 - (effectiveAnimationValue - 0.5) * 2;
      translateY = -60 - (effectiveAnimationValue - 0.5) * 60;
      scale = 1 - (effectiveAnimationValue - 0.5) * 1.5;
    }

    return Positioned(
      left: initialPosition.dx,
      top: initialPosition.dy + translateY,
      child: Opacity(
        opacity: opacity.clamp(0.0, 1.0),
        child: Transform.scale(
          scale: scale.clamp(0.0, 1.5),
          child: Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}