// lib/core/widgets/error_widget.dart
import 'package:flutter/material.dart';

/// Custom ErrorWidget for showing errors in a user-friendly way
class CustomErrorWidget extends StatefulWidget {
  final Object error;
  final StackTrace? stackTrace;
  final VoidCallback? onRetry;
  final VoidCallback? onGoHome;

  const CustomErrorWidget({
    super.key,
    required this.error,
    this.stackTrace,
    this.onRetry,
    this.onGoHome,
  });

  @override
  State<CustomErrorWidget> createState() => _CustomErrorWidgetState();
}

class _CustomErrorWidgetState extends State<CustomErrorWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  bool _showDetails = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: Transform.translate(
                offset: Offset(0, _slideAnimation.value),
                child: _buildErrorContent(screenWidth, screenHeight),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildErrorContent(double screenWidth, double screenHeight) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(screenWidth * 0.06),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: screenHeight * 0.1),
          
          // Error Icon
          _buildErrorIcon(screenWidth),
          
          SizedBox(height: screenWidth * 0.08),
          
          // Error Title
          Text(
            'Something went wrong',
            style: TextStyle(
              fontSize: screenWidth * 0.06,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: screenWidth * 0.04),
          
          // Error Subtitle
          Text(
            'We apologize for the inconvenience.\nPlease try again or go back to home.',
            style: TextStyle(
              fontSize: screenWidth * 0.04,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: screenWidth * 0.1),
          
          // Action Buttons
          _buildActionButtons(screenWidth),
          
          SizedBox(height: screenWidth * 0.08),
          
          // Show Details Button
          _buildDetailsButton(screenWidth),
          
          if (_showDetails) ...[
            SizedBox(height: screenWidth * 0.04),
            _buildErrorDetails(screenWidth),
          ],
          
          SizedBox(height: screenHeight * 0.1),
        ],
      ),
    );
  }

  Widget _buildErrorIcon(double screenWidth) {
    return Container(
      width: screenWidth * 0.25,
      height: screenWidth * 0.25,
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.red.shade200,
          width: 2,
        ),
      ),
      child: Icon(
        Icons.error_outline,
        size: screenWidth * 0.12,
        color: Colors.red.shade600,
      ),
    );
  }

  Widget _buildActionButtons(double screenWidth) {
    return Column(
      children: [
        if (widget.onRetry != null) ...[
          _buildButton(
            'Try Again',
            Icons.refresh,
            Colors.blue,
            widget.onRetry!,
            screenWidth,
            isPrimary: true,
          ),
          
          if (widget.onGoHome != null) SizedBox(height: screenWidth * 0.03),
        ],
        
        if (widget.onGoHome != null)
          _buildButton(
            'Go to Home',
            Icons.home,
            Colors.grey.shade600,
            widget.onGoHome!,
            screenWidth,
            isPrimary: false,
          ),
      ],
    );
  }

  Widget _buildButton(
    String text,
    IconData icon,
    Color color,
    VoidCallback onPressed,
    double screenWidth, {
    required bool isPrimary,
  }) {
    return Container(
      width: double.infinity,
      height: screenWidth * 0.12,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: screenWidth * 0.045),
        label: Text(
          text,
          style: TextStyle(
            fontSize: screenWidth * 0.04,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? color : Colors.white,
          foregroundColor: isPrimary ? Colors.white : color,
          side: isPrimary ? null : BorderSide(color: Colors.grey.shade300),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: isPrimary ? 2 : 0,
        ),
      ),
    );
  }

  Widget _buildDetailsButton(double screenWidth) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showDetails = !_showDetails;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: screenWidth * 0.02,
        ),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _showDetails ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: Colors.grey.shade600,
              size: screenWidth * 0.045,
            ),
            SizedBox(width: screenWidth * 0.02),
            Text(
              _showDetails ? 'Hide Details' : 'Show Details',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: screenWidth * 0.035,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorDetails(double screenWidth) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Error Details',
            style: TextStyle(
              fontSize: screenWidth * 0.04,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          
          SizedBox(height: screenWidth * 0.03),
          
          Text(
            'Error: ${widget.error}',
            style: TextStyle(
              fontSize: screenWidth * 0.035,
              color: Colors.grey.shade600,
              fontFamily: 'monospace',
            ),
          ),
          
          if (widget.stackTrace != null) ...[
            SizedBox(height: screenWidth * 0.03),
            Text(
              'Stack Trace:',
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: screenWidth * 0.02),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(screenWidth * 0.03),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                widget.stackTrace.toString(),
                style: TextStyle(
                  fontSize: screenWidth * 0.025,
                  color: Colors.grey.shade600,
                  fontFamily: 'monospace',
                  height: 1.2,
                ),
                maxLines: 8,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }
}