import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:property_manager_app/src/core/utils/app_snackbar.dart';
import 'package:share_plus/share_plus.dart';

// Production Grade Image Viewer Screen
class ImageViewerScreen extends StatefulWidget {
  final File imageFile;
  final String heroTag;
  final String fileName;

  const ImageViewerScreen({
    super.key,
    required this.imageFile,
    required this.heroTag,
    required this.fileName,
  });

  @override
  State<ImageViewerScreen> createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends State<ImageViewerScreen>
    with TickerProviderStateMixin {
  late TransformationController _transformationController;
  late AnimationController _animationController;
  late AnimationController _overlayController;
  late Animation<double> _overlayAnimation;

  bool _showOverlay = true;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _overlayController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _overlayAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _overlayController, curve: Curves.easeInOut),
    );

    _overlayController.forward();
    // _loadImage();
  }

  void _loadImage() {
    // Simulate loading delay for better UX
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  void _toggleOverlay() {
    setState(() {
      _showOverlay = !_showOverlay;
    });

    if (_showOverlay) {
      _overlayController.forward();
    } else {
      _overlayController.reverse();
    }
  }

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
  }

  void _onInteractionEnd(ScaleEndDetails details) {
    // Auto-hide overlay when user starts interacting with image
    if (_showOverlay) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted && _showOverlay) {
          _toggleOverlay();
        }
      });
    }
  }

  String _getImageType() {
    final extension = widget.imageFile.path.split('.').last.toLowerCase();
    if (extension == 'jpg' || extension == 'jpeg') return 'JPG';
    if (extension == 'png') return 'PNG';
    if (extension == 'webp') return 'WebP';
    return extension.toUpperCase(); // Fallback for other types
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Main Image Viewer
          GestureDetector(
            onTap: _toggleOverlay,
            child: Center(
              child: Hero(
                tag: widget.heroTag,
                child: InteractiveViewer(
                  transformationController: _transformationController,
                  minScale: 0.5,
                  maxScale: 4.0,
                  onInteractionEnd: _onInteractionEnd,
                  child: _buildImageContent(screenWidth, screenHeight),
                ),
              ),
            ),
          ),

          // Top Overlay
          AnimatedBuilder(
            animation: _overlayAnimation,
            builder: (context, child) {
              return Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Transform.translate(
                  offset: Offset(0, -100 * (1 - _overlayAnimation.value)),
                  child: Opacity(
                    opacity: _overlayAnimation.value,
                    child: _buildTopOverlay(screenWidth),
                  ),
                ),
              );
            },
          ),

          // Bottom Overlay
          AnimatedBuilder(
            animation: _overlayAnimation,
            builder: (context, child) {
              return Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Transform.translate(
                  offset: Offset(0, 100 * (1 - _overlayAnimation.value)),
                  child: Opacity(
                    opacity: _overlayAnimation.value,
                    child: _buildBottomOverlay(screenWidth),
                  ),
                ),
              );
            },
          ),

          // Loading Indicator
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      color: Color(0xFF10B981),
                      strokeWidth: 3,
                    ),
                    SizedBox(height: screenWidth * 0.05),
                    Text(
                      "Loading image...",
                      style: GoogleFonts.lato(
                        color: Colors.white,
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.w500,
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

  Widget _buildImageContent(double screenWidth, double screenHeight) {
    if (_error != null) {
      return Container(
        width: screenWidth * 0.8,
        height: screenHeight * 0.5,
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red,
              size: screenWidth * 0.15,
            ),
            SizedBox(height: screenWidth * 0.05),
            Text(
              "Failed to load image",
              style: GoogleFonts.lato(
                color: Colors.white,
                fontSize: screenWidth * 0.045,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: screenWidth * 0.02),
            Text(
              _error!,
              style: GoogleFonts.lato(
                color: Colors.white70,
                fontSize: screenWidth * 0.035,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.file(
        widget.imageFile,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              _error = error.toString();
              _isLoading = false;
            });
          });
          return const SizedBox.shrink();
        },
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded || frame != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && _isLoading) {
                setState(() {
                  _isLoading = false;
                });
              }
            });
            return child;
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildTopOverlay(double screenWidth) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha:0.8),
            Colors.black.withValues(alpha:0.4),
            Colors.transparent,
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Row(
            children: [
              // Close Button
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: screenWidth * 0.12,
                  height: screenWidth * 0.12,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha:0.5),
                    borderRadius: BorderRadius.circular(screenWidth * 0.06),
                    border: Border.all(
                      color: Colors.white.withValues(alpha:0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: screenWidth * 0.06,
                  ),
                ),
              ),

              SizedBox(width: screenWidth * 0.04),

              // Image Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Image Preview",
                      style: GoogleFonts.lato(
                        color: Colors.white,
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: screenWidth * 0.01),
                    Text(
                      widget.fileName,
                      style: GoogleFonts.lato(
                        color: Colors.white70,
                        fontSize: screenWidth * 0.035,
                        fontWeight: FontWeight.w400,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Reset Zoom Button
              GestureDetector(
                onTap: _resetZoom,
                child: Container(
                  width: screenWidth * 0.12,
                  height: screenWidth * 0.12,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha:0.5),
                    borderRadius: BorderRadius.circular(screenWidth * 0.06),
                    border: Border.all(
                      color: Colors.white.withValues(alpha:0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.zoom_out_map,
                    color: Colors.white,
                    size: screenWidth * 0.05,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomOverlay(double screenWidth) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withValues(alpha:0.8),
            Colors.black.withValues(alpha:0.4),
            Colors.transparent,
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image Details Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(screenWidth * 0.04),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha:0.6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha:0.1),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Image Details",
                      style: GoogleFonts.lato(
                        color: Colors.white,
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: screenWidth * 0.03),
                    _buildDetailRow("File Name", widget.fileName, screenWidth),
                    _buildDetailRow("Size", _getFileSize(), screenWidth),
                    // _buildDetailRow("Type", "Image", screenWidth),
                    _buildDetailRow("Type", _getImageType(), screenWidth),
                  ],
                ),
              ),

              SizedBox(height: screenWidth * 0.04),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      "Remove",
                      Icons.delete_outline,
                      Colors.red.withValues(alpha:0.8),
                      () => _removeImage(),
                      screenWidth,
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.03),
                  Expanded(
                    child: _buildActionButton(
                      "Share",
                      Icons.share_outlined,
                      const Color(0xFF10B981).withValues(alpha:0.8),
                      () => _shareImage(),
                      screenWidth,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, double screenWidth) {
    return Padding(
      padding: EdgeInsets.only(bottom: screenWidth * 0.02),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: screenWidth * 0.2,
            child: Text(
              "$label:",
              style: GoogleFonts.lato(
                color: Colors.white70,
                fontSize: screenWidth * 0.035,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.lato(
                color: Colors.white,
                fontSize: screenWidth * 0.035,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
    double screenWidth,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: screenWidth * 0.035,
          horizontal: screenWidth * 0.04,
        ),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withValues(alpha:0.2), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: screenWidth * 0.045),
            SizedBox(width: screenWidth * 0.02),
            Text(
              label,
              style: GoogleFonts.lato(
                color: Colors.white,
                fontSize: screenWidth * 0.035,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getFileSize() {
    try {
      final bytes = widget.imageFile.lengthSync();
      if (bytes < 1024) return '$bytes B';
      if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } catch (e) {
      return 'Unknown';
    }
  }

  void _removeImage() {
    Navigator.pop(context, 'remove');
  }

  void _shareImage() async {
    try {
      final filePath = widget.imageFile.path;
      await Share.shareXFiles([XFile(filePath)], text: 'Check out this image!');
    } catch (e) {
      if (!mounted) return;

      AppSnackBar.showError(
        context: context,
        message: 'Failed to share image.',
      );
    }
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _animationController.dispose();
    _overlayController.dispose();
    super.dispose();
  }
}
