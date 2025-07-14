// lib/src/presentation/screens/profile/edit_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:property_manager_app/src/presentation/providers/auth_state_provider.dart';
import 'package:property_manager_app/src/data/models/user_profile_response_model.dart';
import 'package:property_manager_app/src/core/constants/app_constants.dart';

// Data models for edit profile
class EditProfileData {
  String name;
  String bio;
  String email;
  String age;
  String location;
  String occupation;
  List<String> interests;
  String? avatarPath;

  EditProfileData({
    required this.name,
    required this.bio,
    required this.email,
    required this.age,
    required this.location,
    required this.occupation,
    required this.interests,
    this.avatarPath,
  });

  factory EditProfileData.fromUserProfile(UserProfileDataModel profile) {
    return EditProfileData(
      name: profile.name,
      bio: '', // Add bio field to your API response if needed
      email: '', // Add email field to your API response if needed
      age: '',
      location: '',
      occupation: '',
      interests: [],
      avatarPath: profile.avatar,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'bio': bio,
      'email': email,
      'age': age,
      'location': location,
      'occupation': occupation,
      'interests': interests,
      'avatar': avatarPath,
    };
  }
}

// Predefined interests list
class InterestOption {
  final String name;
  final IconData icon;

  const InterestOption(this.name, this.icon);
}

const List<InterestOption> availableInterests = [
  InterestOption('Painting', Icons.brush),
  InterestOption('Cooking', Icons.restaurant),
  InterestOption('Cricket', Icons.sports_cricket),
  InterestOption('Cycling', Icons.directions_bike),
  InterestOption('Reading', Icons.menu_book),
  InterestOption('Music', Icons.music_note),
  InterestOption('Photography', Icons.camera_alt),
  InterestOption('Gaming', Icons.sports_esports),
  InterestOption('Traveling', Icons.flight),
  InterestOption('Fitness', Icons.fitness_center),
  InterestOption('Movies', Icons.movie),
  InterestOption('Dancing', Icons.music_video),
];

class EditProfileScreen extends ConsumerStatefulWidget {
  final UserProfileDataModel? initialProfile;

  const EditProfileScreen({
    super.key,
    this.initialProfile,
  });

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late EditProfileData _profileData;
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _emailController;
  late TextEditingController _ageController;
  late TextEditingController _locationController;
  late TextEditingController _occupationController;

  // State variables
  bool _isLoading = false;
  File? _selectedImage;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    if (widget.initialProfile != null) {
      _profileData = EditProfileData.fromUserProfile(widget.initialProfile!);
    } else {
      _profileData = EditProfileData(
        name: '',
        bio: '',
        email: '',
        age: '',
        location: '',
        occupation: '',
        interests: [],
      );
    }

    // Initialize controllers
    _nameController = TextEditingController(text: _profileData.name);
    _bioController = TextEditingController(text: _profileData.bio);
    _emailController = TextEditingController(text: _profileData.email);
    _ageController = TextEditingController(text: _profileData.age);
    _locationController = TextEditingController(text: _profileData.location);
    _occupationController = TextEditingController(text: _profileData.occupation);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _locationController.dispose();
    _occupationController.dispose();
    super.dispose();
  }

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

              // Content
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
                  child: _isLoading
                      ? _buildLoadingIndicator()
                      : _buildEditForm(screenWidth),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => _showDiscardDialog(),
            child: Container(
              width: screenWidth * 0.12,
              height: screenWidth * 0.12,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(screenWidth * 0.06),
              ),
              child: Icon(
                Icons.close,
                color: Colors.white,
                size: screenWidth * 0.05,
              ),
            ),
          ),
          Text(
            "Edit Profile",
            style: GoogleFonts.lato(
              color: Colors.white,
              fontSize: screenWidth * 0.05,
              fontWeight: FontWeight.w600,
            ),
          ),
          GestureDetector(
            onTap: _isLoading ? null : _saveProfile,
            child: Container(
              width: screenWidth * 0.12,
              height: screenWidth * 0.12,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(screenWidth * 0.06),
              ),
              child: Icon(
                Icons.check,
                color: Colors.white,
                size: screenWidth * 0.05,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppConstants.purple50),
      ),
    );
  }

  Widget _buildEditForm(double screenWidth) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Photo Section
            _buildProfilePhotoSection(screenWidth),
            SizedBox(height: screenWidth * 0.06),

            // Name Section
            _buildNameSection(screenWidth),
            SizedBox(height: screenWidth * 0.05),

            // Bio Section
            _buildBioSection(screenWidth),
            SizedBox(height: screenWidth * 0.05),

            // Personal Details Section
            _buildPersonalDetailsSection(screenWidth),
            SizedBox(height: screenWidth * 0.05),

            // Interests Section
            _buildInterestsSection(screenWidth),
            SizedBox(height: screenWidth * 0.08),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePhotoSection(double screenWidth) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.05),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Profile Photo',
            style: GoogleFonts.lato(
              fontSize: screenWidth * 0.045,
              fontWeight: FontWeight.w600,
              color: AppConstants.black,
            ),
          ),
          SizedBox(height: screenWidth * 0.04),
          Stack(
            children: [
              Container(
                width: screenWidth * 0.3,
                height: screenWidth * 0.3,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(screenWidth * 0.15),
                  border: Border.all(
                    color: AppConstants.purple50.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: _buildProfileImage(screenWidth),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _showPhotoOptions,
                  child: Container(
                    width: screenWidth * 0.1,
                    height: screenWidth * 0.1,
                    decoration: BoxDecoration(
                      color: AppConstants.purple50,
                      borderRadius: BorderRadius.circular(screenWidth * 0.05),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: screenWidth * 0.05,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage(double screenWidth) {
    if (_selectedImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(screenWidth * 0.15),
        child: Image.file(
          _selectedImage!,
          fit: BoxFit.cover,
          width: screenWidth * 0.3,
          height: screenWidth * 0.3,
        ),
      );
    } else if (_profileData.avatarPath != null && _profileData.avatarPath!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(screenWidth * 0.15),
        child: Image.network(
          _profileData.avatarPath!,
          fit: BoxFit.cover,
          width: screenWidth * 0.3,
          height: screenWidth * 0.3,
          errorBuilder: (context, error, stackTrace) => Icon(
            Icons.person,
            color: Colors.grey.shade400,
            size: screenWidth * 0.15,
          ),
        ),
      );
    } else {
      return Icon(
        Icons.person,
        color: Colors.grey.shade400,
        size: screenWidth * 0.15,
      );
    }
  }

  Widget _buildNameSection(double screenWidth) {
    return _buildEditCard(
      title: 'Name',
      screenWidth: screenWidth,
      child: TextFormField(
        controller: _nameController,
        style: GoogleFonts.lato(
          fontSize: screenWidth * 0.04,
          color: AppConstants.black,
        ),
        decoration: InputDecoration(
          hintText: 'Enter your name',
          hintStyle: GoogleFonts.lato(
            color: AppConstants.black50,
            fontSize: screenWidth * 0.04,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppConstants.purple50, width: 2),
          ),
          contentPadding: EdgeInsets.all(screenWidth * 0.04),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Name is required';
          }
          return null;
        },
        onChanged: (value) => _profileData.name = value.trim(),
      ),
    );
  }

  Widget _buildBioSection(double screenWidth) {
    return _buildEditCard(
      title: 'Bio',
      screenWidth: screenWidth,
      child: Column(
        children: [
          TextFormField(
            controller: _bioController,
            maxLines: 4,
            maxLength: 150,
            style: GoogleFonts.lato(
              fontSize: screenWidth * 0.04,
              color: AppConstants.black,
            ),
            decoration: InputDecoration(
              hintText: 'Write something fun',
              hintStyle: GoogleFonts.lato(
                color: AppConstants.black50,
                fontSize: screenWidth * 0.04,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppConstants.purple50, width: 2),
              ),
              contentPadding: EdgeInsets.all(screenWidth * 0.04),
              counterStyle: GoogleFonts.lato(
                color: AppConstants.black50,
                fontSize: screenWidth * 0.032,
              ),
            ),
            onChanged: (value) => _profileData.bio = value,
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalDetailsSection(double screenWidth) {
    return _buildEditCard(
      title: 'Personal Details',
      screenWidth: screenWidth,
      child: Column(
        children: [
          _buildTextField(
            controller: _emailController,
            label: 'Email',
            hint: 'Enter your email',
            keyboardType: TextInputType.emailAddress,
            screenWidth: screenWidth,
            onChanged: (value) => _profileData.email = value,
            validator: (value) {
              if (value != null && value.isNotEmpty && !value.contains('@')) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          SizedBox(height: screenWidth * 0.04),
          _buildTextField(
            controller: _ageController,
            label: 'Age',
            hint: 'Enter your age',
            keyboardType: TextInputType.number,
            screenWidth: screenWidth,
            onChanged: (value) => _profileData.age = value,
          ),
          SizedBox(height: screenWidth * 0.04),
          _buildTextField(
            controller: _locationController,
            label: 'Location',
            hint: 'Enter your location',
            screenWidth: screenWidth,
            onChanged: (value) => _profileData.location = value,
          ),
          SizedBox(height: screenWidth * 0.04),
          _buildTextField(
            controller: _occupationController,
            label: 'Occupation',
            hint: 'Enter your occupation',
            screenWidth: screenWidth,
            onChanged: (value) => _profileData.occupation = value,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required double screenWidth,
    required Function(String) onChanged,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.lato(
            fontSize: screenWidth * 0.035,
            fontWeight: FontWeight.w500,
            color: AppConstants.black,
          ),
        ),
        SizedBox(height: screenWidth * 0.02),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: GoogleFonts.lato(
            fontSize: screenWidth * 0.04,
            color: AppConstants.black,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.lato(
              color: AppConstants.black50,
              fontSize: screenWidth * 0.04,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppConstants.purple50, width: 2),
            ),
            contentPadding: EdgeInsets.all(screenWidth * 0.04),
          ),
          validator: validator,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildInterestsSection(double screenWidth) {
    return _buildEditCard(
      title: 'Interests',
      screenWidth: screenWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select your interests',
            style: GoogleFonts.lato(
              fontSize: screenWidth * 0.035,
              color: AppConstants.black50,
            ),
          ),
          SizedBox(height: screenWidth * 0.03),
          Wrap(
            spacing: screenWidth * 0.02,
            runSpacing: screenWidth * 0.02,
            children: availableInterests.map((interest) {
              final isSelected = _profileData.interests.contains(interest.name);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _profileData.interests.remove(interest.name);
                    } else {
                      _profileData.interests.add(interest.name);
                    }
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.04,
                    vertical: screenWidth * 0.025,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppConstants.purple50 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? AppConstants.purple50 : Colors.grey.shade300,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        interest.icon,
                        size: screenWidth * 0.04,
                        color: isSelected ? Colors.white : AppConstants.black50,
                      ),
                      SizedBox(width: screenWidth * 0.02),
                      Text(
                        interest.name,
                        style: GoogleFonts.lato(
                          fontSize: screenWidth * 0.035,
                          color: isSelected ? Colors.white : AppConstants.black,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEditCard({
    required String title,
    required Widget child,
    required double screenWidth,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenWidth * 0.05),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.lato(
              fontSize: screenWidth * 0.045,
              fontWeight: FontWeight.w600,
              color: AppConstants.black,
            ),
          ),
          SizedBox(height: screenWidth * 0.03),
          child,
        ],
      ),
    );
  }

  void _showPhotoOptions() {
    final screenWidth = MediaQuery.of(context).size.width;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(screenWidth * 0.05),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Add Photo!',
                style: GoogleFonts.lato(
                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.w600,
                  color: AppConstants.black,
                ),
              ),
              SizedBox(height: screenWidth * 0.05),
              _buildPhotoOption(
                'Take Photo',
                Icons.camera_alt,
                () => _pickImage(ImageSource.camera),
                screenWidth,
              ),
              _buildPhotoOption(
                'Choose from Gallery',
                Icons.photo_library,
                () => _pickImage(ImageSource.gallery),
                screenWidth,
              ),
              if (_selectedImage != null || (_profileData.avatarPath?.isNotEmpty ?? false))
                _buildPhotoOption(
                  'Remove Photo',
                  Icons.delete,
                  _removePhoto,
                  screenWidth,
                  isDestructive: true,
                ),
              _buildPhotoOption(
                'Cancel',
                Icons.close,
                () => Navigator.pop(context),
                screenWidth,
                isCancel: true,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPhotoOption(
    String title,
    IconData icon,
    VoidCallback onTap,
    double screenWidth, {
    bool isDestructive = false,
    bool isCancel = false,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: screenWidth * 0.04),
        margin: EdgeInsets.only(bottom: screenWidth * 0.02),
        decoration: BoxDecoration(
          color: isDestructive
              ? Colors.red.shade50
              : isCancel
                  ? Colors.grey.shade100
                  : AppConstants.purple50.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            SizedBox(width: screenWidth * 0.04),
            Icon(
              icon,
              color: isDestructive
                  ? Colors.red.shade600
                  : isCancel
                      ? AppConstants.black50
                      : AppConstants.purple50,
              size: screenWidth * 0.06,
            ),
            SizedBox(width: screenWidth * 0.04),
            Text(
              title,
              style: GoogleFonts.lato(
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.w500,
                color: isDestructive
                    ? Colors.red.shade600
                    : isCancel
                        ? AppConstants.black50
                        : AppConstants.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 70,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      _showSnackBar('Failed to pick image. Please try again.', Colors.red);
    }
  }

  void _removePhoto() {
    setState(() {
      _selectedImage = null;
      _profileData.avatarPath = null;
    });
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Update profile data with current form values
        _profileData.name = _nameController.text.trim();
        _profileData.bio = _bioController.text.trim();
        _profileData.email = _emailController.text.trim();
        _profileData.age = _ageController.text.trim();
        _profileData.location = _locationController.text.trim();
        _profileData.occupation = _occupationController.text.trim();

        // Here you would call your edit profile API
        // await ref.read(editProfileUseCaseProvider).call(_profileData, _selectedImage);
        
        // Simulate API call
        await Future.delayed(const Duration(seconds: 2));
        
        _showSnackBar('Profile updated successfully!', Colors.green);
        
        // Navigate back
        if (mounted) {
          context.pop();
        }
      } catch (e) {
        _showSnackBar('Failed to update profile. Please try again.', Colors.red);
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _showDiscardDialog() async {
    final shouldDiscard = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        final screenWidth = MediaQuery.of(context).size.width;
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange.shade600,
                size: screenWidth * 0.06,
              ),
              SizedBox(width: screenWidth * 0.02),
              Text(
                'Discard Changes',
                style: GoogleFonts.lato(
                  fontSize: screenWidth * 0.045,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to discard your changes?',
            style: GoogleFonts.lato(
              fontSize: screenWidth * 0.04,
              color: AppConstants.black50,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Keep Editing',
                style: GoogleFonts.lato(
                  fontSize: screenWidth * 0.04,
                  fontWeight: FontWeight.w600,
                  color: AppConstants.purple50,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade600,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Discard',
                style: GoogleFonts.lato(
                  fontSize: screenWidth * 0.04,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDiscard == true && mounted) {
      context.pop();
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: GoogleFonts.lato(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: backgroundColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
        ),
      );
    }
  }
}

// Add these dependencies to pubspec.yaml:
/*
dependencies:
  image_picker: ^1.0.4
*/

// API Integration Structure
/*
// lib/src/domain/usecases/edit_profile_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../../core/errors/failures.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../repositories/auth_repository.dart';

class EditProfileUseCase {
  final AuthRepository repository;

  EditProfileUseCase(this.repository);

  Future<Either<Failure, void>> call(
    EditProfileData profileData,
    File? imageFile,
  ) {
    return repository.editProfile(profileData, imageFile);
  }
}

final editProfileUseCaseProvider = Provider<EditProfileUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return EditProfileUseCase(repository);
});

// Add to AuthRemoteDataSource:
abstract class AuthRemoteDataSource {
  // ... existing methods
  Future<void> editProfile(EditProfileData profileData, File? imageFile);
}

// Implementation in AuthRemoteDataSourceImpl:
@override
Future<void> editProfile(EditProfileData profileData, File? imageFile) async {
  try {
    // Your edit profile endpoint here
    final formData = FormData.fromMap(profileData.toJson());
    
    if (imageFile != null) {
      formData.files.add(MapEntry(
        'avatar',
        await MultipartFile.fromFile(imageFile.path),
      ));
    }

    final response = await dio.put(
      '/user/profile', // Your edit profile endpoint
      data: formData,
    );

    if (response.statusCode == 200) {
      logger.i('✅ Profile updated successfully');
    } else {
      throw ServerException('Failed to update profile');
    }
  } on DioException catch (e) {
    // Handle errors
    throw ServerException(e.response?.data['message'] ?? 'Update failed');
  }
}
*/