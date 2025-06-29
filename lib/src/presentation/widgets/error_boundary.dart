import 'package:flutter/material.dart';

class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(Object error, StackTrace? stackTrace)? errorBuilder;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorBuilder,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;
  StackTrace? _stackTrace;

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.errorBuilder?.call(_error!, _stackTrace) ??
          _DefaultErrorWidget(error: _error!, stackTrace: _stackTrace);
    }

    return widget.child;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    FlutterError.onError = (FlutterErrorDetails details) {
      if (mounted) {
        if (!mounted) return;//
        setState(() {
          _error = details.exception;
          _stackTrace = details.stack;
        });
      }
    };
  }
}

class _DefaultErrorWidget extends StatelessWidget {
  final Object error;
  final StackTrace? stackTrace;

  const _DefaultErrorWidget({
    required this.error,
    this.stackTrace,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Restart the app or navigate to home
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/home',
                  (route) => false,
                );
              },
              child: const Text('Restart App'),
            ),
          ],
        ),
      ),
    );
  }
}