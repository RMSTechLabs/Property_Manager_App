// Dashboard Screen (Image 1) - Responsive with TypeAhead and Skeleton Loading
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';
import 'package:property_manager_app/src/core/constants/app_constants.dart';
import 'package:property_manager_app/src/data/models/community_item_model.dart';
import 'package:property_manager_app/src/data/models/society_state_model.dart';
import 'package:property_manager_app/src/presentation/providers/society_provider.dart';
import 'package:redacted/redacted.dart';
import 'package:property_manager_app/src/core/utils/app_helper.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _communityController = TextEditingController();
  Logger logger = Logger(printer: PrettyPrinter());
  bool _isLoading = true;
  bool _isError = false;
  String _errorMessage = 'Something went wrong. Please try again later.';
  late FocusNode _communityFocusNode;
  // Dynamic community data
  List<CommunityItem> communities = [];
  CommunityItem? selectedCommunity;

  @override
  void initState() {
    super.initState();
    // Wait for the first frame to render before unfocusing
    _communityFocusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load data from Riverpod provider
      await ref.read(societyStateProvider.notifier).initialize();

      final societyListState = ref.read(societyStateProvider);

      if (societyListState.societies.isNotEmpty) {
        setState(() {
          communities = _convertSocietiesToCommunityItems(
            societyListState.societies,
            societyListState.ownerOrTenantName!,
          );
          if (communities.isNotEmpty) {
            selectedCommunity = communities.first;

            _communityController.text = selectedCommunity!.name.split(',')[0];
            // 🔥 SET INITIAL COMMUNITY GLOBALLY
            ref.read(selectedCommunityProvider.notifier).state =
                selectedCommunity;
            logger.i('Initial community set: ${selectedCommunity!.id}');
          }
          _isLoading = false;
          _isError = false;
        });
      } else {
        setState(() {
          _isError = true;
          _isLoading = false;
          _errorMessage = societyListState.error ?? 'No communities found.';
        });
      }
    } catch (e) {
      setState(() {
        _isError = true;
        _isLoading = false;
        _errorMessage = 'An error occurred while loading data: $e';
      });
    }
  }

  List<CommunityItem> _convertSocietiesToCommunityItems(
    List<SocietyStateModel> societies,
    String ownerOrTenantName,
  ) {
    return societies.map((society) {
      return CommunityItem(
        id: society.id ?? 'unknown',
        name:
            '${society.block ?? ''}-${society.flat ?? ''}-${society.societyId ?? ''}-${society.apartmentId ?? ''},${society.block},${society.society}'
                .trim(),
        residentType: society.residentType ?? 'Unknown',
        ownerOrTenantName: ownerOrTenantName,
        societyId: society.societyId?.toString() ?? '',
        apartmentId: society.apartmentId?.toString() ?? '',
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    if (_isError) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.05),
            child: Text(
              _errorMessage,
              style: GoogleFonts.lato(fontSize: 16, color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppConstants.secondartGradient,
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Header with Community TypeAhead
                Padding(
                  padding: EdgeInsets.all(screenWidth * 0.05),
                  child: Row(
                    children: [
                      // Container(
                      //   width: screenWidth * 0.12,
                      //   height: screenWidth * 0.12,
                      //   decoration: BoxDecoration(
                      //     color: Colors.white.withOpacity(0.2),
                      //     borderRadius: BorderRadius.circular(
                      //       screenWidth * 0.06,
                      //     ),
                      //   ),
                      //   child: Icon(
                      //     Icons.home_outlined,
                      //     color: Colors.white,
                      //     size: screenWidth * 0.06,
                      //   ),
                      // ),
                      Container(
                        width: screenWidth * 0.12,
                        height: screenWidth * 0.12,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(
                            screenWidth * 0.06,
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(
                            screenWidth * 0.02,
                          ), // optional: to give some inner spacing
                          child: Image.asset(
                            'assets/images/logo.png', // change this path to your image asset
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),

                      SizedBox(width: screenWidth * 0.03),
                      Expanded(
                        child: _isLoading
                            ? _buildSkeletonTypeAhead()
                            : _buildCommunityTypeAhead(),
                      ),
                    ],
                  ),
                ),

                // Main Content Area
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(top: screenHeight * 0.025),
                    decoration: const BoxDecoration(
                      color: AppConstants.whiteColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Grid Cards
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.all(screenWidth * 0.05),
                            child: _isLoading
                                ? _buildSkeletonGrid(screenWidth)
                                : _buildDashboardGrid(screenWidth),
                          ),
                        ),

                        // Amenities Section
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                            screenWidth * 0.05,
                            0,
                            screenWidth * 0.05,
                            screenWidth * 0.05,
                          ),
                          child: _isLoading
                              ? _buildSkeletonAmenities(screenWidth)
                              : _buildAmenitiesCard(screenWidth),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCommunityTypeAhead() {
    return Container(
      // constraints: const BoxConstraints(minHeight:10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.52),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.52)),
      ),
      child: TypeAheadField<CommunityItem>(
        controller: _communityController,
        debounceDuration: const Duration(milliseconds: 300), //

        builder: (context, controller, focusNode) {
          return TextField(
            controller: controller,
            focusNode: focusNode,
            style: GoogleFonts.lato(
              color: Colors.black,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              // border: InputBorder.none,
              fillColor: Colors.transparent,
              hint: Text(
                "Select Community",
                style: GoogleFonts.lato(
                  color: AppConstants.black50,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),

              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              suffixIcon: GestureDetector(
                // onTap: () {
                //   if (_communityFocusNode.hasFocus) {
                //     _communityFocusNode.unfocus(); // Hide dropdown
                //   } else {
                //     _communityFocusNode.requestFocus(); // Show dropdown
                //   }
                // },
                child: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.black,
                ),
              ),

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.white),
              ),
            ),
          );
        },
        suggestionsCallback: (pattern) {
          return communities
              .where(
                (community) => community.name.toLowerCase().contains(
                  pattern.toLowerCase(),
                ),
              )
              .toList();
        },
        itemBuilder: (context, community) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F4F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  community.name,
                  style: GoogleFonts.lato(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppConstants.black,
                  ),
                ),
                if (community.residentType.isNotEmpty)
                  Row(
                    children: [
                      Text(
                        community.ownerOrTenantName,
                        style: GoogleFonts.lato(
                          fontSize: 11,
                          color: AppConstants.black50,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: community.residentType == 'owner'
                              ? Colors.green.shade100
                              : Colors.blue.shade100, // or any color you prefer
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          AppHelper.toSentenceCase(community.residentType),
                          style: GoogleFonts.lato(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
        onSelected: (community) {
          ref.read(selectedCommunityProvider.notifier).state = community;
          logger.i('Community changed to: ${community.id}');
          setState(() {
            selectedCommunity = community;
            _communityController.text = community.name.split(',')[0];
          });
        },
        decorationBuilder: (context, child) {
          return Material(
            type: MaterialType.card,
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF2F4F5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: child,
            ),
          );
        },
      ),
    );
  }

  Widget _buildSkeletonTypeAhead() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 20,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            ).redacted(context: context, redact: true),
          ),
          const SizedBox(width: 8),
          Icon(Icons.keyboard_arrow_down, color: Colors.white.withOpacity(0.5)),
        ],
      ),
    );
  }

  Widget _buildDashboardGrid(double screenWidth) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth < 600 ? 2 : 3;
        final childAspectRatio = constraints.maxWidth < 600 ? 1.0 : 1.1;

        return GridView.count(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: screenWidth * 0.04,
          mainAxisSpacing: screenWidth * 0.04,
          childAspectRatio: childAspectRatio,
          children: [
            _buildDashboardCard(
              icon: Icons.people_outline,
              title: "Visitors",
              subtitle: "Expected & past visitors",
              onTap: () => _navigateToVisitors(),
              screenWidth: screenWidth,
            ),
            _buildDashboardCard(
              icon: Icons.notifications_outlined,
              title: "Notify Gate",
              subtitle: "Expected cab, delivery etc",
              onTap: () => _navigateToNotifyGate(),
              screenWidth: screenWidth,
            ),
            _buildDashboardCard(
              icon: Icons.help_outline,
              title: "Help Desk",
              subtitle: "Personal issues",
              onTap: () => _navigateToHelpDesk(),
              screenWidth: screenWidth,
            ),
            _buildDashboardCard(
              icon: Icons.campaign_outlined,
              title: "Notice Board",
              subtitle: "Society announcements",
              onTap: () => _navigateToNoticeBoard(),
              screenWidth: screenWidth,
            ),
          ],
        );
      },
    );
  }

  Widget _buildSkeletonGrid(double screenWidth) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth < 600 ? 2 : 3;

        return GridView.count(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: screenWidth * 0.04,
          mainAxisSpacing: screenWidth * 0.04,
          childAspectRatio: 1.0,
          children: List.generate(
            4,
            (index) => _buildSkeletonCard(screenWidth),
          ),
        );
      },
    );
  }

  Widget _buildSkeletonCard(double screenWidth) {
    return Container(
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
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: screenWidth * 0.12,
              height: screenWidth * 0.12,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(12),
              ),
            ).redacted(context: context, redact: true),
            SizedBox(height: screenWidth * 0.03),
            Container(
              height: 16,
              width: screenWidth * 0.2,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ).redacted(context: context, redact: true),
            SizedBox(height: screenWidth * 0.02),
            Container(
              height: 12,
              width: screenWidth * 0.25,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ).redacted(context: context, redact: true),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required double screenWidth,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
        ),
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: screenWidth * 0.12,
                height: screenWidth * 0.12,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: screenWidth * 0.06,
                ),
              ),
              SizedBox(height: screenWidth * 0.03),
              Flexible(
                child: Text(
                  title,
                  style: GoogleFonts.lato(
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.black,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: screenWidth * 0.01),
              Flexible(
                child: Text(
                  subtitle,
                  style: GoogleFonts.lato(
                    fontSize: screenWidth * 0.03,
                    color: AppConstants.black50,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmenitiesCard(double screenWidth) {
    return GestureDetector(
      onTap: () => _navigateToAmenities(),
      child: Container(
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
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              width: screenWidth * 0.15,
              height: screenWidth * 0.15,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                Icons.location_city_outlined,
                color: Colors.white,
                size: screenWidth * 0.07,
              ),
            ),
            SizedBox(width: screenWidth * 0.04),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Amenities and Classes",
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
                    "Browse and book amenities",
                    style: GoogleFonts.lato(
                      fontSize: screenWidth * 0.035,
                      color: AppConstants.black50,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppConstants.black50,
              size: screenWidth * 0.04,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonAmenities(double screenWidth) {
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
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: screenWidth * 0.15,
            height: screenWidth * 0.15,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(15),
            ),
          ).redacted(context: context, redact: true),
          SizedBox(width: screenWidth * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 18,
                  width: screenWidth * 0.4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ).redacted(context: context, redact: true),
                SizedBox(height: screenWidth * 0.02),
                Container(
                  height: 14,
                  width: screenWidth * 0.3,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ).redacted(context: context, redact: true),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: Colors.grey.shade300,
            size: screenWidth * 0.04,
          ),
        ],
      ),
    );
  }

  // Navigation methods
  void _navigateToVisitors() {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => const PropertySelectionScreen()),
    // );
    print('Navigate to Notify Gate');
  }

  void _navigateToNotifyGate() {
    print('Navigate to Notify Gate');
  }

  void _navigateToHelpDesk() {
    context.push('/help_desk');
  }

  void _navigateToNoticeBoard() {
    print('Navigate to Notice Board');
  }

  void _navigateToAmenities() {
    print('Navigate to Amenities');
  }

  @override
  void dispose() {
    _communityController.dispose();
    _communityFocusNode.dispose();
    super.dispose();
  }
}
