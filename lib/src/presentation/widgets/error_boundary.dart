// lib/core/widgets/error_boundary.dart
import 'package:flutter/material.dart';
import 'package:property_manager_app/src/presentation/widgets/error_widget.dart';

/// ErrorBoundary that catches and handles errors in Flutter apps
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final void Function(Object error, StackTrace? stackTrace)? onError;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.onError,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;
  StackTrace? _stackTrace;
  bool _hasError = false;

  @override
  Widget build(BuildContext context) {
    if (_hasError && _error != null) {
      // Show our custom error widget
      return CustomErrorWidget(
        error: _error!,
        stackTrace: _stackTrace,
        onRetry: _resetError,
        onGoHome: () {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/',
            (route) => false,
          );
        },
      );
    }

    // Wrap child to catch errors
    return _ErrorWrapper(
      onError: _handleError,
      child: widget.child,
    );
  }

  void _handleError(Object error, StackTrace? stackTrace) {
    // Call custom error handler if provided
    widget.onError?.call(error, stackTrace);

    // Update state safely using post-frame callback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _error = error;
          _stackTrace = stackTrace;
          _hasError = true;
        });
      }
    });
  }

  void _resetError() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _error = null;
          _stackTrace = null;
          _hasError = false;
        });
      }
    });
  }
}

/// Internal wrapper that catches errors
class _ErrorWrapper extends StatefulWidget {
  final Widget child;
  final void Function(Object error, StackTrace? stackTrace) onError;

  const _ErrorWrapper({
    required this.child,
    required this.onError,
  });

  @override
  State<_ErrorWrapper> createState() => _ErrorWrapperState();
}

class _ErrorWrapperState extends State<_ErrorWrapper> {
  ErrorWidgetBuilder? _previousErrorBuilder;

  @override
  void initState() {
    super.initState();
    _setupErrorHandling();
  }

  @override
  void dispose() {
    _restoreErrorHandling();
    super.dispose();
  }

  void _setupErrorHandling() {
    // Store the previous error builder
    _previousErrorBuilder = ErrorWidget.builder;

    // Set custom error builder
    ErrorWidget.builder = (FlutterErrorDetails details) {
      // Handle the error
      widget.onError(details.exception, details.stack);

      // Return a simple error widget
      return Container(
        color: Colors.red.shade100,
        child: Center(
          child: Text(
            'Error: ${details.exception}',
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      );
    };
  }

  void _restoreErrorHandling() {
    // Restore previous error builder
    if (_previousErrorBuilder != null) {
      ErrorWidget.builder = _previousErrorBuilder!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}