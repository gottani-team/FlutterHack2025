import 'package:flutter/material.dart';

/// Widget that displays memory text with a rising animation from the bottom
class MemoryTextWidget extends StatefulWidget {
  const MemoryTextWidget({
    super.key,
    required this.text,
    required this.isVisible,
    this.animationDuration = const Duration(milliseconds: 2500),
    this.onAnimationComplete,
  });

  /// The memory text to display
  final String text;

  /// Whether the text should be visible (triggers animation)
  final bool isVisible;

  /// Duration of the rise animation
  final Duration animationDuration;

  /// Callback when the animation completes
  final VoidCallback? onAnimationComplete;

  @override
  State<MemoryTextWidget> createState() => _MemoryTextWidgetState();
}

class _MemoryTextWidgetState extends State<MemoryTextWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1), // Start below screen
      end: Offset.zero, // End at final position
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
    ));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onAnimationComplete?.call();
      }
    });

    // Start animation if already visible on first build
    if (widget.isVisible) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.forward();
      });
    }
  }

  @override
  void didUpdateWidget(MemoryTextWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible && !oldWidget.isVisible) {
      debugPrint('MemoryTextWidget: Starting reveal animation');
      _controller.forward(from: 0);
    } else if (!widget.isVisible && oldWidget.isVisible) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // RepaintBoundary isolates the slide/fade animation for 60fps performance
    return RepaintBoundary(
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0x009ACCFD), // 0% opacity
                  const Color(0xE69ACCFD), // 90% opacity
                  const Color(0xFF9ACCFD), // 100% opacity
                ],
                stops: const [0.0, 0.3, 1.0],
              ),
            ),
            child: SafeArea(
              top: false,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.4,
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Text(
                    widget.text,
                    style: const TextStyle(
                      color: Color(0xFF1A3A5C), // Dark blue for readability
                      fontSize: 18,
                      height: 1.6,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
