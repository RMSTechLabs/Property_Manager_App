import 'package:flutter/material.dart';

class ImageHelper {
  static const String _imagePath = 'assets/images';
  
  // Standard images
  static const String logo = '$_imagePath/logo.png';
  static const String placeholder = '$_imagePath/placeholder.png';
  
  // Icons
  static const String propertyIcon = '$_imagePath/icons/property.png';
  static const String tenantIcon = '$_imagePath/icons/tenant.png';
  static const String maintenanceIcon = '$_imagePath/icons/maintenance.png';
  
  // Background images
  static const String splashBackground = '$_imagePath/backgrounds/splash_bg.png';
  static const String loginBackground = '$_imagePath/backgrounds/login_bg.png';
  
  // Helper method to load images with error handling
  static Widget loadAssetImage(
    String path, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    String? semanticLabel,
    Widget? errorWidget,
  }) {
    return Image.asset(
      path,
      width: width,
      height: height,
      fit: fit,
      semanticLabel: semanticLabel,
      errorBuilder: (context, error, stackTrace) {
        return errorWidget ?? _defaultErrorWidget();
      },
    );
  }
  
  // Helper method for network images with caching
  static Widget loadNetworkImage(
    String url, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    return FadeInImage.assetNetwork(
      placeholder: ImageHelper.placeholder,
      image: url,
      width: width,
      height: height,
      fit: fit,
      imageErrorBuilder: (context, error, stackTrace) {
        return errorWidget ?? _defaultErrorWidget();
      },
    );
  }
  
  static Widget _defaultErrorWidget() {
    return Container(
      color: Colors.grey[200],
      child: const Icon(
        Icons.error_outline,
        color: Colors.grey,
      ),
    );
  }
}

// Custom Image Widget with better performance
class OptimizedImage extends StatelessWidget {
  final String? assetPath;
  final String? networkUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const OptimizedImage.asset(
    this.assetPath, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
  }) : networkUrl = null;

  const OptimizedImage.network(
    this.networkUrl, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
  }) : assetPath = null;

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    if (assetPath != null) {
      imageWidget = ImageHelper.loadAssetImage(
        assetPath!,
        width: width,
        height: height,
        fit: fit,
        errorWidget: errorWidget,
      );
    } else if (networkUrl != null) {
      imageWidget = ImageHelper.loadNetworkImage(
        networkUrl!,
        width: width,
        height: height,
        fit: fit,
        placeholder: placeholder,
        errorWidget: errorWidget,
      );
    } else {
      imageWidget = ImageHelper._defaultErrorWidget();
    }

    if (borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }
}