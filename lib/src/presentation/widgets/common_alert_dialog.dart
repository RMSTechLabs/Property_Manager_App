// lib/src/presentation/widgets/common/common_alert_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;

enum AlertDialogType {
  info,
  warning,
  error,
  success,
  confirmation,
}

enum AlertActionType {
  primary,
  secondary,
  destructive,
  cancel,
}

class AlertAction {
  final String text;
  final VoidCallback? onPressed;
  final AlertActionType type;
  final bool isLoading;

  const AlertAction({
    required this.text,
    this.onPressed,
    this.type = AlertActionType.secondary,
    this.isLoading = false,
  });
}

class CommonAlertDialog extends StatelessWidget {
  final String title;
  final String? content;
  final Widget? contentWidget;
  final List<AlertAction> actions;
  final AlertDialogType type;
  final bool barrierDismissible;
  final IconData? customIcon;
  final Color? customIconColor;

  const CommonAlertDialog({
    super.key,
    required this.title,
    this.content,
    this.contentWidget,
    this.actions = const [],
    this.type = AlertDialogType.info,
    this.barrierDismissible = true,
    this.customIcon,
    this.customIconColor,
  }) : assert(
          (content != null) ^ (contentWidget != null),
          'Either content or contentWidget must be provided, but not both',
        );

  @override
  Widget build(BuildContext context) {
    // Use Cupertino style on iOS, Material on Android
    if (Platform.isIOS && type != AlertDialogType.confirmation) {
      return _buildCupertinoDialog(context);
    }
    return _buildMaterialDialog(context);
  }

  Widget _buildMaterialDialog(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      actionsPadding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      title: _buildTitle(context),
      content: _buildContent(context),
      actions: _buildMaterialActions(context),
      backgroundColor: colorScheme.surface,
      surfaceTintColor: colorScheme.surfaceTint,
      elevation: 6,
    );
  }

  Widget _buildCupertinoDialog(BuildContext context) {
    return CupertinoAlertDialog(
      title: _buildTitle(context, isCupertino: true),
      content: _buildContent(context, isCupertino: true),
      actions: _buildCupertinoActions(context),
    );
  }

  Widget _buildTitle(BuildContext context, {bool isCupertino = false}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final icon = _getTypeIcon();
    final iconColor = _getTypeIconColor(colorScheme);

    return Row(
      children: [
        if (icon != null) ...[
          Icon(
            customIcon ?? icon,
            color: customIconColor ?? iconColor,
            size: isCupertino ? 20 : 24,
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Text(
            title,
            style: isCupertino
                ? const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  )
                : theme.textTheme.headlineSmall?.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, {bool isCupertino = false}) {
    final theme = Theme.of(context);
    
    Widget contentChild;
    if (contentWidget != null) {
      contentChild = contentWidget!;
    } else {
      contentChild = Text(
        content!,
        style: isCupertino
            ? const TextStyle(fontSize: 13)
            : theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(
        top: isCupertino ? 8 : 16,
        bottom: isCupertino ? 0 : 16,
      ),
      child: contentChild,
    );
  }

  List<Widget> _buildMaterialActions(BuildContext context) {
    if (actions.isEmpty) {
      return [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ];
    }

    return actions.map((action) => _buildMaterialAction(context, action)).toList();
  }

  Widget _buildMaterialAction(BuildContext context, AlertAction action) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (action.isLoading) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: TextButton(
          onPressed: null,
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: colorScheme.primary,
            ),
          ),
        ),
      );
    }

    switch (action.type) {
      case AlertActionType.primary:
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          child: FilledButton(
            onPressed: action.onPressed ?? () => Navigator.of(context).pop(),
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            ),
            child: Text(action.text),
          ),
        );

      case AlertActionType.destructive:
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          child: FilledButton(
            onPressed: action.onPressed ?? () => Navigator.of(context).pop(),
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
            ),
            child: Text(action.text),
          ),
        );

      case AlertActionType.cancel:
      case AlertActionType.secondary:
      return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          child: TextButton(
            onPressed: action.onPressed ?? () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: action.type == AlertActionType.cancel
                  ? colorScheme.onSurfaceVariant
                  : colorScheme.primary,
            ),
            child: Text(action.text),
          ),
        );
    }
  }

  List<Widget> _buildCupertinoActions(BuildContext context) {
    if (actions.isEmpty) {
      return [
        CupertinoDialogAction(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ];
    }

    return actions.map((action) => _buildCupertinoAction(context, action)).toList();
  }

  Widget _buildCupertinoAction(BuildContext context, AlertAction action) {
    if (action.isLoading) {
      return CupertinoDialogAction(
        onPressed: null,
        child: const CupertinoActivityIndicator(),
      );
    }

    bool isDestructive = action.type == AlertActionType.destructive;
    bool isDefault = action.type == AlertActionType.primary;

    return CupertinoDialogAction(
      onPressed: action.onPressed ?? () => Navigator.of(context).pop(),
      isDestructiveAction: isDestructive,
      isDefaultAction: isDefault,
      child: Text(action.text),
    );
  }

  IconData? _getTypeIcon() {
    switch (type) {
      case AlertDialogType.info:
        return Icons.info_outline;
      case AlertDialogType.warning:
        return Icons.warning_amber_outlined;
      case AlertDialogType.error:
        return Icons.error_outline;
      case AlertDialogType.success:
        return Icons.check_circle_outline;
      case AlertDialogType.confirmation:
        return Icons.help_outline;
    }
  }

  Color _getTypeIconColor(ColorScheme colorScheme) {
    switch (type) {
      case AlertDialogType.info:
        return colorScheme.primary;
      case AlertDialogType.warning:
        return Colors.orange;
      case AlertDialogType.error:
        return colorScheme.error;
      case AlertDialogType.success:
        return Colors.green;
      case AlertDialogType.confirmation:
        return colorScheme.primary;
    }
  }
}

// Helper class for easy usage
class CommonAlertDialogHelper {
  static Future<bool?> showConfirmation({
    required BuildContext context,
    required String title,
    required String content,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    AlertDialogType type = AlertDialogType.confirmation,
    bool barrierDismissible = true,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => CommonAlertDialog(
        title: title,
        content: content,
        type: type,
        barrierDismissible: barrierDismissible,
        actions: [
          AlertAction(
            text: cancelText,
            type: AlertActionType.cancel,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          AlertAction(
            text: confirmText,
            type: AlertActionType.primary,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
  }

  static Future<void> showInfo({
    required BuildContext context,
    required String title,
    required String content,
    String buttonText = 'OK',
    AlertDialogType type = AlertDialogType.info,
    bool barrierDismissible = true,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => CommonAlertDialog(
        title: title,
        content: content,
        type: type,
        barrierDismissible: barrierDismissible,
        actions: [
          AlertAction(
            text: buttonText,
            type: AlertActionType.primary,
          ),
        ],
      ),
    );
  }

  static Future<void> showError({
    required BuildContext context,
    required String title,
    required String content,
    String buttonText = 'OK',
    bool barrierDismissible = true,
  }) {
    return showInfo(
      context: context,
      title: title,
      content: content,
      buttonText: buttonText,
      type: AlertDialogType.error,
      barrierDismissible: barrierDismissible,
    );
  }

  static Future<void> showSuccess({
    required BuildContext context,
    required String title,
    required String content,
    String buttonText = 'OK',
    bool barrierDismissible = true,
  }) {
    return showInfo(
      context: context,
      title: title,
      content: content,
      buttonText: buttonText,
      type: AlertDialogType.success,
      barrierDismissible: barrierDismissible,
    );
  }

  static Future<void> showWarning({
    required BuildContext context,
    required String title,
    required String content,
    String buttonText = 'OK',
    bool barrierDismissible = true,
  }) {
    return showInfo(
      context: context,
      title: title,
      content: content,
      buttonText: buttonText,
      type: AlertDialogType.warning,
      barrierDismissible: barrierDismissible,
    );
  }
}