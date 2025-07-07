import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:property_manager_app/src/core/constants/app_constants.dart';
import 'package:property_manager_app/src/core/utils/app_helper.dart';
import 'package:property_manager_app/src/core/utils/app_snackbar.dart';
import 'package:property_manager_app/src/data/models/category_model.dart';
import 'package:property_manager_app/src/data/models/location_model.dart';
import 'package:property_manager_app/src/data/services/complaint/complaint_service.dart';
import 'package:property_manager_app/src/presentation/providers/society_provider.dart';
import 'package:property_manager_app/src/presentation/widgets/category_selection.dart';
import 'package:property_manager_app/src/presentation/widgets/image_viewer.dart';
import 'package:property_manager_app/src/presentation/widgets/location_selection.dart';

// Gradient Button Widget
class GradientButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final Gradient gradient;
  final TextStyle textStyle;
  final bool isLoading;

  const GradientButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.borderRadius = 8.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    this.gradient = const LinearGradient(
      colors: [Color(0xFF5A5FFF), Color(0xFFB833F2)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ),
    this.textStyle = const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          textStyle: textStyle,
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(label),
      ),
    );
  }
}

class CreateComplaintScreen extends ConsumerStatefulWidget {
  const CreateComplaintScreen({super.key});

  @override
  ConsumerState<CreateComplaintScreen> createState() =>
      _CreateComplaintScreenState();
}

class _CreateComplaintScreenState extends ConsumerState<CreateComplaintScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();

  String? _selectedCategoryId;
  String? _selectedCategoryTitle;
  LocationModel? _selectedLocation;
  String? _selectedLocationTitle;
  String _visibility = 'personal';
  bool _isUrgent = false;
  bool _isSubmitting = false;

  List<File> _selectedFiles = [];
  final ImagePicker _picker = ImagePicker();

  // Theme colors matching gradient button
  static const Color primaryColor = Color(0xFF5A5FFF);
  static const Color secondaryColor = Color(0xFFB833F2);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppConstants.secondartGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(screenWidth),

              // Form Content
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(top: screenHeight * 0.02),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      Expanded(child: _buildForm(screenWidth)),
                      _buildSubmitButton(screenWidth),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(double screenWidth) {
    return Padding(
      padding: EdgeInsets.all(screenWidth * 0.05),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: screenWidth * 0.12,
              height: screenWidth * 0.12,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(screenWidth * 0.06),
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: screenWidth * 0.05,
              ),
            ),
          ),
          SizedBox(width: screenWidth * 0.04),
          Expanded(
            child: Text(
              "Create Ticket",
              style: GoogleFonts.lato(
                color: Colors.white,
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(double screenWidth) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Visibility Selection - Fixed responsive layout
            _buildVisibilitySelector(screenWidth),

            SizedBox(height: screenWidth * 0.04),

            // Category Selection
            _buildCategorySelector(screenWidth),

            SizedBox(height: screenWidth * 0.04),

            // Location Selection
            _buildLocationSelector(screenWidth),

            SizedBox(height: screenWidth * 0.04),

            // Description Field
            _buildDescriptionField(screenWidth),

            SizedBox(height: screenWidth * 0.04),

            // File Preview Grid
            if (_selectedFiles.isNotEmpty) _buildFilePreview(screenWidth),

            SizedBox(height: screenWidth * 0.04),

            // Bottom Controls
            _buildBottomControls(screenWidth),
          ],
        ),
      ),
    );
  }

  Widget _buildVisibilitySelector(double screenWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Complaint Visibility",
          style: GoogleFonts.lato(
            fontSize: screenWidth * 0.038,
            color: AppConstants.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: screenWidth * 0.025),
        // Fixed responsive layout for radio options
        LayoutBuilder(
          builder: (context, constraints) {
            // Check if we have enough space for horizontal layout
            bool useVerticalLayout = constraints.maxWidth < 400;

            if (useVerticalLayout) {
              return Column(
                children: [
                  _buildVisibilityOption(
                    'personal',
                    "Personal(Only Me)",
                    screenWidth,
                  ),
                  SizedBox(height: screenWidth * 0.025),
                  _buildVisibilityOption(
                    'community',
                    "Community(All)",
                    screenWidth,
                  ),
                ],
              );
            } else {
              return Row(
                children: [
                  Expanded(
                    child: _buildVisibilityOption(
                      'personal',
                      "Personal(Only Me)",
                      screenWidth,
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.025),
                  Expanded(
                    child: _buildVisibilityOption(
                      'community',
                      "Community(All)",
                      screenWidth,
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildVisibilityOption(
    String value,
    String label,
    double screenWidth,
  ) {
    final isSelected = _visibility == value;
    return GestureDetector(
      onTap: () => setState(() => _visibility = value),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.035,
          vertical: screenWidth * 0.025,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: screenWidth * 0.045,
              height: screenWidth * 0.045,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? primaryColor : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: screenWidth * 0.02,
                        height: screenWidth * 0.02,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: primaryColor,
                        ),
                      ),
                    )
                  : null,
            ),
            SizedBox(width: screenWidth * 0.025),
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.lato(
                  fontSize: screenWidth * 0.032,
                  color: AppConstants.black,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelector(double screenWidth) {
    return GestureDetector(
      onTap: () => _navigateToCategorySelection(),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: screenWidth * 0.04,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                _selectedCategoryTitle ?? "Select Category",
                style: GoogleFonts.lato(
                  fontSize: screenWidth * 0.04,
                  color: _selectedCategoryTitle != null
                      ? AppConstants.black
                      : AppConstants.black50,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              color: AppConstants.black50,
              size: screenWidth * 0.05,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSelector(double screenWidth) {
    return GestureDetector(
      onTap: () => _navigateToLocationSelection(),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: screenWidth * 0.04,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                _selectedLocationTitle ?? "Select Location",
                style: GoogleFonts.lato(
                  fontSize: screenWidth * 0.04,
                  color: _selectedLocationTitle != null
                      ? AppConstants.black
                      : AppConstants.black50,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              color: AppConstants.black50,
              size: screenWidth * 0.05,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionField(double screenWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          height: screenWidth * 0.35,
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
                "Description (mandatory)",
                style: GoogleFonts.lato(
                  fontSize: screenWidth * 0.035,
                  color: AppConstants.black50,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: screenWidth * 0.02),
              Expanded(
                child: TextFormField(
                  controller: _descriptionController,
                  maxLines: null,
                  expands: true,
                  style: GoogleFonts.lato(
                    fontSize: screenWidth * 0.04,
                    color: AppConstants.black,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Please describe your issue in detail...",
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Description is required';
                    }
                    if (value.trim().length < 10) {
                      return 'Please provide more details (minimum 10 characters)';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilePreview(double screenWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Attachments",
          style: GoogleFonts.lato(
            fontSize: screenWidth * 0.04,
            color: AppConstants.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: screenWidth * 0.03),
        SizedBox(
          height: screenWidth * 0.22,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _selectedFiles.length,
            itemBuilder: (context, index) {
              final file = _selectedFiles[index];
              return Container(
                width: screenWidth * 0.22,
                margin: EdgeInsets.only(right: screenWidth * 0.02),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Stack(
                  children: [
                    GestureDetector(
                      onTap: () => _isImageFile(file.path)
                          ? _openImageViewer(context, file, index)
                          : null,
                      child: Hero(
                        tag: 'image_$index',
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: _isImageFile(file.path)
                              ? Image.file(
                                  file,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  color: Colors.grey.shade200,
                                  child: Icon(
                                    Icons.insert_drive_file,
                                    size: screenWidth * 0.06,
                                    color: AppConstants.black50,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => _removeFile(index),
                        child: Container(
                          padding: EdgeInsets.all(screenWidth * 0.012),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                            size: screenWidth * 0.025,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        SizedBox(height: screenWidth * 0.04),
      ],
    );
  }

  Widget _buildBottomControls(double screenWidth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Urgent Checkbox
        Flexible(
          flex: 2,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Checkbox(
                value: _isUrgent,
                onChanged: (bool? value) {
                  setState(() {
                    _isUrgent = value ?? false;
                  });
                },
                activeColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Flexible(
                child: Text(
                  "This is Urgent",
                  style: GoogleFonts.lato(
                    fontSize: screenWidth * 0.032,
                    color: AppConstants.black,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),

        // Action Buttons
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Voice Recording Button
            GestureDetector(
              onTap: () => _recordVoice(),
              child: Container(
                width: screenWidth * 0.11,
                height: screenWidth * 0.11,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(screenWidth * 0.055),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.mic,
                  color: AppConstants.black,
                  size: screenWidth * 0.045,
                ),
              ),
            ),

            SizedBox(width: screenWidth * 0.025),

            // Attachment Button
            GestureDetector(
              onTap: () => _showAttachmentOptions(context, screenWidth),
              child: Container(
                width: screenWidth * 0.11,
                height: screenWidth * 0.11,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(screenWidth * 0.055),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.attach_file,
                  color: AppConstants.black,
                  size: screenWidth * 0.045,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSubmitButton(double screenWidth) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(screenWidth * 0.05),
      child: GradientButton(
        onPressed: _isSubmitting ? null : _submitTicket,
        label: "Log Ticket",
        isLoading: _isSubmitting,
        padding: EdgeInsets.symmetric(vertical: screenWidth * 0.04),
        textStyle: GoogleFonts.lato(
          fontSize: screenWidth * 0.045,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  // Navigation Methods
  void _navigateToCategorySelection() async {
    final result = await Navigator.push<CategoryModel>(
      context,
      MaterialPageRoute(builder: (context) => const CategorySelectionScreen()),
    );

    if (result != null) {
      setState(() {
        _selectedCategoryId = result.id;
        _selectedCategoryTitle = result.categoryTitle;
      });
    }
  }

  void _navigateToLocationSelection() async {
    final result = await Navigator.push<LocationModel>(
      context,
      MaterialPageRoute(builder: (context) => const LocationSelectionScreen()),
    );

    if (result != null) {
      setState(() {
        _selectedLocation = result;
        _selectedLocationTitle = result.locationName;
      });
    }
  }

  // Permission and Attachment Methods - Fixed bottom sheet overflow
  void _showAttachmentOptions(BuildContext context, double screenWidth) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05,
          vertical: screenWidth * 0.04,
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: screenWidth * 0.12,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: screenWidth * 0.04),
              Text(
                "Add Attachments!",
                style: GoogleFonts.lato(
                  fontSize: screenWidth * 0.045,
                  fontWeight: FontWeight.w600,
                  color: AppConstants.black,
                ),
              ),
              SizedBox(height: screenWidth * 0.035),
              _buildAttachmentOption(
                "Take Photo",
                Icons.camera_alt,
                () => _handleImageSelection(ImageSource.camera),
                screenWidth,
              ),
              _buildAttachmentOption(
                "Take Video",
                Icons.videocam,
                () => _handleVideoSelection(ImageSource.camera),
                screenWidth,
              ),
              _buildAttachmentOption(
                "Add Documents",
                Icons.folder,
                () => _handleDocumentSelection(),
                screenWidth,
              ),
              _buildAttachmentOption(
                "Choose from Library",
                Icons.photo_library,
                () => _handleImageSelection(ImageSource.gallery),
                screenWidth,
              ),
              SizedBox(height: screenWidth * 0.03),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Cancel",
                  style: GoogleFonts.lato(
                    fontSize: screenWidth * 0.038,
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(height: screenWidth * 0.02),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentOption(
    String title,
    IconData icon,
    VoidCallback onTap,
    double screenWidth,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: screenWidth * 0.02),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
        leading: Icon(icon, color: primaryColor, size: screenWidth * 0.055),
        title: Text(
          title,
          style: GoogleFonts.lato(
            fontSize: screenWidth * 0.038,
            color: AppConstants.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: () {
          Navigator.pop(context);
          onTap();
        },
      ),
    );
  }

  Future<void> _handleImageSelection(ImageSource source) async {
    if (await _requestPermission(
      source == ImageSource.camera ? Permission.camera : Permission.photos,
    )) {
      final XFile? image = await _picker.pickImage(source: source);
      final File? originalFile = image != null ? File(image.path) : null; //
      if (originalFile != null) {
        //
        final File? compressedFile = await AppHelper.compressImage(
          originalFile,
        ); //
        if (compressedFile != null) {
          setState(() {
            _selectedFiles.add(compressedFile);
          });
        }
      }
    }
  }

  Future<void> _handleVideoSelection(ImageSource source) async {
    if (await _requestPermission(Permission.camera)) {
      final XFile? video = await _picker.pickVideo(source: source);
      if (video != null) {
        setState(() {
          _selectedFiles.add(File(video.path));
        });
      }
    }
  }

  Future<void> _handleDocumentSelection() async {
    if (await _requestPermission(Permission.storage)) {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.any,
      );

      if (result != null) {
        setState(() {
          _selectedFiles.addAll(
            result.paths.map((path) => File(path!)).toList(),
          );
        });
      }
    }
  }

  Future<bool> _requestPermission(Permission permission) async {
    final status = await permission.request();
    if (status.isDenied) {
      _showPermissionDialog(permission);
      return false;
    }
    return status.isGranted;
  }

  void _showPermissionDialog(Permission permission) {
    final screenWidth = MediaQuery.of(context).size.width;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          "Permission Required",
          style: GoogleFonts.lato(
            fontSize: screenWidth * 0.045,
            fontWeight: FontWeight.w600,
            color: AppConstants.black,
          ),
        ),
        content: Text(
          "This app needs ${permission.toString().split('.').last} permission to function properly.",
          style: GoogleFonts.lato(
            fontSize: screenWidth * 0.035,
            color: AppConstants.black50,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: GoogleFonts.lato(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          GradientButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            label: "Settings",
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04,
              vertical: screenWidth * 0.02,
            ),
            textStyle: GoogleFonts.lato(
              fontSize: screenWidth * 0.035,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // Utility Methods
  bool _isImageFile(String path) {
    final ext = path.toLowerCase().split('.').last;
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(ext);
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  void _openImageViewer(BuildContext context, File imageFile, int index) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageViewerScreen(
          imageFile: imageFile,
          heroTag: 'image_$index',
          fileName: imageFile.path.split('/').last,
        ),
      ),
    );

    // Handle removal from image viewer
    if (result == 'remove') {
      _removeFile(index);
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text(
      //       'Image removed successfully',
      //       style: GoogleFonts.lato(color: Colors.white),
      //     ),
      //     backgroundColor: primaryColor,
      //     duration: const Duration(seconds: 2),
      //   ),
      // );
      if (mounted) {
        AppSnackBar.showSuccess(
          context: context,
          message: 'Image removed successfully',
        );
      }
    }
  }

  void _recordVoice() {
    print('Record voice message');
    // TODO: Implement voice recording
  }

  void _submitTicket() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a location'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final societyState = ref.watch(societyStateProvider);

      final complaintData = {
        "locationId": 5, //int.parse(_selectedLocationId!),
        "priority": _isUrgent ? "high" : "low",
        "categoryId": int.parse(_selectedCategoryId!),
        "stuffId": 1,
        "complaintVisibility": _visibility.toLowerCase(),
        "complaintDescription": _descriptionController.text.trim(),
        "ticketStatus": "Open",
        "societyId": _selectedLocation?.societyId,
        "apartmentId": _selectedLocation?.apartmentId,
        // "areaId": _selectedLocation?.areaId,
      };
      print(complaintData);

      List<String> filePaths = _selectedFiles.map((file) => file.path).toList();

      final complaintService = ref.read(complaintServiceProvider);
      final response = await complaintService.createComplaint(
        complaintData,
        filePaths,
      );
      print(response);
      if (response.statusCode == 201) {
        if (mounted) {
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(
          //     content: Text(
          //       'Ticket created successfully!',
          //       style: GoogleFonts.lato(color: Colors.white),
          //     ),
          //     backgroundColor: primaryColor,
          //   ),
          // );
          AppSnackBar.showSuccess(
            context: context,
            message: 'Ticket created successfully!',
          );
          Navigator.pop(context, response.data);
        }
      } else {
        if (mounted) {
          AppSnackBar.showError(
            context: context,
            message: '${response.data['error'] ?? 'Failed to create ticket'}',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.showError(
          context: context,
          message: 'Error creating ticket: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }
}
