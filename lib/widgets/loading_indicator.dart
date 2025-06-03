import 'package:flutter/material.dart';
import 'package:project_resendis/styles/app_colors.dart';

class LoadingIndicator extends StatefulWidget {
  final double size;
  final Color? color;
  final String? message;
  final bool isLoading;
  final Color? textColor; // Este parámetro ya está añadido

  const LoadingIndicator({
    Key? key,
    this.size = 40.0,
    this.color,
    this.message,
    this.isLoading = true,
    this.textColor, // Este parámetro ya está añadido
  }) : super(key: key);

  @override
  State<LoadingIndicator> createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<LoadingIndicator> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) return const SizedBox.shrink();
    
    return Center(
      child: AnimatedOpacity(
        opacity: widget.isLoading ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _controller.value * 2 * 3.14159,
                  child: Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: SweepGradient(
                        colors: [
                          widget.color ?? AppColors.primaryColor,
                          (widget.color ?? AppColors.primaryColor).withOpacity(0.3),
                        ],
                        stops: const [0.5, 1.0],
                        startAngle: 0,
                        endAngle: 3.14159 * 2,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(widget.size * 0.15),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).scaffoldBackgroundColor,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            if (widget.message != null) ...[
              const SizedBox(height: 16.0),
              Text(
                widget.message!,
                style: TextStyle(
                  color: widget.textColor ?? Theme.of(context).textTheme.bodyMedium?.color,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}