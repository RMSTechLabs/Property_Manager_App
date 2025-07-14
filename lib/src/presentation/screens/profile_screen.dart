// Profile Screen - Responsive with Loading States
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:property_manager_app/src/core/utils/app_snackbar.dart';
import 'package:property_manager_app/src/data/models/user_profile_response_model.dart';
import 'package:property_manager_app/src/presentation/providers/auth_state_provider.dart';
import 'package:property_manager_app/src/presentation/providers/user_profile_provider.dart';
import 'package:property_manager_app/src/presentation/screens/edit_profile_screen.dart';
import 'package:redacted/redacted.dart';
import 'package:property_manager_app/src/core/constants/app_constants.dart';
import 'package:share_plus/share_plus.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  String? userId;

  @override
  void initState() {
    super.initState();
    _getUserId();
  }

  void _getUserId() {
    // Get userId from auth state or stored user data
    final authState = ref.read(authStateProvider);
    if (authState.user != null) {
      userId = authState.user!.id;
    }
    // You might also get it from secure storage if needed
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    if (userId == null) {
      return const Scaffold(body: Center(child: Text('User ID not found')));
    }

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
                  child: Consumer(
                    builder: (context, ref, child) {
                      final userProfileAsync = ref.watch(
                        userProfileProvider(userId!),
                      );

                      return userProfileAsync.when(
                        loading: () => _buildLoadingContent(screenWidth),
                        error: (error, stack) =>
                            _buildErrorContent(error.toString(), screenWidth),
                        data: (userProfile) =>
                            _buildSuccessContent(userProfile, screenWidth),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingContent(double screenWidth) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(screenWidth * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Profile Card Skeleton
          _buildSkeletonUserCard(screenWidth),
          SizedBox(height: screenWidth * 0.06),

          // Section Header Skeleton
          Container(
            height: 16,
            width: screenWidth * 0.3,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          ).redacted(context: context, redact: true),
          SizedBox(height: screenWidth * 0.03),

          // Horizontal Cards Skeleton
          _buildSkeletonHorizontalCards(screenWidth),
          SizedBox(height: screenWidth * 0.06),

          // Other sections...
          _buildSettingsSection(screenWidth),
          SizedBox(height: screenWidth * 0.06),
          _buildSupportSection(screenWidth),
          SizedBox(height: screenWidth * 0.06),
          _buildOthersSection(screenWidth),
          SizedBox(height: screenWidth * 0.06),
          _buildProfileActions(screenWidth),
        ],
      ),
    );
  }

  Widget _buildErrorContent(String error, double screenWidth) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: screenWidth * 0.2,
              color: Colors.red.shade400,
            ),
            SizedBox(height: screenWidth * 0.04),
            Text(
              'Failed to load profile',
              style: GoogleFonts.lato(
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.w600,
                color: AppConstants.black,
              ),
            ),
            SizedBox(height: screenWidth * 0.02),
            Text(
              error,
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: screenWidth * 0.035,
                color: AppConstants.black50,
              ),
            ),
            SizedBox(height: screenWidth * 0.06),
            ElevatedButton(
              onPressed: () {
                // Refresh the provider
                ref.invalidate(userProfileProvider(userId!));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.purple50,
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.08,
                  vertical: screenWidth * 0.04,
                ),
              ),
              child: Text(
                'Retry',
                style: GoogleFonts.lato(
                  fontSize: screenWidth * 0.04,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessContent(
    UserProfileDataModel userProfile,
    double screenWidth,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(screenWidth * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Profile Card
          _buildUserProfileCard(userProfile, screenWidth),
          SizedBox(height: screenWidth * 0.06),

          // My Flats Section Header
          // _buildSectionHeader(
          //   "MY FLATS",
          //   "Add/Manage Flat",
          //   screenWidth,
          // ),
          _buildSectionHeader("MY FLATS", null, screenWidth),
          SizedBox(height: screenWidth * 0.03),

          // Horizontal Scrollable Cards
          _buildHorizontalScrollableCards(userProfile.properties, screenWidth),
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
          _buildAppInfo(userProfile.appVersion, screenWidth),
          SizedBox(height: screenWidth * 0.05),
        ],
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

  Widget _buildUserProfileCard(
    UserProfileDataModel userProfile,
    double screenWidth,
  ) {
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
            child: userProfile.avatar != null && userProfile.avatar!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(screenWidth * 0.075),
                    child: Image.network(
                      userProfile.avatar!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.person,
                        color: Colors.grey.shade400,
                        size: screenWidth * 0.08,
                      ),
                    ),
                  )
                : Icon(
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
                  userProfile.name,
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
                  userProfile.phone,
                  style: GoogleFonts.lato(
                    fontSize: screenWidth * 0.035,
                    color: AppConstants.black50,
                  ),
                ),
                SizedBox(height: screenWidth * 0.02),
                GestureDetector(
                  onTap: () => _editProfile(userProfile),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.edit_outlined,
                        color: AppConstants.purple50,
                        size: screenWidth * 0.04,
                      ),
                      SizedBox(width: screenWidth * 0.01),
                      Text(
                        "Edit",
                        style: GoogleFonts.lato(
                          fontSize: screenWidth * 0.035,
                          fontWeight: FontWeight.w600,
                          color: AppConstants.purple50,
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

  Widget _buildHorizontalScrollableCards(
    List<PropertyDetailsModel> properties,
    double screenWidth,
  ) {
    if (properties.isEmpty) {
      return Container(
        height: screenWidth * 0.6,
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.home_outlined,
                size: screenWidth * 0.15,
                color: Colors.grey.shade400,
              ),
              SizedBox(height: screenWidth * 0.04),
              Text(
                'No Properties Found',
                style: GoogleFonts.lato(
                  fontSize: screenWidth * 0.045,
                  fontWeight: FontWeight.w600,
                  color: AppConstants.black,
                ),
              ),
              SizedBox(height: screenWidth * 0.02),
              Text(
                'Add your first property to get started',
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                  fontSize: screenWidth * 0.035,
                  color: AppConstants.black50,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      // height: screenWidth * 1.2,
      height: screenWidth * 0.5,
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.9),
        itemCount: properties.length,
        itemBuilder: (context, index) {
          return _buildPropertyCard(properties[index], screenWidth);
        },
      ),
    );
  }

  Future<bool?> _showLogoutDialog() async {
    return showDialog<bool>(
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
                Icons.logout,
                color: Colors.red.shade600,
                size: screenWidth * 0.06,
              ),
              SizedBox(width: screenWidth * 0.02),
              Text(
                'Logout',
                style: GoogleFonts.lato(
                  fontSize: screenWidth * 0.045,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to logout from your account?',
            style: GoogleFonts.lato(
              fontSize: screenWidth * 0.04,
              color: AppConstants.black50,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: GoogleFonts.lato(
                  fontSize: screenWidth * 0.04,
                  fontWeight: FontWeight.w600,
                  color: AppConstants.black50,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Logout',
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
  }

  Widget _buildPropertyCard(PropertyDetailsModel property, double screenWidth) {
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

    return Container(
      margin: EdgeInsets.only(right: screenWidth * 0.02),
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
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Property Header
            Row(
              children: [
                Icon(
                  Icons.home_outlined,
                  color: Colors.orange.shade600,
                  size: screenWidth * 0.05,
                ),
                SizedBox(width: screenWidth * 0.02),
                Expanded(
                  child: Text(
                    property.status,
                    style: GoogleFonts.lato(
                      fontSize: screenWidth * 0.035,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange.shade600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: screenWidth * 0.03),

            // Property Details
            Text(
              property.societyName,
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

            // Share Address and Passcode
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => _shareAddress(property),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.04,
                      vertical: screenWidth * 0.02,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppConstants.purple50),
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
                            color: AppConstants.purple50,
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.01),
                        Icon(
                          Icons.share_outlined,
                          color: AppConstants.purple50,
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

            // SizedBox(height: screenWidth * 0.06),

            // Quick Actions Section
            // Row(
            //   children: [
            //     Icon(
            //       Icons.dashboard_outlined,
            //       color: AppConstants.purple50,
            //       size: screenWidth * 0.045,
            //     ),
            //     SizedBox(width: screenWidth * 0.02),
            //     Text(
            //       "Quick Actions",
            //       style: GoogleFonts.lato(
            //         fontSize: screenWidth * 0.04,
            //         fontWeight: FontWeight.w600,
            //         color: AppConstants.black,
            //       ),
            //     ),
            //   ],
            // ),
            // SizedBox(height: screenWidth * 0.03),

            // Quick Actions Grid
            // GridView.builder(
            //   shrinkWrap: true,
            //   physics: const NeverScrollableScrollPhysics(),
            //   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            //     crossAxisCount: 2,
            //     crossAxisSpacing: screenWidth * 0.03,
            //     mainAxisSpacing: screenWidth * 0.03,
            //     childAspectRatio: 2.5,
            //   ),
            //   itemCount: actions.length,
            //   itemBuilder: (context, index) {
            //     final action = actions[index];
            //     return GestureDetector(
            //       onTap: action.onTap,
            //       child: Container(
            //         padding: EdgeInsets.all(screenWidth * 0.025),
            //         decoration: BoxDecoration(
            //           color: Colors.grey.shade50,
            //           borderRadius: BorderRadius.circular(12),
            //           border: Border.all(
            //             color: AppConstants.purple50.withOpacity(0.3),
            //           ),
            //         ),
            //         child: Row(
            //           children: [
            //             Container(
            //               width: screenWidth * 0.07,
            //               height: screenWidth * 0.07,
            //               decoration: BoxDecoration(
            //                 color: Colors.purple.shade50,
            //                 borderRadius: BorderRadius.circular(6),
            //               ),
            //               child: Icon(
            //                 action.icon,
            //                 color: AppConstants.purple50,
            //                 size: screenWidth * 0.035,
            //               ),
            //             ),
            //             SizedBox(width: screenWidth * 0.02),
            //             Expanded(
            //               child: Text(
            //                 action.title,
            //                 style: GoogleFonts.lato(
            //                   fontSize: screenWidth * 0.03,
            //                   fontWeight: FontWeight.w500,
            //                   color: AppConstants.black,
            //                 ),
            //                 maxLines: 1,
            //                 overflow: TextOverflow.ellipsis,
            //               ),
            //             ),
            //             Container(
            //               width: screenWidth * 0.045,
            //               height: screenWidth * 0.045,
            //               decoration: BoxDecoration(
            //                 color: AppConstants.purple50,
            //                 borderRadius: BorderRadius.circular(screenWidth * 0.0225),
            //               ),
            //               child: Icon(
            //                 Icons.add,
            //                 color: Colors.white,
            //                 size: screenWidth * 0.025,
            //               ),
            //             ),
            //           ],
            //         ),
            //       ),
            //     );
            //   },
            // ),

            // SizedBox(height: screenWidth * 0.06),

            // Documents Section
            // Container(
            //   padding: EdgeInsets.all(screenWidth * 0.04),
            //   decoration: BoxDecoration(
            //     color: Colors.blue.shade50,
            //     borderRadius: BorderRadius.circular(12),
            //     border: Border.all(
            //       color: Colors.blue.shade100,
            //     ),
            //   ),
            //   child: Row(
            //     children: [
            //       Container(
            //         width: screenWidth * 0.12,
            //         height: screenWidth * 0.12,
            //         decoration: BoxDecoration(
            //           color: Colors.blue.shade100,
            //           borderRadius: BorderRadius.circular(8),
            //         ),
            //         child: Icon(
            //           Icons.folder_outlined,
            //           color: Colors.blue.shade600,
            //           size: screenWidth * 0.06,
            //         ),
            //       ),
            //       SizedBox(width: screenWidth * 0.03),
            //       Expanded(
            //         child: Column(
            //           crossAxisAlignment: CrossAxisAlignment.start,
            //           children: [
            //             Text(
            //               "Documents",
            //               style: GoogleFonts.lato(
            //                 fontSize: screenWidth * 0.04,
            //                 fontWeight: FontWeight.w600,
            //                 color: AppConstants.black,
            //               ),
            //             ),
            //             Text(
            //               "View and manage documents",
            //               style: GoogleFonts.lato(
            //                 fontSize: screenWidth * 0.032,
            //                 color: AppConstants.black50,
            //               ),
            //             ),
            //           ],
            //         ),
            //       ),
            //       Icon(
            //         Icons.arrow_forward_ios,
            //         color: Colors.blue.shade600,
            //         size: screenWidth * 0.04,
            //       ),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  // Include all the skeleton loading methods from previous implementation
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

  Widget _buildSkeletonHorizontalCards(double screenWidth) {
    return SizedBox(
      height: screenWidth * 1.2,
      child: PageView(
        controller: PageController(viewportFraction: 0.9),
        children: [
          _buildSkeletonPropertyCard(screenWidth),
          _buildSkeletonPropertyCard(screenWidth),
          _buildSkeletonPropertyCard(screenWidth),
        ],
      ),
    );
  }

  Widget _buildSkeletonPropertyCard(double screenWidth) {
    return Container(
      margin: EdgeInsets.only(right: screenWidth * 0.03),
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
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Property Header Skeleton
            Container(
              height: 16,
              width: screenWidth * 0.4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ).redacted(context: context, redact: true),
            SizedBox(height: screenWidth * 0.03),

            // Property Details Skeleton
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
            SizedBox(height: screenWidth * 0.04),

            // Share Address and Passcode Skeleton
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 30,
                  width: screenWidth * 0.3,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ).redacted(context: context, redact: true),
                Container(
                  height: 40,
                  width: screenWidth * 0.2,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ).redacted(context: context, redact: true),
              ],
            ),

            SizedBox(height: screenWidth * 0.06),

            // Quick Actions Header Skeleton
            Container(
              height: 16,
              width: screenWidth * 0.35,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ).redacted(context: context, redact: true),
            SizedBox(height: screenWidth * 0.03),

            // Quick Actions Grid Skeleton
            GridView.builder(
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
                  padding: EdgeInsets.all(screenWidth * 0.025),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: screenWidth * 0.07,
                        height: screenWidth * 0.07,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ).redacted(context: context, redact: true),
                      SizedBox(width: screenWidth * 0.02),
                      Expanded(
                        child: Container(
                          height: 12,
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
            ),

            SizedBox(height: screenWidth * 0.06),

            // Documents Section Skeleton
            Container(
              padding: EdgeInsets.all(screenWidth * 0.04),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Container(
                    width: screenWidth * 0.12,
                    height: screenWidth * 0.12,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ).redacted(context: context, redact: true),
                  SizedBox(width: screenWidth * 0.03),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 16,
                          width: screenWidth * 0.25,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ).redacted(context: context, redact: true),
                        SizedBox(height: screenWidth * 0.01),
                        Container(
                          height: 12,
                          width: screenWidth * 0.4,
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
            ),
          ],
        ),
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
                  color: AppConstants.purple50,
                  size: screenWidth * 0.04,
                ),
                SizedBox(width: screenWidth * 0.01),
                Text(
                  actionText,
                  style: GoogleFonts.lato(
                    fontSize: screenWidth * 0.035,
                    fontWeight: FontWeight.w600,
                    color: AppConstants.purple50,
                  ),
                ),
              ],
            ),
          ),
      ],
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

  Widget _buildAppInfo(String appVersion, double screenWidth) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text: "Crafted in Kolkata, India with ",
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
            "Version $appVersion",
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
  void _editProfile(UserProfileDataModel userProfile) => {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(
          initialProfile: userProfile, // Pass current profile data
        ),
      ),
    ),
  };
  void _manageFlats() => print('Manage Flats');
  Future<void> _shareAddress(PropertyDetailsModel property) async {
    try {
      final userProfile = await ref.read(userProfileProvider(userId!).future);

      final addressText =
          '''
            🏠 Property Address

            📍 ${property.societyName}
            🏢 ${property.name}
            👤 Resident: ${userProfile.name}
            📱 Contact: ${userProfile.phone}
            🎯 Status: ${property.status}
            🔐 Passcode: ${property.passcode}

            ---
            Shared via Property Manager App
          '''
              .trim();

      await Share.share(
        addressText,
        subject: 'Property Address - ${property.societyName}',
      );
      if (!mounted) return;
      AppSnackBar.showSuccess(
        message: 'Address shared successfully!',
        context: context,
      );
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.showError(
        message: 'Failed to share address. Please try again.',
        context: context,
      );
    }
  }

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
  Future<void> _logout() async {
    final shouldLogout = await _showLogoutDialog();
    if (shouldLogout == true) {
      await ref.read(authStateProvider.notifier).logout();
    }
  }
}

// Data Models for Quick Actions and Menu Items
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
