// Profile Screen - Responsive with Loading States
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:property_manager_app/src/presentation/providers/auth_state_provider.dart';
import 'package:redacted/redacted.dart';
import 'package:property_manager_app/src/core/constants/app_constants.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isLoading = true;
  UserProfile? userProfile;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      userProfile = UserProfile(
        name: "Gopal prasad",
        phone: "971-502663572",
        avatar: null,
        properties: [
          PropertyDetails(
            id: "Community-C01",
            name: "BNH Tower 03",
            status: "Residing as Tenant",
            passcode: "861458",
          ),
          PropertyDetails(
            id: "Community-C01",
            name: "BNH Tower 03",
            status: "Residing as Tenant",
            passcode: "861458",
          ),
          PropertyDetails(
            id: "Community-C01",
            name: "BNH Tower 03",
            status: "Residing as Tenant",
            passcode: "861458",
          ),
        ],
        appVersion: "3.4.92",
      );
      _isLoading = false;
    });
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Header
              _buildHeader(screenWidth),

              // Scrollable Content
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
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(screenWidth * 0.05),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // User Profile Card
                        _isLoading
                            ? _buildSkeletonUserCard(screenWidth)
                            : _buildUserProfileCard(screenWidth),

                        SizedBox(height: screenWidth * 0.06),

                        // My Flats Section
                        _buildSectionHeader(
                          "MY FLATS",
                          "Add/Manage Flat",
                          screenWidth,
                        ),
                        SizedBox(height: screenWidth * 0.03),

                        _isLoading
                            ? _buildSkeletonPropertyCard(screenWidth)
                            : _buildPropertyCard(screenWidth),

                        SizedBox(height: screenWidth * 0.06),

                        // Quick Actions Grid
                        _isLoading
                            ? _buildSkeletonQuickActions(screenWidth)
                            : _buildQuickActionsGrid(screenWidth),

                        SizedBox(height: screenWidth * 0.06),

                        // Documents Section
                        _buildDocumentsSection(screenWidth),

                        SizedBox(height: screenWidth * 0.06),

                        // Settings and IVR
                        _buildSettingsSection(screenWidth),

                        SizedBox(height: screenWidth * 0.06),

                        // Support Section
                        _buildSupportSection(screenWidth),

                        SizedBox(height: screenWidth * 0.06),

                        // Others Section
                        _buildOthersSection(screenWidth),

                        SizedBox(height: screenWidth * 0.06),

                        // Profile Actions
                        _buildProfileActions(screenWidth),

                        SizedBox(height: screenWidth * 0.08),

                        // App Info
                        _buildAppInfo(screenWidth),

                        SizedBox(height: screenWidth * 0.05),
                      ],
                    ),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => context.pop(),
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
          Text(
            "Profile",
            style: GoogleFonts.lato(
              color: Colors.white,
              fontSize: screenWidth * 0.05,
              fontWeight: FontWeight.w600,
            ),
          ),
          Container(
            width: screenWidth * 0.12,
            height: screenWidth * 0.12,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(screenWidth * 0.06),
            ),
            child: Icon(
              Icons.notifications_outlined,
              color: Colors.white,
              size: screenWidth * 0.06,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfileCard(double screenWidth) {
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
      child: Row(
        children: [
          Container(
            width: screenWidth * 0.15,
            height: screenWidth * 0.15,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(screenWidth * 0.075),
            ),
            child: Icon(
              Icons.person,
              color: Colors.grey.shade400,
              size: screenWidth * 0.08,
            ),
          ),
          SizedBox(width: screenWidth * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userProfile!.name,
                  style: GoogleFonts.lato(
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: screenWidth * 0.01),
                Text(
                  userProfile!.phone,
                  style: GoogleFonts.lato(
                    fontSize: screenWidth * 0.035,
                    color: AppConstants.black50,
                  ),
                ),
                SizedBox(height: screenWidth * 0.02),
                GestureDetector(
                  onTap: () => _editProfile(),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.edit_outlined,
                        color: const Color(0xFF10B981),
                        size: screenWidth * 0.04,
                      ),
                      SizedBox(width: screenWidth * 0.01),
                      Text(
                        "Edit",
                        style: GoogleFonts.lato(
                          fontSize: screenWidth * 0.035,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonUserCard(double screenWidth) {
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
      child: Row(
        children: [
          Container(
            width: screenWidth * 0.15,
            height: screenWidth * 0.15,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(screenWidth * 0.075),
            ),
          ).redacted(context: context, redact: true),
          SizedBox(width: screenWidth * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 20,
                  width: screenWidth * 0.4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ).redacted(context: context, redact: true),
                SizedBox(height: screenWidth * 0.02),
                Container(
                  height: 16,
                  width: screenWidth * 0.35,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ).redacted(context: context, redact: true),
                SizedBox(height: screenWidth * 0.02),
                Container(
                  height: 14,
                  width: screenWidth * 0.2,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ).redacted(context: context, redact: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    String? actionText,
    double screenWidth,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.lato(
            fontSize: screenWidth * 0.04,
            fontWeight: FontWeight.w600,
            color: AppConstants.black50,
          ),
        ),
        if (actionText != null)
          GestureDetector(
            onTap: () => _manageFlats(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.add_circle_outline,
                  color: const Color(0xFF10B981),
                  size: screenWidth * 0.04,
                ),
                SizedBox(width: screenWidth * 0.01),
                Text(
                  actionText,
                  style: GoogleFonts.lato(
                    fontSize: screenWidth * 0.035,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF10B981),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildPropertyCard(double screenWidth) {
    final property = userProfile!.properties.first;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.home_outlined,
                color: Colors.orange.shade600,
                size: screenWidth * 0.05,
              ),
              SizedBox(width: screenWidth * 0.02),
              Text(
                property.status,
                style: GoogleFonts.lato(
                  fontSize: screenWidth * 0.035,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange.shade600,
                ),
              ),
            ],
          ),
          SizedBox(height: screenWidth * 0.03),
          Text(
            property.id,
            style: GoogleFonts.lato(
              fontSize: screenWidth * 0.045,
              fontWeight: FontWeight.bold,
              color: AppConstants.black,
            ),
          ),
          Text(
            property.name,
            style: GoogleFonts.lato(
              fontSize: screenWidth * 0.04,
              color: AppConstants.black,
            ),
          ),
          SizedBox(height: screenWidth * 0.04),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => _shareAddress(),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.04,
                    vertical: screenWidth * 0.02,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF10B981)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Share Address",
                        style: GoogleFonts.lato(
                          fontSize: screenWidth * 0.035,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF10B981),
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.01),
                      Icon(
                        Icons.share_outlined,
                        color: const Color(0xFF10B981),
                        size: screenWidth * 0.04,
                      ),
                    ],
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "PASSCODE",
                    style: GoogleFonts.lato(
                      fontSize: screenWidth * 0.03,
                      fontWeight: FontWeight.w600,
                      color: AppConstants.black50,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.03,
                      vertical: screenWidth * 0.015,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      property.passcode,
                      style: GoogleFonts.lato(
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.black,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonPropertyCard(double screenWidth) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 16,
            width: screenWidth * 0.4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          ).redacted(context: context, redact: true),
          SizedBox(height: screenWidth * 0.03),
          Container(
            height: 20,
            width: screenWidth * 0.5,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          ).redacted(context: context, redact: true),
          SizedBox(height: screenWidth * 0.02),
          Container(
            height: 18,
            width: screenWidth * 0.45,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          ).redacted(context: context, redact: true),
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid(double screenWidth) {
    final actions = [
      QuickAction(
        title: "Add Family M...",
        icon: Icons.group_add_outlined,
        onTap: () => _addFamilyMembers(),
      ),
      QuickAction(
        title: "Add Daily Help",
        icon: Icons.cleaning_services_outlined,
        onTap: () => _addDailyHelp(),
      ),
      QuickAction(
        title: "Add Vehicles",
        icon: Icons.directions_car_outlined,
        onTap: () => _addVehicles(),
      ),
      QuickAction(
        title: "Add Pets",
        icon: Icons.pets_outlined,
        onTap: () => _addPets(),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: screenWidth * 0.03,
        mainAxisSpacing: screenWidth * 0.03,
        childAspectRatio: 2.5,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return GestureDetector(
          onTap: action.onTap,
          child: Container(
            padding: EdgeInsets.all(screenWidth * 0.03),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppConstants.purple50,
                style: BorderStyle.solid,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 5,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: screenWidth * 0.08,
                  height: screenWidth * 0.08,
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    action.icon,
                    color: AppConstants.purple50,
                    size: screenWidth * 0.04,
                  ),
                ),
                SizedBox(width: screenWidth * 0.02),
                Expanded(
                  child: Text(
                    action.title,
                    style: GoogleFonts.lato(
                      fontSize: screenWidth * 0.032,
                      fontWeight: FontWeight.w500,
                      color: AppConstants.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  width: screenWidth * 0.05,
                  height: screenWidth * 0.05,
                  decoration: BoxDecoration(
                    color: AppConstants.purple50,
                    borderRadius: BorderRadius.circular(screenWidth * 0.025),
                  ),
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: screenWidth * 0.03,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSkeletonQuickActions(double screenWidth) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: screenWidth * 0.03,
        mainAxisSpacing: screenWidth * 0.03,
        childAspectRatio: 2.5,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Container(
          padding: EdgeInsets.all(screenWidth * 0.03),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Container(
                width: screenWidth * 0.08,
                height: screenWidth * 0.08,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(6),
                ),
              ).redacted(context: context, redact: true),
              SizedBox(width: screenWidth * 0.02),
              Expanded(
                child: Container(
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ).redacted(context: context, redact: true),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDocumentsSection(double screenWidth) {
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Documents",
            style: GoogleFonts.lato(
              fontSize: screenWidth * 0.04,
              fontWeight: FontWeight.w600,
              color: AppConstants.black,
            ),
          ),
          Icon(
            Icons.folder_outlined,
            color: AppConstants.black50,
            size: screenWidth * 0.06,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(double screenWidth) {
    return _buildMenuSection(
      title: "SETTINGS AND IVR",
      items: [
        MenuItem(
          title: "Notification Settings",
          icon: Icons.notifications_outlined,
          color: AppConstants.purple50,
          onTap: () => _notificationSettings(),
        ),
        MenuItem(
          title: "Change Password",
          icon: Icons.lock_outline,
          color: AppConstants.purple50,
          onTap: () => _changePassword(),
        ),
      ],
      screenWidth: screenWidth,
    );
  }

  Widget _buildSupportSection(double screenWidth) {
    return _buildMenuSection(
      title: "SUPPORT",
      items: [
        MenuItem(
          title: "Support and Help",
          icon: Icons.help_outline,
          color: AppConstants.purple50,
          onTap: () => _supportAndHelp(),
        ),
        MenuItem(
          title: "Troubleshooting App",
          icon: Icons.build_outlined,
          color: AppConstants.purple50,
          onTap: () => _troubleshooting(),
        ),
      ],
      screenWidth: screenWidth,
    );
  }

  Widget _buildOthersSection(double screenWidth) {
    return _buildMenuSection(
      title: "OTHERS",
      items: [
        MenuItem(
          title: "Share App",
          icon: Icons.share_outlined,
          color: AppConstants.purple50,
          onTap: () => _shareApp(),
        ),
        MenuItem(
          title: "App Feedback",
          icon: Icons.star_outline,
          color: AppConstants.purple50,
          onTap: () => _appFeedback(),
        ),
        MenuItem(
          title: "App Policies",
          icon: Icons.description_outlined,
          color: AppConstants.purple50,
          onTap: () => _appPolicies(),
        ),
        MenuItem(
          title: "Training Feedback",
          icon: Icons.quiz_outlined,
          color: AppConstants.purple50,
          onTap: () => _trainingFeedback(),
        ),
      ],
      screenWidth: screenWidth,
    );
  }

  Widget _buildProfileActions(double screenWidth) {
    return _buildMenuSection(
      title: null,
      items: [
        MenuItem(
          title: "Switch Profile",
          icon: Icons.switch_account_outlined,
          color: AppConstants.purple50,
          onTap: () => _switchProfile(),
        ),
        MenuItem(
          title: "Logout",
          icon: Icons.logout_outlined,
          color: AppConstants.purple50,
          onTap: () => _logout(),
        ),
      ],
      screenWidth: screenWidth,
    );
  }

  Widget _buildMenuSection({
    required String? title,
    required List<MenuItem> items,
    required double screenWidth,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(
            title,
            style: GoogleFonts.lato(
              fontSize: screenWidth * 0.04,
              fontWeight: FontWeight.w600,
              color: AppConstants.black50,
            ),
          ),
          SizedBox(height: screenWidth * 0.03),
        ],
        Container(
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
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isLast = index == items.length - 1;

              return Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.05,
                      vertical: screenWidth * 0.01,
                    ),
                    leading: Container(
                      width: screenWidth * 0.1,
                      height: screenWidth * 0.1,
                      decoration: BoxDecoration(
                        color: item.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        item.icon,
                        color: item.color,
                        size: screenWidth * 0.05,
                      ),
                    ),
                    title: Text(
                      item.title,
                      style: GoogleFonts.lato(
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.w500,
                        color: AppConstants.black,
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      color: AppConstants.black50,
                      size: screenWidth * 0.04,
                    ),
                    onTap: item.onTap,
                  ),
                  if (!isLast)
                    Divider(
                      height: 1,
                      color: Colors.grey.shade200,
                      indent: screenWidth * 0.15,
                      endIndent: screenWidth * 0.05,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildAppInfo(double screenWidth) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text: "Crafted in Bengaluru, India with ",
                  style: GoogleFonts.lato(
                    fontSize: screenWidth * 0.035,
                    color: AppConstants.purple50,
                  ),
                ),
                TextSpan(
                  text: "❤️",
                  style: GoogleFonts.lato(fontSize: screenWidth * 0.04),
                ),
              ],
            ),
          ),
          SizedBox(height: screenWidth * 0.02),
          Text(
            "Version ${userProfile?.appVersion ?? '3.4.92'}",
            style: GoogleFonts.lato(
              fontSize: screenWidth * 0.035,
              color: AppConstants.black50,
            ),
          ),
        ],
      ),
    );
  }

  // Action methods
  void _editProfile() => print('Edit Profile');
  void _manageFlats() => print('Manage Flats');
  void _shareAddress() => print('Share Address');
  void _addFamilyMembers() => print('Add Family Members');
  void _addDailyHelp() => print('Add Daily Help');
  void _addVehicles() => print('Add Vehicles');
  void _addPets() => print('Add Pets');
  void _notificationSettings() => print('Notification Settings');
  void _changePassword() => print('Change Password');
  void _supportAndHelp() => print('Support and Help');
  void _troubleshooting() => print('Troubleshooting');
  void _shareApp() => print('Share App');
  void _appFeedback() => print('App Feedback');
  void _appPolicies() => print('App Policies');
  void _trainingFeedback() => print('Training Feedback');
  void _switchProfile() => print('Switch Profile');
  void _logout() async => await ref.read(authStateProvider.notifier).logout();
}

// Data Models
class UserProfile {
  final String name;
  final String phone;
  final String? avatar;
  final List<PropertyDetails> properties;
  final String appVersion;

  UserProfile({
    required this.name,
    required this.phone,
    this.avatar,
    required this.properties,
    required this.appVersion,
  });
}

class PropertyDetails {
  final String id;
  final String name;
  final String status;
  final String passcode;

  PropertyDetails({
    required this.id,
    required this.name,
    required this.status,
    required this.passcode,
  });
}

class QuickAction {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  QuickAction({required this.title, required this.icon, required this.onTap});
}

class MenuItem {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  MenuItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}
