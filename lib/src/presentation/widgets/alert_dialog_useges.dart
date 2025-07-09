// // Usage Examples for CommonAlertDialog

// // 1. Replace your original method with this simple approach:
// void _showSelectCommunityAlert() {
//   CommonAlertDialogHelper.showWarning(
//     context: context,
//     title: 'Community Required',
//     content: 'Please select a community before continuing.',
//     buttonText: 'OK',
//   );
// }

// // 2. More advanced confirmation dialog:
// void _showDeleteConfirmation() async {
//   final confirmed = await CommonAlertDialogHelper.showConfirmation(
//     context: context,
//     title: 'Delete Property',
//     content: 'Are you sure you want to delete this property? This action cannot be undone.',
//     confirmText: 'Delete',
//     cancelText: 'Cancel',
//     type: AlertDialogType.error,
//   );
  
//   if (confirmed == true) {
//     // Proceed with deletion
//     _deleteProperty();
//   }
// }

// // 3. Success message:
// void _showSuccessMessage() {
//   CommonAlertDialogHelper.showSuccess(
//     context: context,
//     title: 'Success',
//     content: 'Property has been successfully added!',
//     buttonText: 'Great!',
//   );
// }

// // 4. Error with custom actions:
// void _showNetworkError() {
//   showDialog(
//     context: context,
//     builder: (context) => CommonAlertDialog(
//       title: 'Connection Error',
//       content: 'Unable to connect to the server. Please check your internet connection.',
//       type: AlertDialogType.error,
//       actions: [
//         AlertAction(
//           text: 'Retry',
//           type: AlertActionType.primary,
//           onPressed: () {
//             Navigator.of(context).pop();
//             _retryConnection();
//           },
//         ),
//         AlertAction(
//           text: 'Go Offline',
//           type: AlertActionType.secondary,
//           onPressed: () {
//             Navigator.of(context).pop();
//             _enableOfflineMode();
//           },
//         ),
//         AlertAction(
//           text: 'Cancel',
//           type: AlertActionType.cancel,
//         ),
//       ],
//     ),
//   );
// }

// // 5. Custom content widget:
// void _showCustomContentDialog() {
//   showDialog(
//     context: context,
//     builder: (context) => CommonAlertDialog(
//       title: 'Property Details',
//       type: AlertDialogType.info,
//       contentWidget: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text('Property Name: Villa Heights'),
//           const SizedBox(height: 8),
//           Text('Location: Downtown'),
//           const SizedBox(height: 8),
//           Text('Price: \$250,000'),
//           const SizedBox(height: 16),
//           Row(
//             children: [
//               Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
//               const SizedBox(width: 4),
//               Text('View on Map', style: TextStyle(color: Theme.of(context).primaryColor)),
//             ],
//           ),
//         ],
//       ),
//       actions: [
//         AlertAction(
//           text: 'Contact Owner',
//           type: AlertActionType.primary,
//           onPressed: () {
//             Navigator.of(context).pop();
//             _contactOwner();
//           },
//         ),
//         AlertAction(
//           text: 'Close',
//           type: AlertActionType.secondary,
//         ),
//       ],
//     ),
//   );
// }

// // 6. Loading state dialog:
// void _showLoadingDialog() {
//   showDialog(
//     context: context,
//     barrierDismissible: false,
//     builder: (context) => CommonAlertDialog(
//       title: 'Processing',
//       content: 'Please wait while we process your request...',
//       type: AlertDialogType.info,
//       barrierDismissible: false,
//       actions: [
//         AlertAction(
//           text: 'Processing...',
//           type: AlertActionType.primary,
//           isLoading: true,
//           onPressed: null, // Disabled while loading
//         ),
//       ],
//     ),
//   );
// }

// // 7. With localization support (if you have l10n setup):
// void _showLocalizedAlert(BuildContext context) {
//   // Assuming you have AppLocalizations setup
//   // final l10n = AppLocalizations.of(context);
  
//   CommonAlertDialogHelper.showWarning(
//     context: context,
//     title: 'Community Required', // l10n.communityRequired
//     content: 'Please select a community before continuing.', // l10n.pleaseSelectCommunity
//     buttonText: 'OK', // l10n.ok
//   );
// }

// // 8. Multiple choice dialog:
// void _showMultipleChoiceDialog() {
//   showDialog(
//     context: context,
//     builder: (context) => CommonAlertDialog(
//       title: 'Select Action',
//       content: 'What would you like to do with this property?',
//       type: AlertDialogType.confirmation,
//       actions: [
//         AlertAction(
//           text: 'Edit',
//           type: AlertActionType.primary,
//           onPressed: () {
//             Navigator.of(context).pop();
//             _editProperty();
//           },
//         ),
//         AlertAction(
//           text: 'Share',
//           type: AlertActionType.secondary,
//           onPressed: () {
//             Navigator.of(context).pop();
//             _shareProperty();
//           },
//         ),
//         AlertAction(
//           text: 'Delete',
//           type: AlertActionType.destructive,
//           onPressed: () {
//             Navigator.of(context).pop();
//             _showDeleteConfirmation();
//           },
//         ),
//         AlertAction(
//           text: 'Cancel',
//           type: AlertActionType.cancel,
//         ),
//       ],
//     ),
//   );
// }

// // Placeholder methods for examples
// void _deleteProperty() {}
// void _retryConnection() {}
// void _enableOfflineMode() {}
// void _contactOwner() {}
// void _editProperty() {}
// void _shareProperty() {}